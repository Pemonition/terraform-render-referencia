terraform {
  required_version = ">= 1.9"

  required_providers {
    render = {
      source  = "render-oss/render"
      version = "~> 1.9"
    }
  }

  # Estado local (terraform.tfstate) para estudo. Em equipe, use um backend remoto
  # (ex.: HCP Terraform gratuito) para o estado não ficar preso a um computador.
  # Veja "Estado remoto" no README.
}
