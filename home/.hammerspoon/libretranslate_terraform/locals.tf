locals {
  repository_fqdn  = replace(aws_ecr_repository.libretranslate.repository_url, "///.*/", "")
  image_identifier = "${aws_ecr_repository.libretranslate.repository_url}:latest"
  lt_load_only     = { LT_LOAD_ONLY = join(",", var.libretranslate_config.languages) }

  environment_vars = merge({
    LT_UPDATE_MODELS  = "true"
    LT_HOST           = "0.0.0.0"
    LT_URL_PREFIX     = random_uuid.libretranslate_prefix.result
    LT_DISABLE_WEB_UI = var.libretranslate_config.enable_web_ui ? "false" : "true"
    LT_REQ_LIMIT      = "100"
    LT_PORT           = var.libretranslate_config.port
    LT_DISABLE_FILES_TRANSLATION = "true" },
  length(var.libretranslate_config.languages) > 0 ? { LT_LOAD_ONLY = join(",", var.libretranslate_config.languages) } : {})


  libretranslate_api_url = "https://${aws_apprunner_service.libretranslate.service_url}/${random_uuid.libretranslate_prefix.result}"
}
