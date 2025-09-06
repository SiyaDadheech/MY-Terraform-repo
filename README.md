# MY-Terraform-repo
This Repo is for terraform
Step 1. create a directory: mkdir demo
Step 2. cd demo
Step 3. create a file containing provider info. Here I am using AWS: vi provider.tf
Step 4. terraform init
Step 5.  create the main file for creating the ec2 instance, vpc and subnet: vi main.tf
Step 6. check for validation: terraform validate
Step 7. To apply changes: terraform apply -auto-approve(no ask to enter the yes/no)
Step 8. To destroy: terraform destroy -auto-approve

