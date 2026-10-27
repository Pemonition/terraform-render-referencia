output "id" {
  description = "ID do serviço no Render."
  value       = render_web_service.this.id
}

output "url" {
  description = "URL pública do serviço."
  value       = render_web_service.this.url
}
