resource "aws_s3_bucket" "static_website" {
  bucket = "punitdarira-static-website-final-cicd"
}

resource "aws_s3_bucket_website_configuration" "static_website_configuration" {
  bucket = aws_s3_bucket.static_website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.static_website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "s3:*"
        Effect    = "Allow"
        Resource  = ["${aws_s3_bucket.static_website.arn}/*"]
        Principal = "*"
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.static_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

locals {
  files_to_upload = {
    "index.html" = "../src/index.html",
    "styles.css" = "../src/styles.css"
  }
}

resource "aws_s3_object" "web_files" {
  for_each = local.files_to_upload

  bucket = aws_s3_bucket.static_website.id
  key    = each.key
  source = each.value
  content_type = "text/html"
}

data "template_file" "app_js" {
  template = file("${path.module}/../src/app.js.tpl")

  vars = {
    api_gateway_url = "https://${aws_api_gateway_rest_api.api.id}.execute-api.us-east-1.amazonaws.com/prod/text"
  }
}
resource "aws_s3_bucket_object" "app_js" {
  bucket = aws_s3_bucket.static_website.id
  key    = "app.js"
  content = data.template_file.app_js.rendered
  etag   = md5(data.template_file.app_js.rendered)
}

resource "aws_lambda_function" "text_function" {
  function_name = "textFunction"
  handler       = "handler.handler"
  runtime       = "nodejs22.x"
  role          = aws_iam_role.lambda_exec.arn
  filename      = "../lambda/package.zip"

    environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.static_website.bucket
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.text_function.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_api_gateway_rest_api" "api" {
  name        = "textApi"
  description = "API for fetching text from Lambda"
}

resource "aws_api_gateway_resource" "text" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "text"
}

resource "aws_api_gateway_method" "get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.text.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.text.id
  http_method             = aws_api_gateway_method.get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.text_function.invoke_arn
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_method.get
  ]
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "prod"
}
output "website_url" {
  value = aws_s3_bucket.static_website.website_endpoint
}

output "api_url" {
  value = "${aws_api_gateway_rest_api.api.execution_arn}/text"
}