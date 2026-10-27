variable "nome" {
  description = "Nome do serviço no Render (vira parte da URL: <nome>.onrender.com)."
  type        = string
}

variable "regiao" {
  description = "Região do Render (oregon, ohio, virginia, frankfurt, singapore)."
  type        = string
}

variable "repo_url" {
  description = "URL do repositório GitHub com o Dockerfile."
  type        = string
}

variable "branch" {
  description = "Branch que o Render observa para build e deploy."
  type        = string
  default     = "main"
}

variable "dockerfile_path" {
  description = "Caminho do Dockerfile dentro do repositório."
  type        = string
  default     = "./Dockerfile"
}

variable "health_check_path" {
  description = "Rota que o Render chama para saber se o serviço está saudável."
  type        = string
  default     = "/health"
}

variable "plano" {
  description = "Plano do serviço. O padrão é gratuito para não gerar cobrança por engano."
  type        = string
  default     = "free"

  validation {
    condition     = contains(["free", "starter", "standard", "pro"], var.plano)
    error_message = "Plano deve ser free, starter, standard ou pro."
  }
}

variable "env_vars" {
  description = "Variáveis de ambiente (não use para segredos versionados no Git)."
  type        = map(string)
  default     = {}
}

variable "auto_deploy" {
  description = "Se true, cada push na branch gera um deploy novo."
  type        = bool
  default     = true
}
