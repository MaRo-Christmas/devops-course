data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "maro-lesson-5-tfstate-12345"
    key    = "lesson-5/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "aws_vpc" "selected" {
  id = data.terraform_remote_state.network.outputs.vpc_id
}