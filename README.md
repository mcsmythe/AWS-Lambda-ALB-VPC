## AWS VPC that uses IAM, Lambda, ECR, ALB and APIGateway with Terraform

This Terraform project will deploy a **VPC** with an **Internet Gateway**, **2 Public Subnets**, , **A Public Route Table , Security Group, Application Load Balancer with Target Group, Lambda Function that pulls from ECR, APIGateway and IAM Role** This is my first forway into anything AWS Serverless, but it is super exciting stuff. Obviously terraform and coding refactoring and debugging work needs to happen but this brief project was a great jumping platform to limitless Serverless Infrastructure opportunities.

The point of this intial project is to learn and deploy scalable AWS Serverless projects utilizing Infrastucture as code. The goal was to deploy an AWS Serverless App and then an a user would hit the API Gateway and get AWS instance, account, regoin and Public IP details (utilizing Python boto3 and AWS SDK script inside a Lambda function), but I need to keep tinkering with the Python script further so I have added the python script that I will continue to work on.

I chose a simple python project from AWS blog
(https://aws.amazon.com/blogs/aws/new-for-aws-lambda-container-image-support/) and got some AWESOME insight on this project from **Pablo's Spot on YouTube**

Create a user in AWS. I use terraform_user with AWS CLI

These steps below will build the Dockerfile locally also using the AWS CLI then will create the ECR Repo, tag the image, login and push the Docker image to AWS. You can just throw these lines into a shell script and chmod +x and run it instead of copying and paste but why not.

```
docker build . -t lambda-container:1
docker run -p 9000:8080 lambda-container:1
curl -XPOST ("http://localhost:9000/2015-03-31/functions/function/invocations") -d '{}'
aws ecr create-repository --repository-name lambda-container
docker tag lambda-container:1 {Insert_AWS_AccountID}.dkr.ecr.{Region}.amazonaws.com/lambda-container:1
aws ecr get-login-password | docker login --username AWS --password-stdin {Insert_AWS_AccountID}.dkr.ecr.{Region}.amazonaws.com
docker push {Insert_AWS_AccountID}.dkr.ecr.{Region}.amazonaws.com/lambda-container:1
```

###### Terraform

```
terraform init
terraform plan -out output.tf
terraform apply
```

###### Due to Python and APIGateway issues I utilzed the cmd line to get response

```
aws lambda invoke --region us-east-1 --function-name lambda_container out --log-type Tail --query LogResult --output text | base64 -d

cat out (message from lambda fuction)
terraform destroy
```

Now back to tinkering...
