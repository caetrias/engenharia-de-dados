# stack movida pra modules/lake, sem mudar nome/propriedade dos recursos
module "lake" {
  source     = "./modules/lake"
  sufixo     = var.sufixo
  teto_bytes = var.teto_bytes
}
