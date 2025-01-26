# AWS Instance Scheduler
It consists of three parts:

 1. Lambda Function
 2. Elastic Container Repository (ECR)
 3. Elastic Container Service (ECS)

A bit more details on each part.

**Lambda Function** - the code of it is maintained by the AWS itself. More information of how it was deployed and how it works, you can find here [press me](https://docs.aws.amazon.com/solutions/latest/instance-scheduler/deployment.html#step1)

**ECR** - This is the separate docker repository in the AWS, it was deployed with terraform and you can find the code under the **./ecr** folder. It has repository policy which allows basic operation with it and two lifecycle policy, first one for cleaning untagged images older than 14 days and second one for keeping last 30 tagged images with **v prefixes**.

**ECS** - This is the main part, it was also deployed with terraform and you can find the code under the **./ecs** folder. The are several crucial moment to keep in mind. When you deploy this part you should pass the configuration table name of the dynamodb and the arn of the kms key which was used to encrypt it. Both variable you can get form the Lambda Function.  And one more thing, don't forget to create **ecsTaskExecutionRole** if it doesn't exist already. For the **AWS EU Hybris DEV** account it was done manually, for more details see this instruction [use the Mouse, Luke](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html)
This task execution role grants the Amazon ECS container and Fargate agents minimal needed permission to make AWS API calls on your behalf.
