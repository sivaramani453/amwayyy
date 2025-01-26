#!/usr/bin/env python

import os
import sys
import re
import time
import argparse
import boto3

# Const
CriticalError = 1
NonCriticalError = 11
TimesToRepeat = 60
Region = "eu-central-1"
RequiredNumberOfInstances = 4
RunningStateName = "running"
StoppedStateName = "stopped"
ActiveStateName = "active"

class AWSError(Exception):
    pass

class TimeoutError(Exception):
    pass

class ArgumentError(Exception):
    pass
    
    
def repeat(times):
    def inner(func):
        def wrapper(*args, **kwargs):
            for i in range(times):
                result = func(*args, **kwargs)
                if result:
                    return result
                time.sleep(10)
            raise TimeoutError("Function {0} did not succeed via {1} attempts".format(func.__name__, times))
        return wrapper
    return inner


def parse_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument("--instance-ids", nargs='+', required = True)
    parser.add_argument("--capacity-reservation-id", required = True)
    args = parser.parse_args()
    return args


def get_ec2_client(region):
    sess = boto3.Session(region_name = region)
    ec2 = sess.client("ec2")
    return ec2


def validate_args(value, objtype):
    cap_pattern = re.compile(r"^cr-[a-z0-9]{17}$")
    inst_pattern = re.compile(r"^i-[a-z0-9]{17}$")
    if objtype == "instance_id":
        if inst_pattern.match(value):
            return 
    elif objtype == "capacity_reservation":
        if cap_pattern.match(value): 
            return 
    else:
        raise ArgumentError("Unsupported type {0}".format(objtype))
    raise ArgumentError("{0} does not seem to be valid {1}".format(value, objtype))


def get_cap_reserv_avail_instance_count(client, id):
    try:
        resp = client.describe_capacity_reservations(CapacityReservationIds = [ id ])
    except Exception as err:
        raise AWSError("API call to describe capacity reservation failed: {0}".format(err))
    try:
        if resp["CapacityReservations"][0]["State"] == ActiveStateName:
            count = resp["CapacityReservations"][0]["AvailableInstanceCount"]
            return count
    except IndexError:
        raise AWSError("Could not get avail instance count from aws")
    return 0


def stop_aws_instances(ec2, ids):
    try:
        ec2.stop_instances(InstanceIds = ids)
    except:
        raise AWSError("API call to stop instances failed")
        
def start_aws_instances(ec2, ids):
    try:
        ec2.start_instances(InstanceIds = ids)
    except:
        raise AWSError("API call to start instances failed")
        


@repeat(TimesToRepeat)
def wait_for_instances_to_be_in_proper_state(ec2, ids, state):
    try:
        resp = ec2.describe_instances(InstanceIds = ids)
    except:
        # log it
        return False
    try:
        states = [x["Instances"][0]["State"]["Name"] for x in resp["Reservations"]]
    except:
        # not gonna happen if aws response is valid but who knows
        return False
    if len(states) != len(ids):
        # this could happen if some instance id does not exist
        return False
    if len(set(states)) == 1:
        if states[0] == state:
            return True    
    return False
    

def assign_capacity_reservation_to_instance(ec2, cap_id, instance_id):
    spec = {"CapacityReservationTarget": { "CapacityReservationId": cap_id }}
    try:
        resp = ec2.modify_instance_capacity_reservation_attributes( InstanceId = instance_id, 
                                                                    CapacityReservationSpecification = spec )
    except Exception as err:
        raise AWSError("Could not assign capacity reservation to instance: {0}".format(err))
        
    

if __name__ == "__main__":
    rc = 0
    # Get and validate args
    args = parse_arguments()
    try:
        validate_args(args.capacity_reservation_id, "capacity_reservation")
        [validate_args(x, "instance_id") for x in args.instance_ids]
    except ArgumentError as err:
        print(err)
        # We did nothing so deployment can go on
        # however we should exit with err to notify users
        sys.exit(NonCriticalError) 
    
    # Create ec2 boto client
    ec2 = get_ec2_client(Region)
    
    # Check if capacity reservation contains enough capacity =)
    try:
        avail_instance_count = get_cap_reserv_avail_instance_count(ec2, args.capacity_reservation_id)
    except AWSError as err:
        print(err)
        sys.exit(NonCriticalError)
    if avail_instance_count < RequiredNumberOfInstances:
        print("Not enogh avail instance count in capacity reservation {0}. Required: {1}, avail: {2}".format(args.capacity_reservation_id, RequiredNumberOfInstances, avail_instance_count))
        # exit now and continue deployment bc we did not stop any instaces yet
        sys.exit(NonCriticalError)
    
    # Stop instances and wait for proper state
    try:
        stop_aws_instances(ec2, args.instance_ids)
    except AWSError as err:
        print(err)
        # exit now and continue deployment bc we proabably did not stop instances
        sys.exit(NonCriticalError)
    try:
        wait_for_instances_to_be_in_proper_state(ec2, args.instance_ids, StoppedStateName)
    except TimeoutError as err:
        print(err)
        # Critical error, deployment failed
        sys.exit(CriticalError)
        
    # Assign capacity reservation to instances 
    try:
        for instance_id in args.instance_ids:
            assign_capacity_reservation_to_instance(ec2, args.capacity_reservation_id, instance_id)
    except AWSError as err:
        print(err)
        # Failed to assign capacity reservation but still could start instances and continue deployment
        rc = NonCriticalError
    
    # Run instances and wait for proper state
    try:
        start_aws_instances(ec2, args.instance_ids)
    except AWSError as err:
        print(err)
        # Critical error, deployment failed
        sys.exit(CriticalError)
    try:
        wait_for_instances_to_be_in_proper_state(ec2, args.instance_ids, RunningStateName)
    except TimeoutError as err:
        print(err)
        # Critical error, deployment failed
        sys.exit(CriticalError)
    # exit with proper rc (will be handled in next step)
    sys.exit(rc)
