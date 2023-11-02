terraform {
  backend "s3" {
    bucket = "jenkinseks"
    key    = "eks/terraform.tfstate"
    region = "ap-south-1"
  }
}