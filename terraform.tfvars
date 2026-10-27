# Valores desta conta. Não coloque segredos aqui: chaves vão em variáveis de ambiente.
regiao = "oregon"

servicos = {
  # Mesma API do repositório ScraperApi-melhorado, agora criada pelo Terraform.
  "scraperapi-terraform" = {
    repo_url = "https://github.com/Pemonition/ScraperApi-melhorado"
    env_vars = {
      Cache__Minutos  = "10"
      SCRAPER_PAGINAS = "1"
    }
  }

  # Para gerenciar outro projeto, descomente (nome precisa ser único no workspace):
  # "apicripto-terraform" = {
  #   repo_url = "https://github.com/Pemonition/ApiCripto"
  #   env_vars = { Sincronizacao__IntervaloMinutos = "15" }
  # }
}
