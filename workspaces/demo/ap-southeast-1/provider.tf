terraform {
  backend "s3" {
    bucket = "demo.terraform.42dev.co"
    key    = "s3-tf-demo/ap-southeast-1/state.tfstate"
    region = "ap-southeast-1"
  } 
}

provider "aws" {
  region = var.region
}

variable "region" {
  default = "ap-southeast-1"
}
