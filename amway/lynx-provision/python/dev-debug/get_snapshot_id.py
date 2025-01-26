import boto3
import datetime
import sys
import argparse
import os

AWS_REGION_NAME = 'eu-central-1'

client = boto3.client('ec2', region_name=AWS_REGION_NAME)



def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("-env", help="Environment name")
    parser.add_argument("-snap", help="Snapshots to use: db or media", nargs="*")
    args = parser.parse_args()
    return args



def describe_snapshots(snapshot_name):
    filters = [
            {
               'Name': 'tag:Name',
               'Values': snapshot_name
           }
    ]

    snapshots = client.describe_snapshots(Filters=filters)
    return snapshots



def get_latest_snapshot(snapshots, env, snap_prefix):

    unsorted_list_of_snapshots= []
    snapshots_count = len(snapshots['Snapshots'])
    if snapshots_count < 1: 
        print(
            "There are no {} snapshots for environment {}."
            .format(snap_prefix, env))
        sys.exit(1)

    for snapshot in snapshots['Snapshots']:
        unsorted_list_of_snapshots.append({'creation_date': snapshot['StartTime'], 'snap_id': snapshot['SnapshotId']})

    
    sorted_list_of_snapshots = sorted(unsorted_list_of_snapshots, key=lambda k: k['creation_date'], reverse= True)
    latest_snap_id = sorted_list_of_snapshots[0]['snap_id']
    latest_snap_id_creation_time = sorted_list_of_snapshots[0]['creation_date']

    print(
            "Env: {}, Snapshot ID: {}, Creation time: {}."
            .format(env + "-" + snap_prefix, latest_snap_id, latest_snap_id_creation_time.strftime("%Y-%m-%d %H:%M:%S")))
    return latest_snap_id        


# Get lates snapshot ids of db and media for given environment
args = parse_args()
snapshot_names = []
for prefix in args.snap:
    snapshot_names = [args.env + "-" + prefix]
    
    list_of_snapshots = describe_snapshots(snapshot_names)
    snap_id = get_latest_snapshot(list_of_snapshots, args.env, prefix)

    if prefix == "db":
        with open("variables", "a") as f:
            f.write("SNAPSHOT_ID_DB=" + snap_id + "\n")
    elif prefix == "media":
        with open("variables", "a") as f:
            f.write("SNAPSHOT_ID_MEDIA=" + snap_id + "\n")   
