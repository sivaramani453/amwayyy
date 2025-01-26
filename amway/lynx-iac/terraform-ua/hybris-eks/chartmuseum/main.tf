
resource "aws_s3_bucket" "app-backend" {
  bucket        = "amway-chartmuseum-h-backend"
  acl           = "private"
  force_destroy = "false"

  tags = {
    Service       = "chartmuseum-h",
    Environment   = "DEV",
    ApplicationID = "APP1433689"
  }
}

resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = aws_s3_bucket.app-backend.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::860702706577:role/hybris-eks2021092015353215910000000a"
            },
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::amway-chartmuseum-h-backend/*",
                "arn:aws:s3:::amway-chartmuseum-h-backend"
            ]
        }
    ]
  })
}
