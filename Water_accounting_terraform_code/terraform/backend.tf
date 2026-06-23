terraform {
  backend "s3" {
    bucket  = "well-labs-water-accounting-product-terraform-state"
    region  = "ap-south-1"
    encrypt = true
  }
}
