resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = var.mutable_tags ? "MUTABLE" : "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
}
