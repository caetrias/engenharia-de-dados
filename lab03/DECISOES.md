# Decisões do Exercício 03

## DECISÃO 01: fronteira do módulo

Colocamos os seis recursos dentro de modules/lake/: os dois buckets, o bloqueio de acesso público, o banco e a tabela do Glue e o workgroup do Athena. Esses recursos fazem parte da mesma infraestrutura e são criados e removidos juntos. Na raiz ficaram as variáveis, o provider, o backend e os outputs, pois eles são configurações do projeto e não fazem parte diretamente dos recursos do lake.

## DECISÃO 02: movimentação do estado

Usamos o comando terraform state mv para mover cada recurso da raiz para o módulo. Escolhemos essa opção em vez de usar blocos moved {} porque o estado já existia localmente e precisávamos atualizar os endereços antes de migrá-lo para o backend S3.

Antes da movimentação, o plan mostrava 6 to add, 0 to change, 6 to destroy. Isso aconteceu porque o Terraform considerava os recursos antigos como removidos e os mesmos recursos dentro do módulo como novos. Depois dos seis comandos terraform state mv, o plan mostrou No changes. Assim, os recursos continuaram sendo os mesmos e nenhuma alteração foi feita na AWS.

## DECISÃO 03: workspace e pasta

Criamos o workspace dev para atender à separação de ambientes no Terraform. A infraestrutura que já estava criada continuou no workspace default. O workspace dev ficou vazio e poderá ser usado para um ambiente separado no futuro.

Não movemos a infraestrutura existente para dev porque cada workspace possui seu próprio estado. Se fizéssemos isso sem migrar o estado corretamente, o Terraform não encontraria os recursos existentes e tentaria criá-los novamente. A pasta organiza os arquivos do projeto, enquanto o workspace separa os estados das diferentes instâncias da infraestrutura.

## DECISÃO 04: o que o plan limpo mostra

O resultado No changes mostra que a configuração atual está de acordo com o estado armazenado no backend. No nosso caso, ele confirmou que a mudança para o módulo e a migração do estado não criaram, alteraram ou destruíram recursos.

Esse resultado não garante que não exista drift na infraestrutura. Por exemplo, uma alteração feita diretamente na AWS pode não estar representada no código. Portanto, o plan limpo confirma a situação encontrada pelo Terraform naquele momento, mas não substitui a verificação da infraestrutura e dos dados na AWS.

## DECISÃO 05: ordem das operações

A ordem foi importante porque o estado precisava ser movimentado antes de qualquer apply depois da criação do módulo. Se tivéssemos aplicado primeiro, o Terraform teria destruído os seis recursos que estavam na raiz e criado outros seis dentro do módulo, como mostrou o plan do passo 4 do enunciado.

Isso poderia apagar dados dos buckets, pois eles usam force_destroy = true, além de deixar os recursos indisponíveis durante a troca. Ao usar terraform state mv antes do apply, o Terraform passou a reconhecer os recursos existentes nos novos endereços e o plan ficou limpo.
