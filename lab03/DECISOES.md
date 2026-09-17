# Decisões — Exercício 03 (Aula 12)

## DECISÃO 01 — a fronteira do módulo
Colocamos os seis recursos (buckets, bloqueio de acesso público, banco e tabela do Glue, workgroup do Athena) dentro de `modules/lake/`, porque eles formam uma unidade só: sempre sobem e caem juntos. Ficaram na raiz apenas as variáveis, o provider, o backend e os outputs — ou seja, tudo que é configuração do ambiente, não do lake propriamente dito.

## DECISÃO 02 — como movemos o estado sem recriar
Usamos `terraform state mv`, um comando por recurso, em vez de blocos `moved {}`. Antes disso, o `plan` mostrava `6 to add, 0 to change, 6 to destroy`, porque o Terraform via `aws_s3_bucket.lake` como removido e `module.lake.aws_s3_bucket.lake` como novo — mesmo sendo o mesmo bucket na AWS. Depois do `state mv`, o `plan` voltou a `No changes`. O que ficou claro pra gente: o Terraform não deduz sozinho que um recurso só mudou de endereço; é preciso avisar isso explicitamente, com `state mv` ou `moved{}`.

## DECISÃO 03 — workspace × pasta
Criamos o workspace `dev`, mas a stack que já estava no ar (aplicada no Passo 2 e depois refatorada) continuou no `default`. Migrar essa stack para `dev` mudaria o caminho do estado no S3 e teria o mesmo efeito do módulo: o Terraform trataria os recursos como novos e tentaria recriá-los. Como o exercício proíbe recriação, o workspace `dev` fica reservado pra um ambiente futuro, não pra "renomear" o que já existe.

## DECISÃO 04 — o que o plan limpo prova (e o que não prova)
O `No changes` prova que o código bate com o estado — a refatoração não mudou, destruiu ou criou nada na AWS. Não prova que não existe drift: se alguém alterar algo direto na Console AWS, sem passar pelo Terraform, o `plan` só vai notar dependendo do que foi mudado, e só na próxima vez que for rodado. O plan compara código × estado, não código × realidade.

## DECISÃO 05 — a ordem (por que state mv antes do apply)
Se tivéssemos aplicado o `apply` logo depois de mover o código pro módulo, sem antes fazer o `state mv`, o Terraform teria seguido o plano do Passo 4: destruir os 6 recursos originais e criar 6 novos iguais dentro do módulo. Isso apagaria qualquer dado gravado nos buckets (eles têm `force_destroy = true`) e deixaria a stack fora do ar durante a troca. Mover o estado primeiro evita isso: o Terraform reconhece os recursos no novo endereço e não precisa recriar nada.
