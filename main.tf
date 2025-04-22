terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.94.1"
    }
  }
}

locals {
  s3_origin_id = "mys3origin"
}

provider "aws" {
    region = "us-east-1"
}

#--------------------------------------------------------------------------------------------------
# creating a role
#--------------------------------------------------------------------------------------------------
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = {
    Environment = "dev"
  }
}

#--------------------------------------------------------------------------------------------------
# attaching policies to the role
#--------------------------------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "lambda-basic-execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "ses" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}

resource "aws_iam_role_policy_attachment" "s3-full-access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "cloudwatch-log" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "dynamodb-full-access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

#--------------------------------------------------------------------------------------------------
# making lambda function
#--------------------------------------------------------------------------------------------------

resource "aws_lambda_function" "first-lambda" {
  filename         = "lambda_function.zip"
  function_name    = "my_lambda"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  role             = aws_iam_role.lambda_role.arn
  source_code_hash = filebase64sha256("lambda_function.zip")

  tags = {
    name = "first-lambda"
  }
  
}

#--------------------------------------------------------------------------------------------------
# creating a dynamodb table
#--------------------------------------------------------------------------------------------------

resource "aws_dynamodb_table" "db-table" {
  name             = "chat-bot"
  hash_key         = "sessionId"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "sessionId"
    type = "S"
  }

    attribute {
    name = "timestamp"
    type = "S"
  }

    attribute {
    name = "sender	"
    type = "S"
  }

    attribute {
    name = "message"
    type = "S"
  }

  replica {
    region_name = "us-east-2"
  }

  replica {
    region_name = "us-west-2"
  }
}

#--------------------------------------------------------------------------------------------------
# creating a api gateway
#--------------------------------------------------------------------------------------------------

resource "aws_api_gateway_rest_api" "myapi" {
  name = "myapi"
}

resource "aws_api_gateway_resource" "myapiresource" {
  rest_api_id = aws_api_gateway_rest_api.myapi.id
  parent_id   = aws_api_gateway_rest_api.myapi.root_resource_id
  path_part   = "chatbot"
}

#--------------------------------------------------------------------------------------------------
# creating a method 
#--------------------------------------------------------------------------------------------------

resource "aws_api_gateway_method" "chatbot-method" {
  rest_api_id   = aws_api_gateway_rest_api.myapi.id
  resource_id   = aws_api_gateway_resource.myapiresource.id
  http_method   = "POST"
  authorization = "NONE"
}

#--------------------------------------------------------------------------------------------------
# creating a integration between api gateway and lambda function
#--------------------------------------------------------------------------------------------------

resource "aws_api_gateway_integration" "chatbot-integration" {
  rest_api_id             = aws_api_gateway_rest_api.myapi.id
  resource_id             = aws_api_gateway_resource.myapiresource.id
  http_method             = aws_api_gateway_method.chatbot-method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.first-lambda.invoke_arn
}

#--------------------------------------------------------------------------------------------------
# giving permission to api gateway to invoke the lambda function
#--------------------------------------------------------------------------------------------------

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.first-lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.myapi.execution_arn}/*/*"
}

#--------------------------------------------------------------------------------------------------
# creating a deployment and stage for the api gateway
#--------------------------------------------------------------------------------------------------

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.myapi.id
  depends_on  = [aws_api_gateway_integration.chatbot-integration]
}

resource "aws_api_gateway_stage" "dev_stage" {
  rest_api_id = aws_api_gateway_rest_api.myapi.id
  deployment_id = aws_api_gateway_deployment.deployment.id
  stage_name = "dev"
}

#--------------------------------------------------------------------------------------------------
# creating a s3 bucket
#--------------------------------------------------------------------------------------------------

resource "aws_s3_bucket" "s3-buck" {
  bucket = "my-tf-19-02"
}

resource "aws_s3_bucket_ownership_controls" "own" {
  bucket = aws_s3_bucket.s3-buck.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "pcb" {
  bucket = aws_s3_bucket.s3-buck.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "buck-acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.own,
    aws_s3_bucket_public_access_block.pcb,
  ]

  bucket = aws_s3_bucket.s3-buck.id
  acl    = "public-read"
}

#--------------------------------------------------------------------------------------------------
# creating a private s3 bucket for cloudfront
#--------------------------------------------------------------------------------------------------

resource "aws_s3_bucket" "s3-buck-private" {
  bucket = "my-private-tf-18-07"
}

resource "aws_s3_bucket_ownership_controls" "prv-own" {
  bucket = aws_s3_bucket.s3-buck-private.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "pcb-1" {
  bucket = aws_s3_bucket.s3-buck-private.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "buck-acl-1" {
  depends_on = [
    aws_s3_bucket_ownership_controls.prv-own,
    aws_s3_bucket_public_access_block.pcb-1,
  ]

  bucket = aws_s3_bucket.s3-buck-private.id
  acl    = "private"
}

#--------------------------------------------------------------------------------------------------
# creating a cloudfront distribution
#--------------------------------------------------------------------------------------------------
resource "aws_cloudfront_origin_access_control" "cloud-access" {
  name = "cloud-access-control"
  origin_access_control_origin_type = "s3"
  signing_behavior = "always"
  signing_protocol = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.s3-buck.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.cloud-access.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"

  logging_config {
    include_cookies = true
    bucket          = "my-private-tf-18-07"
    prefix          = "myprefix"
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}