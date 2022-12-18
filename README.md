# terraform-projects

Launching a VPC with 1 Public subnet and 1 Private subnet in AWS using Terraform

In this project post I will launch a VPC and configure it with 2 subnets, one public and one private. A WORDPRESS EC2 instance will be created in the public subnet while a MYSQL instance will be created in the private subnet. I will create a Bastion host or jump box which will allow SSH connections to the MYSQL instance which is created in the private subnet. It is best practice when creating a multi-tier website with web server in public subnets and database server in private subnet so no one can have access to it since its private.

For this projectthe wordpress will be a public facing application while the MYSQL will be the backend database server.
