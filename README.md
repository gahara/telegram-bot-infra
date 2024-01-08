# Telegram bot infrastructure template

## Telegram bot deployed as AWS Lambda function
Deploy telegram bot via GitHub actions or running a couple commands locally  
Example bot is just an echo and greetings bot  
Actual bot should also be placed in `func` directory  
Although this infrastructure is tailored for python, it can be easily reused with other available [languages](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html)


### Instruments used:
- AWS Lambda to run 
- Terraform to deploy
- AWS CloudFormation to create backend to store terraform state
- Python to write function's code

### Things you need to prepare to start:
- AWS account + AWS CLI credentials. Your account should have permissions to deploy stuff
- Telegram bot token

Note, that if you want build a layer for lambda function locally, your system should be compatible with 
lambda function's environment. For example, if you run terraform configuration on macOS, function
may fail to work in lambda environment, as it's based on Linux, and layer was build in macOS environment. Some 
packages may not be compatible. Also be sure to use the exact same python version in your building environment and function's runtime

Because lambda function is used, it's better to have your bot in webhook mode. 
When you get url for you lambda function(terraform is configured to show you one, check outputs.tf)
make the following request (either browser of curl is fine)  
`https://api.telegram.org/bot<token>/setWebHook?url=https://<url>`  
Url must have `https`  
To check that it worked, visit
`https://api.telegram.org/bot<token>/getWebhookInfo`

### How to:
#### Using GitHub actions
Provide all secrets and variables in workflow, and you are good to go

#### Locally 
Provide AWS credentials. They will be used by AWS CLI and terraform. 
Run  
`aws cloudformation create-stack --stack-name stackname --template-body file://create_s3.yaml --parameters ParameterKey=S3BucketName,ParameterValue=bucketname ParameterKey=S3Tag,ParameterValue=tagname
`  
to create storage for terraform state.  
Check `variables.tf` for other variables you need to provide. Note that terraform will search for 
environmental variables starting with `TF_VAR`. Also provide backend configuration when running terraform
Then run 
`terraform init`  
`terraform apply`




