# Todo módulo declara seus providers. Sem isto o Terraform assume "hashicorp/render",
# que não existe, e o init falha com "Failed to query available provider packages".
terraform {
  required_providers {
    render = {
      source  = "render-oss/render"
      version = "~> 1.9"
    }
  }
}
