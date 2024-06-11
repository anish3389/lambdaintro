provider "aws" {
  region = var.region
  default_tags {
    tags = {
      project   = var.project
      silo      = var.silo
      terraform = var.terraform
      owner     = var.owner
    }
  }
}