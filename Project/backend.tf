terraform {
  backend "s3" {
    bucket         = "maro-lesson-5-tfstate-12345"
    key            = "final-project/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "maro-lesson-5-tf-locks"
    encrypt        = true
  }
}
