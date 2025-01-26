# Setup

This sets up the s3 bucket and dynamoDB table for the automation cluster. This is a one-time task so nothing special, just plain terraform.

Run it like this:

    export AWS_PROFILE=<profile name that accesses the automation dev AWS account>
    terraform plan
    terraform apply
