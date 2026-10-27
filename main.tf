# Um bloco "module" com for_each cria um serviço para cada item de var.servicos.
# Adicionar outro projeto = adicionar uma entrada no terraform.tfvars, sem copiar código.
module "servico" {
  source   = "./modules/servico-docker"
  for_each = var.servicos

  nome              = each.key
  regiao            = var.regiao
  repo_url          = each.value.repo_url
  branch            = each.value.branch
  dockerfile_path   = each.value.dockerfile_path
  health_check_path = each.value.health_check_path
  plano             = each.value.plano
  env_vars          = each.value.env_vars
}
