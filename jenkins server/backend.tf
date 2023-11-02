terraform {

  backend "s3" {

    bucket = "eksbuckets"
    key    = "jenkins/terraform.tfstate"
    region = "ap-south-1"

  }
}


