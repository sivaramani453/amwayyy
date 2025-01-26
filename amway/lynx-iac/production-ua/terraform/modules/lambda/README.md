## Lambda module
### Overview 
This module will create lambda function, logGroup to send logs to and
permission to invoke this function from specified resource by it's arn

### Input
| Input variable  | Description | Default value |
| ------------- | ------------- | ------------- |
| function_name  | name of lambda function  | - |
| filename | path to ZIP archive to upload to aws | - |
| handler | meaning of this input var depends on runtime (for instance for golang in it binary file name, for python it is function name that aws will run in execution context...) | - |
| vpc_id | VPC id to run lambda func in. If specified, internet and network access is all on your configuration | - |
| subnets | list of subnets where this lambda func will be executed | - |
| runtime | 1 of supported lambda [runtime](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html) | - |
| timeout | max execution time in seconds. After this period func  execution will be terminated no matter what| 10 |
| memory_amount | Memory allocated for lambda function | 128 |
| logs_retention | Days to keep logs | 7 |
| env_vars | *dict* of name: value environment variables for lambda func | {} |
| principal| principal of lambda func invokation permission | -|
| arn | resource arn to allow lambda invokation | -|
| statement_id| A unique statement identifier | - |


### Ouput
|Name| Description|
| -- | ---------- |
|func_arn| lambda function arn|
|invoke_arn|lambda function invoke arn|
|log_group_name|log group name|
|lambda_iam_role_name|lambda iam role name|
