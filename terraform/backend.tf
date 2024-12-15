terraform {
  backend "s3" {
    bucket         = "punitdarira-static-website-final-cicd"
    key            = "terraform/state"
    region         = "us-east-1"
  }
}