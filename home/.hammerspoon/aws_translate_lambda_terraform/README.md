# AWS Translate via a public lambda function

Apply this to get a publically callable lambda function that translates text.



## Usage

After an apply you will fin the following in the terraform output: 

```ini
translate_public_function_url = "https://bdjvuj44jft7v4fgcx4uuoaana0epyed.lambda-url.eu-central-1.on.aws/"
```

You can then call this url like this:

```
curl https://bdjvuj44jft7v4fgcx4uuoaana0epyed.lambda-url.eu-central-1.on.aws/?sourceLanguage=es&targetLanguage=en&text=Este+es+un+texto+en+español
```



## Parameters:

`sourceLanguage`: source language if known, defaults to "auto" which tries to auto detect the used language.

`targetLanguage`: target language to translate into. If this is not set, defaults to `var.default_target_language` set in `variables.tf`

`text`: The text to translate (max 10kb)



## Response

http status code 200 with body:

```json
{
  "source":"es",
  "target":"en",
  "text":"This is a text in Spanish"
}
```

