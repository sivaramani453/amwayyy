import boto3
import datetime
import os


AWS_REGION_NAME = os.getenv('AWS_REGION_NAME')
SNAPSHOT_UTIL = ['true', 'TRUE', 'True']

def lambda_handler(event, context):
    client = boto3.client('ec2', region_name=AWS_REGION_NAME)

    filters = [
         {
             'Name': 'tag:Utilization',
             'Values': SNAPSHOT_UTIL
         }
    ]

    snapshots = client.describe_snapshots(Filters=filters)
  

    for snapshot in snapshots['Snapshots']:
        snap_init_time = snapshot['StartTime']
        snap_init_date = snap_init_time.date()
        current_date = datetime.datetime.now().date()
        diff_date = current_date-snap_init_date
        try:
            if diff_date.days>3:
                snap_id = snapshot['SnapshotId']
                snap_desc = snapshot['Description']
                print("Snapshot to delete: {}. Description: {}. Created {} days ago.".format(snap_id, snap_desc, diff_date.days))
                client.delete_snapshot(SnapshotId=snap_id)
        except Exception as e:
            print("Couldn't delete snapshot with id: {}. Reason is: {}".format(snap_id, e))
            continue
        
