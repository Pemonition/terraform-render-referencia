# A chave e o workspace NÃO ficam no código: o provider lê as variáveis de ambiente
#   RENDER_API_KEY   -> Account Settings > API Keys no painel do Render
#   RENDER_OWNER_ID  -> ID do workspace (começa com "tea-" ou "usr-")
provider "render" {
  # Espera o deploy terminar no apply, para os outputs já apontarem para algo no ar.
  wait_for_deploy_completion = true
}
