terraform {
  backend "s3" {
    bucket         = "punitdarira-cicd-final-state"
    key            = "terraform/state"
    region         = "us-east-1"
  }
}