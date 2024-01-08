data "aws_caller_identity" "current" {}

resource "aws_iam_role" "role" {
  name = "Translate"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = ["lambda.amazonaws.com"]
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "execute" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "translate" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/TranslateReadOnly"
}

resource "aws_iam_policy" "allow_invocation" {
  name        = aws_lambda_function.fn.function_name
  path        = "/Translate/"
  description = "Allow invocation of ${aws_lambda_function.fn.function_name} function"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "Allow${aws_lambda_function.fn.function_name}Invocation"
      Effect   = "Allow"
      Action   = "lambda:InvokeFunction"
      Resource = [aws_lambda_function.fn.arn]
      },
      {
        Sid      = "FunctionURLAllowPublicAccess"
        Effect   = "Allow"
        Action   = "lambda:InvokeFunctionUrl"
        Resource = "arn:aws:lambda:eu-central-1:${data.aws_caller_identity.current.account_id}:function:${aws_lambda_function.fn.function_name}"
        Condition = {
          StringEquals = {
            "lambda:FunctionUrlAuthType" = "NONE"
          }
        }
      }
    ]
  })
}
