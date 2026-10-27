# Módulo = receita reutilizável. Recebe variáveis, cria recursos e expõe outputs.
resource "render_web_service" "this" {
  name              = var.nome
  plan              = var.plano
  region            = var.regiao
  health_check_path = var.health_check_path

  runtime_source = {
    docker = {
      repo_url        = var.repo_url
      branch          = var.branch
      dockerfile_path = var.dockerfile_path
      auto_deploy     = var.auto_deploy
    }
  }

  # O provider espera um objeto por variável; aqui o módulo aceita um map(string) simples.
  env_vars = { for chave, valor in var.env_vars : chave => { value = valor } }
}
