# =============================================================================
# REFATORADO — a stack agora vive em modules/lake/. Aqui na raiz só chamamos
# o módulo, passando os mesmos parâmetros que antes iam direto nos recursos.
# Os seis recursos NÃO mudaram de nome nem de propriedade — só de endereço,
# movidos com `terraform state mv` (Passo 5 do enunciado).
# =============================================================================

module "lake" {
  source     = "./modules/lake"
  sufixo     = var.sufixo
  teto_bytes = var.teto_bytes
}
