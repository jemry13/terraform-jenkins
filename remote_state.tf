# --------------------------------------------------
# Remote State for our application 
# --------------------------------------------------
terraform {
  backend "s3" {
    bucket         = "notes-app-alejo"
    key            = "dev-sandbox/alejo_terraform/terraform.tfstate"
    region         = "ap-southeast-2"
    encrypt        = true
  }
}