output "urls" {
  description = "URL pública de cada serviço criado."
  value       = { for nome, servico in module.servico : nome => servico.url }
}

output "ids" {
  description = "ID de cada serviço no Render (útil para terraform import e para a API)."
  value       = { for nome, servico in module.servico : nome => servico.id }
}
