# Terraform + Render — repositório de referência

Infraestrutura como código (IaC) para publicar APIs em Docker no **Render (plano gratuito)** com **Terraform**.
O exemplo publica a API do [ScraperApi-melhorado](https://github.com/Pemonition/ScraperApi-melhorado)
como o serviço `scraperapi-terraform`.

```
terraform-render-referencia/
├── versions.tf          versão do Terraform e do provider (render-oss/render)
├── providers.tf         configuração do provider (chave vem do ambiente, nunca do código)
├── variables.tf         entradas: região e mapa de serviços
├── terraform.tfvars     valores desta conta (sem segredos)
├── main.tf              chama o módulo uma vez por serviço (for_each)
├── outputs.tf           URLs e IDs criados
├── .terraform.lock.hcl  versões exatas dos providers (vai para o Git)
├── modules/
│   └── servico-docker/  receita reutilizável: 1 serviço web Docker no Render
├── exemplos/
│   └── importar-servico-existente.tf.exemplo
└── .github/workflows/terraform.yml   CI: fmt + validate em todo push/PR
```

---

## 1. Conceitos em 1 minuto

| Termo | O que é |
|---|---|
| **Provider** | Plugin que sabe falar com uma API (Render, AWS, GitHub...). Aqui: `render-oss/render`. |
| **Resource** | Algo que existe na nuvem e o Terraform gerencia (`render_web_service`). |
| **Variable / Output** | Entrada e saída de uma configuração ou módulo. |
| **Module** | Pasta com `.tf` reutilizável. Recebe variáveis, cria recursos, devolve outputs. |
| **State** (`terraform.tfstate`) | O "mapa" do que o Terraform criou: liga cada resource ao ID real na nuvem. |
| **Plan** | A diferença entre o código e o mundo real: o que será criado, alterado ou destruído. |
| **Apply** | Executa o plan. |
| **Drift** | Alguém mudou algo no painel e o real ficou diferente do código; o próximo `plan` mostra. |

O Terraform é **declarativo**: você descreve o estado final desejado, e ele calcula os passos.

---

## 2. Pré-requisitos

- Terraform 1.9+ (`winget install --id Hashicorp.Terraform -e`)
- Conta no Render (entrar com o GitHub)
- **Chave de API do Render:** painel → *Account Settings* → *API Keys* → *Create API Key*
- **Owner ID do workspace:** painel → *Workspace Settings* (começa com `tea-` ou `usr-`)

---

## 3. Passo a passo (PowerShell)

```powershell
# 1) Credenciais SÓ nesta janela do terminal (não ficam em arquivo nem no histórico do Git)
$env:RENDER_API_KEY  = Read-Host "Chave de API do Render" -MaskInput
$env:RENDER_OWNER_ID = "tea-xxxxxxxxxxxxxxxxxxxx"

# 2) Baixa o provider e prepara a pasta .terraform
terraform init

# 3) Mostra o que vai acontecer — LEIA antes de aplicar
terraform plan

# 4) Cria/atualiza de verdade (pede "yes")
terraform apply

# 5) Consulta as saídas (URL do serviço)
terraform output urls
```

Depois de mudar qualquer `.tf` ou o `terraform.tfvars`: `terraform plan` e depois `terraform apply`. Para apagar tudo que este código criou: `terraform destroy` (mostra a lista e pede confirmação).

Comandos úteis:

| Comando | Para quê |
|---|---|
| `terraform fmt -recursive` | Formata os arquivos no padrão oficial |
| `terraform validate` | Confere sintaxe e tipos (sem chamar a nuvem) |
| `terraform state list` | Lista o que está no estado |
| `terraform plan '-out=plano.tfplan'` + `terraform apply plano.tfplan` | Aplica exatamente o plano revisado. No PowerShell 5.1 as aspas são obrigatórias: sem elas o argumento é partido no `.` e o Terraform responde "Too many command line arguments" |
| `terraform init -upgrade` | Atualiza o provider dentro da faixa de `versions.tf` |

---

## 4. Adicionar outro serviço

Basta uma entrada nova em `terraform.tfvars`, sem copiar código. O `for_each` do `main.tf` cria um módulo por item:

```hcl
servicos = {
  "scraperapi-terraform" = { repo_url = "https://github.com/Pemonition/ScraperApi-melhorado" }
  "apicripto-terraform"  = {
    repo_url = "https://github.com/Pemonition/ApiCripto"
    env_vars = { Sincronizacao__IntervaloMinutos = "15" }
  }
}
```

O `plan` vai mostrar `1 to add`. Remover a entrada e aplicar **destrói** aquele serviço.

---

## 5. Trazer um serviço que já existe (`import`)

Veja `exemplos/importar-servico-existente.tf.exemplo`. Resumo: um bloco `import { to = ..., id = "srv-..." }` + a configuração equivalente → `terraform plan` mostra "1 to import" → `apply`.

> Serviço criado por **Blueprint** (`render.yaml`) continua sincronizado pelo Blueprint.
> Cada recurso deve ter **um único dono**: ou Blueprint, ou Terraform.

---

## 6. Estado: o arquivo mais importante

- O `terraform.tfstate` é criado no primeiro `apply`. **Sem ele, o Terraform "esquece" o que criou** e tentaria criar de novo.
- Ele **não vai para o Git** (está no `.gitignore`): contém IDs e pode conter segredos, como senha de banco e valores de variáveis.
- **Estado remoto (recomendado em equipe):** o [HCP Terraform](https://app.terraform.io) tem plano gratuito. Crie uma organização e um workspace e adicione em `versions.tf`:

  ```hcl
  terraform {
    cloud {
      organization = "sua-org"
      workspaces { name = "render-referencia" }
    }
  }
  ```

  Depois rode `terraform login` e `terraform init` (ele oferece migrar o estado local).
  Alternativas: bucket S3/GCS/Azure Blob com trava de concorrência.

---

## 7. CI (GitHub Actions)

`.github/workflows/terraform.yml` roda em todo push/PR, **sem precisar de chave**:
`terraform fmt -check` → `terraform init -backend=false` → `terraform validate`.

Evolução natural: com estado remoto e a chave em *Settings → Secrets*, adicionar `terraform plan` comentando na PR e `apply` só ao fazer merge na `main`.

---

## 8. Cuidados

- **Segredos:** chave de API só em variável de ambiente (ou secret do CI). Nunca em `.tf`, `.tfvars` ou commit.
- **Custo:** o módulo usa `plano = "free"` por padrão e valida os valores aceitos. Mudar o plano no `.tfvars` **gera cobrança**: leia o `plan`.
- **`destroy` é definitivo:** o serviço e as configurações somem. Banco destruído perde os dados.
- **Lock file:** `.terraform.lock.hcl` vai para o Git, para todos usarem a mesma versão do provider.
- **Plano gratuito do Render:** o serviço dorme após ~15 min sem acesso (o primeiro acesso leva ~1 min); Postgres gratuito expira em 30 dias.

---

## 9. Blueprint (`render.yaml`) × Terraform

| | `render.yaml` | Terraform |
|---|---|---|
| Onde funciona | Só no Render | Qualquer nuvem/serviço com provider (AWS, Azure, GCP, Cloudflare, GitHub, Render...) |
| Prever mudanças | Não | `terraform plan` |
| Estado | Gerenciado pelo Render | Arquivo de estado (local ou remoto) |
| Reuso | Copiar o YAML | Módulos e `for_each` |
| Curva de aprendizado | Baixa | Média |
| Melhor para | Um app só no Render | Vários ambientes, várias nuvens, padronização |

**OpenTofu** é um fork aberto do Terraform (criado após a mudança para a licença BSL em 2023) e aceita esta mesma configuração com o comando `tofu`.
