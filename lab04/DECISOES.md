# DECISOES.md — Exercício 04 (Aula 21)

**DECISÃO 01 — chave de partição.** Escolhemos `["dt"]` porque a pergunta da madrugada
filtra só por data e agrega **todos** os 22 bairros, então pôr `bairro` na chave não
poda nenhuma pasta: só multiplica os arquivos de 7 para 154 (7 × 22, ~27 KB cada).
Com esta chave, a semana abre **7 arquivos** (7 das 30 pastas), que somam 4.231.809 bytes,
dos quais o Athena leu só 355.803 (8,4%), porque o Parquet lê apenas as 4 colunas da
pergunta.

**DECISÃO 02 — arquivos por pasta.** Escolhemos **1** arquivo por pasta. Cada arquivo ficou
com ~**605 KB** (média de 604.770 bytes nos 30 arquivos, 18.143.089 bytes no total), e a
pergunta lê **~14 KB de rodapés** (7 rodapés de 2.078 bytes = 14.546 bytes, medidos no
fim de cada arquivo). Com 4 por pasta seriam 28 rodapés e 28 pedidos ao S3, para
arquivos de ~150 KB, sem nenhum ganho de paralelismo neste volume.

**DECISÃO 03 — a meta de custo.** Declaramos **524.288 bytes (512 KiB)**. Ela saiu da
estimativa por metadados da Aula 21 para `dt` com 1 arquivo (0,37 MB), com ~40% de
folga para o que o Athena lê a mais (rodapés e estatísticas). A pergunta leu
**355.803 bytes** no Athena (68% da meta, 168.485 bytes de folga), com a resposta certa:
22 bairros e 11.137 corridas.

**DECISÃO 04 — o teto do workgroup.** Declaramos **10.485.760 bytes (10 MiB, o mínimo do
Athena)**. Ele deixa passar a pergunta da madrugada (355.803 bytes, ~29× abaixo do teto)
e barra a consulta das 8 colunas sobre a trusted inteira (18.143.089 bytes), que foi
`CANCELLED` com "Bytes scanned limit was exceeded" ao chegar a 10.485.760 bytes lidos.
O preço é que qualquer varredura ampla legítima (por exemplo, auditar os 30 dias com
todas as colunas) também cai neste workgroup e exige um workgroup separado. Além disso,
a consulta barrada ainda é cobrada pelos 10 MiB que leu antes de parar (~US$ 0,00005).

**DECISÃO 05 — o registro das partições.** Escolhemos **partition projection** (`dt` do tipo
date, `yyyy-MM-dd`, janela `NOW-45DAYS,NOW+1DAYS`). A janela é mais larga que os 30 dias
porque o gerador grava pela data local (-03) e o `NOW` do Athena é UTC: rodamos
este teste às 22h32 de 21/10 local, já 22/10 em UTC, e `NOW-29DAYS,NOW` deixaria
`dt=2026-09-22` invisível, e a contagem não fecharia 518.400. Aceitamos que uma pasta fora
da regra (com mais de 45 dias ou com nome fora do formato) fique invisível **sem erro**. No dia 31, a
pasta nova entra sozinha: basta o job gravar `dt=<hoje>`, sem `MSCK REPAIR TABLE` e sem
ninguém lembrar de registrar nada, e o `rodar-job.sh` confirmou "nada a registrar".

---

Saída do `verifica.sh` (critérios automáticos 70/70):

```
particao=dt  arquivos=30  meta=524288  lido_madrugada_7d=355803  teto=10485760  criterios_auto=70/70  data=2026-10-22T01:35:54Z
```
