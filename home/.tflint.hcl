config {
  module = true
  deep_check = true
  force = false

  aws_credentials = {
    # access_key = "AWS_ACCESS_KEY"
    # secret_key = "AWS_SECRET_KEY"
    region     = "eu-central-1"
  }

  ignore_module = {
    # "github.com/wata727/example-module" = true
  }

  #varfile = [""]
  #variables = ["foo=bar", "bar=[\"baz\"]"]
}
