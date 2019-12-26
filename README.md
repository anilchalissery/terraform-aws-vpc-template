# terraform-aws-vpc-template
a terraform template to create aws vpc

Steps to create aws vpc using terraform

clone the repo to a empty folder

edit main.tf according to your office public ip and office ssl , with your access key and secert key ..etc

to download the aws provider and initializing the terraform plugins use init command as below

$ terraform init

To check for any syntax we could run terraform plan

$ terraform plan

to create the vpc run terraform apply

$ terraform apply
