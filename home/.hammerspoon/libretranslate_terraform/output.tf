output "libretranslate_api_base_url" {
  value = local.libretranslate_api_url
}

output "translate_curl_example" {
  value = <<-CURL
  curl -X POST -H "Content-Type: application/json" --data '{"q":"it works","source":"auto","target":"de","format":"text"}' "${local.libretranslate_api_url}/translate"
CURL
}
