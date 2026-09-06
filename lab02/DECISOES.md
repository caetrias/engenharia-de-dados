# Decisões — Exercício 02

## DECISÃO 01 — tipo de `valor`
Usei `string`. Os 1,5% dos eventos com valor em formato `"17,82"` (vírgula decimal) não são perdidos nem viram null; em troca, toda consulta que precisar somar ou tirar média de `valor` exige `CAST` explícito.

## DECISÃO 02 — tipo das colunas de tempo
Testei `timestamp` primeiro. O Athena retornou `BAD_DATA` ao tentar parsear `"00:20:00"`, porque o campo tem só hora, sem data — não é um timestamp válido. Troquei para `string` nas colunas `data_corrida` e `fim`, na tabela e nas partições. Com `string`, o `SELECT` retorna os valores como texto, sem validação de formato — inclusive casos em que `fim` é numericamente menor que `data_corrida` (corrida cruzando a meia-noite), sem sinalização de virada de dia.

## DECISÃO 03 — `ignore.malformed.json`
Usei `false`. Uma linha de JSON malformada derruba a consulta inteira com `HIVE_BAD_DATA`, em vez de virar `null` silenciosamente. Quem consome a tabela sabe imediatamente que há dado corrompido, ao custo de a consulta falhar por completo até a linha ser corrigida ou removida.

## DECISÃO 04 — quantas partições
Registrei 5 partições (2026-09-02 a 2026-09-06, incluindo a de hoje). Com apenas 3 partições, o volume escaneado pela consulta larga (~10,18 MB) ficava abaixo do piso técnico do Athena (10.485.760 bytes), tornando impossível fixar um teto que barrasse a larga sem violar o mínimo permitido. Com 5 partições, o volume da larga sobe para ~16,96 MB, abrindo margem real para o teto. As partições não registradas continuam existindo como arquivo no S3, mas retornam zero linhas para qualquer consulta no Athena.

## DECISÃO 05 — teto de bytes por consulta
Medi a consulta larga (`SELECT count(*) FROM corridas`, 5 partições): 16.962.897 bytes escaneados. Medi a consulta estreita (`WHERE dt = '2026-09-06'`, 1 partição): 3.393.451 bytes escaneados. Fixei `teto_bytes = 12000000`, entre os dois valores e acima do piso de 10.485.760. Ao rodar a larga com esse teto, o Athena retorna status `CANCELLED` com o motivo `"Bytes scanned limit was exceeded"` — o freio é acionado, mesmo o status não sendo `FAILED`.
