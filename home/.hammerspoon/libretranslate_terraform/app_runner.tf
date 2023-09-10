resource "random_uuid" "libretranslate_prefix" {}

resource "aws_apprunner_service" "libretranslate" {
  service_name = "libretranslate"

  source_configuration {
    image_repository {
      image_configuration {
        port                          = var.libretranslate_config.port
        runtime_environment_variables = local.environment_vars

      }

      image_identifier      = local.image_identifier
      image_repository_type = "ECR"
    }

    authentication_configuration {
      access_role_arn = aws_iam_role.libretranslate.arn
    }
    auto_deployments_enabled = true
  }


  instance_configuration {
    cpu = "1 vCPU"
  }

  network_configuration {
    ingress_configuration {
      is_publicly_accessible = true
    }
  }


  tags = {
    Name = "libretranslate"
  }
}
