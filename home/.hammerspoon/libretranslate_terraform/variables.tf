variable "libretranslate_config" {
  type = object({
    port          = number
    languages     = list(string)
    enable_web_ui = bool
  })

  default = {
    port          = 5000
    languages     = ["en", "de", "es", "ru"]
    enable_web_ui = false
  }
}
