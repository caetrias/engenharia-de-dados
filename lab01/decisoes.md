# Decisões — Exercício 01

## DECISÃO 01 — tipo de `valor`
Usei `double`: assim `sum(valor)` e `avg(valor)` funcionam direto em qualquer
consulta, sem exigir `CAST` de quem for usar a tabela depois. Aceito que os
1,5% dos eventos que chegam como `"17,82"` (vírgula decimal) não sejam
convertidos e virem `null` nessa coluna — prefiro perder esses valores a
empurrar a responsabilidade de converter texto para todo mundo que consultar
a tabela no futuro.

## DECISÃO 02 — tipo das colunas de tempo
[PENDENTE — rodar depois do deploy: `SELECT fim FROM corridas WHERE dt = '$DT' LIMIT 5;`
Se o valor voltar legível/correto, mantenha `timestamp` e escreva aqui o que
o SELECT devolveu. Se der erro de conversão, troque para `string` no
template.yaml, redeploy, e descreva o erro aqui.]

## DECISÃO 03 — `ignore.malformed.json`
Usei `true`: prefiro que uma linha malformada vire `null` silenciosamente a
que ela derrube a consulta inteira com `HIVE_BAD_DATA`. Quem paga por essa
escolha é a análise, que pode subestimar levemente a contagem de eventos sem
perceber — troco esse risco pela garantia de que o lake nunca fica
indisponível por causa de uma única linha ruim.

## DECISÃO 04 — quantas partições
Declarei as 3 mínimas exigidas pelo critério (as calculadas automaticamente
pelo deploy.sh: hoje, ontem e anteontem), garantindo que a de hoje sempre
está incluída. As outras 27 partições existem como dado no S3, mas não
existem para o Athena — uma consulta com `WHERE dt = '<data-não-declarada>'`
devolve zero linhas, não um erro. No dia 31 (em meses sem esse dia), essa
partição simplesmente não é criada pelo gerador nem declarada — não é bug, é
ausência esperada do calendário.

## DECISÃO 05 — teto de bytes por consulta
[PENDENTE — medir depois de carregar os dados:
`aws s3 ls "s3://$BUCKET/raw/corridas/" --recursive --summarize` (lake inteiro)
`aws s3 ls "s3://$BUCKET/raw/corridas/dt=$DT/" --recursive --summarize` (uma partição)
Escolha um valor entre os dois tamanhos medidos — não no piso (10.485.760) nem
no topo (117.655.605) do intervalo — e escreva aqui de qual medição ele saiu
e por que esse valor específico faz a consulta estreita passar e a larga
morrer.]
