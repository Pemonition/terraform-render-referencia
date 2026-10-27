variable "regiao" {
  description = "Região do Render onde os serviços são criados."
  type        = string
  default     = "oregon"
}

variable "servicos" {
  description = "Serviços web Docker a criar. A chave do mapa vira o nome do serviço no Render."
  type = map(object({
    repo_url          = string
    branch            = optional(string, "main")
    dockerfile_path   = optional(string, "./Dockerfile")
    health_check_path = optional(string, "/health")
    plano             = optional(string, "free")
    env_vars          = optional(map(string), {})
  }))
}
