# DECISOES.md — Exercício 05 (Aula 25) · grupo: 06

Cru carregado em 2026-11-04: a madrugada de 2026-11-01 (1.591 corridas) chegou só em
`dt=2026-11-04`, e o arquivo de 2026-10-30 (17.280 corridas) chegou de novo em `dt=2026-10-31`.

## DECISÃO 01 — modo de escrita (`modo_escrita`)
Escolhemos **`sobrescrever`** (troca só as pastas `dt=` que o run escreve). Rodando o job duas
vezes (e uma terceira no `verifica.sh`), a tabela foi de **518.400 para 518.400** linhas, a
madrugada de **11.137 para 11.137**, e a trusted continuou com **30 arquivos** Parquet, um por dia.

## DECISÃO 02 — a chave da linha (`chave_dedup`)
Escolhemos **`corrida_id`**, mantendo a primeira chegada. Com o reenvio de 5 dias atrás, o job leu
535.680 linhas, removeu **17.280 duplicatas**, e a tabela ficou com **518.400 linhas para 518.400
corridas distintas**. Aceitamos descartar a cópia reenviada, mesmo que ela trouxesse correção.

## DECISÃO 03 — janela de atraso (`janela_atraso_dias`)
Escolhemos **3 dias**, o maior atraso presente no cru (madrugada de 2026-11-01 chegando em
2026-11-04). A madrugada dos últimos 7 dias deu **11.137** corridas, com `fora_da_janela = 0`.
Neste script, cada execução diária relê **os 30 dias de chegada** (32 arquivos, 535.680 linhas);
a janela só decide o que é aceito. Aceitamos que uma corrida com mais de 3 dias de atraso fique
fora da carga diária (contada em `fora_da_janela`) até um backfill.

## DECISÃO 04 — o backfill
Se uma corrida chegar com mais atraso do que a janela, o comando que conserta é
**`./rodar-job.sh DIAS=2026-11-01`**. Ele ignora a janela e reescreve **1 pasta** (`dt=2026-11-01`,
17.280 linhas, incluindo as 1.591 da madrugada atrasada). A tabela ficou com **518.400 linhas**
(518.400 distintas) e a madrugada continuou em 11.137. Ele não duplica porque o `sobrescrever`
troca só aquela pasta e a chave `corrida_id` deixa uma linha por corrida.

---

Saída do `verifica.sh` (critérios automáticos 70/70):

```
OK     [0]  (elimina)  backend remoto s3 e trusted em Parquet
PASSA  [1]  (20%)  a madrugada de 7 dias tem 11137 corridas, incluindo as atrasadas
PASSA  [2]  (25%)  rodar de novo não mudou nada: 518400 linhas e 11137 na madrugada, antes e depois
PASSA  [3]  (15%)  uma linha por corrida: 518400 linhas, 518400 corridas distintas
PASSA  [4]  (10%)  terraform plan limpo: o segundo apply não mudaria nada

Critérios automáticos: 70 / 70 pontos-percentuais

evidência: sufixo=grupo06 hoje=2026-11-04 madrugada_7d=11137->11137 linhas=518400->518400 distintas=518400 {"chave_dedup":"corrida_id","janela_atraso_dias":3,"modo_escrita":"sobrescrever"}
```

Depois do `terraform destroy` (`Destroy complete! Resources: 10 destroyed.`):

```
PASSA  [5]  (10%)  destroy limpo: nenhum recurso eda-a25-grupo06 sobrou
```
