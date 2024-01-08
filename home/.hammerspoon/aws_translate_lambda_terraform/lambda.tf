#
# Lambda definition
#

locals {
  zip_path = data.archive_file.zip.output_path
}

data "archive_file" "zip" {
  type        = "zip"
  output_path = "${path.module}/index.zip"
  source_dir  = "${path.module}/lambda"
  excludes    = [".envrc", ".gitignore", ".npmrc", ".prettierignore", "node_modules/.bin"]
}

resource "aws_lambda_function" "fn" {
  filename         = local.zip_path
  source_code_hash = filebase64sha256(local.zip_path)
  description      = "Translates using AWS translate"
  function_name    = "Translate"
  role             = aws_iam_role.role.arn
  handler          = "index.translate"
  runtime          = "nodejs20.x"
  publish          = true
  timeout          = 10

  environment {
    variables = {
      DEFAULT_TARGET_LANGUAGE = var.default_target_language
    }
  }

  tags = {
    Name = "Translate"
  }
}

#
# Callable public HTTPS url
#
resource "aws_lambda_function_url" "fn" {
  function_name      = aws_lambda_function.fn.function_name
  authorization_type = "NONE"
}

# See https://docs.aws.amazon.com/lambda/latest/dg/urls-invocation.html
output "translate_public_function_url" {
  description = "Callable URL of the TRANSLATE lambda function"
  value       = aws_lambda_function_url.fn.function_url
}
