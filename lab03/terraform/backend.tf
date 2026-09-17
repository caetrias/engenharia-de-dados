# Backend remoto — o estado passa a viver no S3 compartilhado da disciplina,
# com lock via DynamoDB (eda-tflock). Valores de bucket/region/etc vêm do
# backend.hcl (não commitado; veja backend.hcl.example).
terraform {
  backend "s3" {
    workspace_key_prefix = "eda-a12"
  }
}
