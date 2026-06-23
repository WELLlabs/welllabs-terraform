terraform {
  backend "s3" {
    bucket  = "well-labs-solution-explorer-terraform-state"
    region  = "ap-south-1"
    encrypt = true
  }
}
