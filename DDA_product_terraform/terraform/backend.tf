terraform {
  backend "s3" {
    bucket  = "well-labs-dda-product-terraform-state"
    region  = "ap-south-1"
    encrypt = true
  }
}
