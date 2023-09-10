resource "aws_ecr_repository" "libretranslate" {
  name = "libretranslate"
  tags = {
    Name = "libretranslate"
  }

  provisioner "local-exec" {
    command = <<-EOC
      aws ecr get-login-password | docker login --username AWS --password-stdin ${aws_ecr_repository.libretranslate.repository_url} 
      docker pull libretranslate/libretranslate:latest
      docker tag libretranslate/libretranslate:latest ${aws_ecr_repository.libretranslate.repository_url}:latest
      docker push ${aws_ecr_repository.libretranslate.repository_url}:latest
    EOC
  }
}
