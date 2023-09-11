# Terraform setup for libre translate

These terraform script setup a [Libre Translate](https://github.com/LibreTranslate/LibreTranslate) instance on [AWS app runner](https://aws.amazon.com/de/apprunner/).

You will need a working **local** docker setup (docker cli) to make this work.

After a `terraform init` and `terraform apply` the output will contain the API URLs and an example curl command like this:

``` 
libretranslate_api_base_url = "https://p844faetrzq.eu-central-1.awsapprunner.com/19210de8-5478-e333-0431-bae364b29346"

libretranslate_api_swagger_docs_url = "https://p844faetrzq.eu-central-1.awsapprunner.com/19210de8-5478-e333-0431-bae364b29346/docs"

translate_curl_example = <<EOT
curl -X POST -H "Content-Type: application/json" --data '{"q":"it works","source":"auto","target":"de","format":"text"}' "https://p844faetrzq.eu-central-1.awsapprunner.com/19210de8-5478-e333-0431-bae364b29346/translate"

EOT
```

Notice there is no real access control (security groups etc.) available when using app runner so this uses the battle tested [security by obscurity](https://de.wikipedia.org/wiki/Security_through_obscurity) method.



# Invalid token error

When you get

```
An error occurred ... : The security token included in the request is invalid.
```

you can try to add MFA to your AWS account. 

At least that solved it for me...