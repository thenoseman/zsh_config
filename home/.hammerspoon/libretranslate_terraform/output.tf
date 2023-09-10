output "libretranslate_api_base_url" {
  description = "The base URl for API operations"
  value       = local.libretranslate_api_url
}

output "libretranslate_api_swagger_docs_url" {
  description = "The base URl for API operations"
  value       = "${local.libretranslate_api_url}/docs"
}

output "translate_curl_example" {
  description = "An example curl command to test your libre translate instance"
  value       = <<-CURL
  curl -X POST -H "Content-Type: application/json" --data '{"q":"it works","source":"auto","target":"de","format":"text"}' ${local.libretranslate_api_url}/translate
CURL
}
