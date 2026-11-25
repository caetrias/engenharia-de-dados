# DECISOES.md — Exercício 06 (Aula 29) · grupo: 06

Cru carregado em 2026-11-25 (32 arquivos, com a madrugada de 2026-11-22 atrasada e o reenvio de
2026-11-20). O job da trusted gravou **518.400 linhas** (17.280 duplicatas removidas), e o da refined,
**660 linhas** (22 bairros × 30 dias, somando as 47.730 corridas da madrugada).

## DECISÃO 01 — o alcance da Prefeitura na refined (`escopo_prefeitura`)
Escolhemos **`tabela`**: a Prefeitura tem `SELECT` só na `madrugada_bairro`, e não no database inteiro
(diferente do Lab 07). Com essa escolha, se alguém criar amanhã uma tabela nova na refined, a
Prefeitura **não a vê** até alguém conceder de propósito. Aceitamos o custo de um grant a mais por
tabela publicada, em troca de nenhuma tabela com id chegar ao painel por descuido. Como a Prefeitura,
`SHOW TABLES` na refined lista só `madrugada_bairro`, e a madrugada dos últimos 7 dias
(`dt >= '2026-11-19'`) deu **11.137** corridas (998 bytes lidos). A trusted foi
**RECUSADA** (`Required Describe on eda_a29_grupo06_trusted`).

## DECISÃO 02 — as colunas que a analista não vê (`colunas_ocultas_analista`)
Escondemos **`passageiro_id` e `motorista_id`**: ela investiga a corrida, não a pessoa, e motorista
também é pessoa. A analista continua lendo **9 das 11** colunas (`corrida_id, bairro, inicio, fim,
distancia_km, duracao_min, valor, faixa_hora, chegada`). `SELECT passageiro_id` e `SELECT motorista_id`
como ela deram **RECUSADO** (`COLUMN_NOT_FOUND ... or requester is not authorized`), e
`count(bairro)` deu **518.400**. Deixamos `corrida_id` visível porque ela precisa dele para achar a
corrida reclamada e cruzar com o atendimento.

## DECISÃO 03 — o contrato da refined (`contrato_refined`)
A descrição (**183 caracteres** no catálogo) diz que a tabela traz *corridas e receita da madrugada
(faixa_hora 0 a 5) por bairro do Recife e por dia, para o painel da Secretaria de Mobilidade*. Quem só
ler o catálogo sabe o grão (bairro × dia), o que cada coluna mede (`receita` = soma de `valor` em R$,
com 2 casas), e sabe que a tabela **não tem id de corrida, motorista ou passageiro**. O dono é
**Engenharia de Dados — grupo06**. A tabela muda **diariamente**, pelo job `eda-a29-grupo06-refined`,
que reescreve só as pastas `dt=` recalculadas.

## Ajuste fora das marcas: a política `consumo`
Com o pacote como veio, toda consulta dos dois perfis falhava antes de começar (`Unable to
verify/create output bucket`, `INSUFFICIENT_PERMISSIONS`), e o `verifica.sh` dava **35/70**.
`iam simulate-principal-policy` mostrou `s3:GetBucketLocation` = `implicitDeny`: ela estava no mesmo
statement do `ListBucket`, sob a condição `s3:prefix`, que essa ação nunca carrega. Separamos o
`GetBucketLocation` em um statement próprio, sem condição. O `ListBucket` continua restrito a
`athena-results`, então o S3 direto nas camadas segue **RECUSADO** para a Prefeitura (critério 2).

---

Saída do `verifica.sh` (critérios automáticos 70/70):

```
OK     [0]  (elimina)  backend remoto s3, três databases (um por camada) e a refined em Parquet
PASSA  [1]  (20%)  a Prefeitura lê a refined: 11137 corridas na madrugada dos últimos 7 dias
PASSA  [2]  (25%)  a Prefeitura não lê a trusted, nem a raw, nem o S3 direto
PASSA  [3]  (15%)  a analista lê a trusted (518400 corridas) e não vê passageiro_id
PASSA  [4]  (10%)  o contrato da refined está no catálogo: descrição (183 caracteres), dono 'Engenharia de Dados — grupo06', comentário em toda coluna

Critérios automáticos: 70 / 70 pontos-percentuais

evidência: sufixo=grupo06 hoje=2026-11-25 prefeitura_refined=11137 prefeitura_trusted=RECUSADO prefeitura_raw=RECUSADO prefeitura_s3=RECUSADO analista_trusted=518400 analista_passageiro=RECUSADO {"colunas_ocultas_analista":["passageiro_id","motorista_id"],"escopo_prefeitura":"tabela"}
```

Depois do `terraform destroy` (`Destroy complete! Resources: 32 destroyed.`):

```
PASSA  [5]  (10%)  destroy limpo: nenhum recurso eda-a29-grupo06 sobrou
```
