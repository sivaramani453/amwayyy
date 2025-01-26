import os
import boto3
import datetime
from datetime import timezone
from time import sleep

# Const
days_to_store = int(os.environ.get("DAYS_TO_STORE", "5"))
volume_filters = [{"Name": "status", "Values": ["available"]}]


def handler(event, context):
    now = datetime.datetime.now(timezone.utc)
    ec2r = boto3.resource("ec2")
    ct_client = boto3.client("cloudtrail")

    volumes = get_volumes(ec2r, ct_client, volume_filters)
    # filter object not dict
    volumes_to_delete = filter(should_be_deleted, volumes)

    # check if the filter object is empty
    # I think this is better than converting it to the list
    e = next(volumes_to_delete, None)
    if e is None:
        print("There are no volumes to delete")
    else:
        for volume in volumes_to_delete:
            v = ec2r.Volume(volume["id"])
            print("Deleting EBS volume: {}, id: {} ".format(volume["name"], volume["id"]))
            v.delete()


def should_be_deleted(volume):
    now = datetime.datetime.now(timezone.utc)
    time_to_compare = volume["detach_time"] if volume[
        "detach_time"] else volume["create_time"]
    delta = now - time_to_compare
    if delta.days >= days_to_store:
        return True
    return False


def get_volumes(ec2r, ct_client, volume_filters):
    volumes = []

    available_volumes = ec2r.volumes.filter(Filters=volume_filters)
    for volume in available_volumes:
        id = volume.volume_id
        create_time = volume.create_time
        volume_name = get_volume_name(volume)
        detach_time = get_volume_detach_time(ct_client, volume)
        volumes.append({
            "id": id,
            "name": volume_name,
            "detach_time": detach_time,
            "create_time": create_time
        })

        # To avoid the throttle exception, adding 1 sec of pause
        sleep(1)

    return volumes


def get_volume_name(volume):
    names = []
    if volume.tags:
        names = [tag["Value"] for tag in volume.tags if tag["Key"] == "Name"]

    return names[0] if len(names) > 0 else "<null>"


def get_volume_detach_time(ct_client, volume):
    lookup_attributes = [{
        "AttributeKey": "ResourceName",
        "AttributeValue": volume.volume_id
    }]
    lookup_response = ct_client.lookup_events(
        LookupAttributes=lookup_attributes)

    ct_events = lookup_response.get("Events", [])
    ct_detach_times = [
        x["EventTime"] for x in ct_events if x["EventName"] == "DetachVolume"
    ]

    return ct_detach_times[0] if len(ct_detach_times) > 0 else None


if __name__ == "__main__":
    handler(None, None)
