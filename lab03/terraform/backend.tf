# backend s3 (bucket/region/etc vêm do backend.hcl, não commitado)
terraform {
  backend "s3" {
    workspace_key_prefix = "eda-a12"
  }
}
