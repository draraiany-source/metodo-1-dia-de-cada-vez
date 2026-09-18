# Auditoria de Imagens — Lili Fit

Data: 2026-09-17
Fonte de verdade: `assets/content/treinos_catalogo_oficial.json` (117 exercícios)
Capas: `assets/lily_exercicios/treino_001.jpg` … `treino_117.jpg`
Vínculo id → arte: `lib/core/lily/lily_exercicio_assets.dart`

Nenhum arquivo de imagem foi apagado, renomeado ou substituído. Correções seguras foram feitas apenas no **vínculo** (mapa `reatribuicoesAuditoria`) e em cadastro/configuração.

---

## Resumo

| Indicador | Valor |
|---|---|
| Total de exercícios | 117 |
| Total de imagens JPG em `lily_exercicios/` (capas) | 117 |
| Imagens distintas (hash MD5) | 101 |
| Imagens corretas após as reatribuições | 68 |
| Imagens incorretas / ainda incompatíveis | 27 |
| Imagens faltantes (arquivo físico) | 0 |
| Caminhos quebrados | 0 (o `pubspec.yaml` **não declarava** a pasta; isso foi corrigido) |
| Imagens duplicadas (mesmo bytes, nomes diferentes) | 11 grupos / 16 arquivos extras |
| Exercícios duplicados (mesmo nome / mesmo vídeo) | 3 grupos |
| Categorias incorretas | 1 corrigida (`treino_053`); 2 candidatas a arquivar (aguardando a responsável) |
| Assets não utilizados | 17 em `_incoming/` (candidatas, fora do bundle) + 18 JPGs órfãos após reatribuição |
| Itens para revisão manual | 12 |
| Imagens que precisam ser geradas | 28 |

Após as correções de código:

- A aluna vê **116** exercícios (`treino_053` arquivado como duplicata do `treino_113`).
- 12 artes atendem mais de um exercício visível (compartilhamento temporário até a arte própria existir).
- Cardio (Bike, Bike Horizontal, Caminhada, Esteira, Bike Spinning) está cadastrado, com imagem própria e hash exclusivo.

Inspeção visual (2026-09-17, segunda passagem nos inferiores e ombros) inverteu donos de arquivo que o relatório tinha marcado pelo nome do JPG, não pelo conteúdo:

| Arquivo | O que a arte realmente mostra | Dono correto | Quem espera arte nova |
|---|---|---|---|
| `treino_020.jpg` | Búlgaro no banco, **sem** halteres | `treino_116` | `treino_020` (agachamento com salto) |
| `treino_022.jpg` | Búlgaro no banco, **com** dois halteres | `treino_052` | `treino_022` (salto lateral no step) |
| `treino_027.jpg` | Goblet / agachamento taça | `treino_033` | `treino_027` (agachamento no TRX) |
| `treino_032.jpg` | Afundo no Smith (trilhos visíveis) | `treino_040` | `treino_032` (afundo com halteres no step) |
| `treino_040.jpg` | Afundo com halteres, perna traseira limpa | `treino_031` (e `treino_054` até ter recuo) | — |
| `treino_042.jpg` / `treino_052.jpg` | Sumô + elevação lateral | `treino_114` usa `042.jpg` | `treino_101` **não** usa mais `052.jpg` |

---

## Correções já aplicadas (código)

1. **`pubspec.yaml`** — declarada a pasta `assets/lily_exercicios/` (sem `_incoming/`). Sem isso as 117 capas não entram no build.
2. **`lily_exercicio_assets.dart`** — mapa `reatribuicoesAuditoria` (44 reatribuições reversíveis). `pathForId` consulta esse mapa antes do `byId` gerado. A inspeção visual removeu `treino_101 → treino_052.jpg` (sumô, não combinado de ombros) e passou `treino_031` para `treino_040.jpg` (afundo com halteres mais limpo).
3. **`treino_053`** — movido de Bíceps para Full Body / Funcional; grupo muscular "Corpo todo"; equipamento "Halteres". Status `incompleto_arquivado_duplicata_treino_113` (some da lista da aluna, o registro histórico permanece).
4. **`treino_113`** — confirmado como registro principal do "Afundo com Recuo e Rosca Direta".
5. **Testes** — `treino_catalog_validation_test.dart` atualizado para 116 visíveis; criado `test/lily_exercicio_assets_test.dart` (vínculo, caminhos, pubspec, artes compartilhadas conhecidas, arquivamento do 053).

**Não arquivados** (aguardando a responsável, decisão explícita desta sessão):

- `treino_068` — Full Body – Agachamento Sumô com Elevação Frontal (kettlebell)
- `treino_114` — Full Body – Agachamento Sumô com Elevação Lateral (halteres)
- `treino_069` — Agachamento com Desenvolvimento
- `treino_070` — Agachamento com Desenvolvimento Unilateral Alternado

---

## Correções confirmadas (prompt 88–115)

Mapeamento nome do prompt → ID do catálogo, status após a auditoria visual e as reatribuições.

### Costas

| Nº | Exercício | ID | Status | Observação |
|---|---|---|---|---|
| — | Puxada com Barra Longa | `treino_077` | OK (após swap) | Estava invertido com 080 (barra W). Agora usa `treino_080.jpg`. |
| — | Barra Fixa no Graviton | `treino_078` | OK | Graviton visível. |
| — | Puxada com Triângulo | `treino_079` | OK | Triângulo visível. |
| — | Puxada com Barra W | `treino_080` | OK (após swap) | Agora usa `treino_077.jpg`. |
| — | Face Pull | `treino_081` | OK | Polia + corda, em pé, puxada ao rosto. |
| — | Pulldown com Barra Reta | `treino_082` | TROCAR_IMAGEM | Continua sentada. **Precisa de arte nova: em pé, polia, barra reta.** |
| — | Puxada Alta com Corda | `treino_083` | TROCAR_IMAGEM | Continua parecendo pular corda. **Precisa de arte nova: polia alta + corda, composição semelhante ao Face Pull.** |
| — | Remada Sentada com Triângulo | `treino_084` | OK (após swap) | Agora usa `treino_094.jpg` (sentada com triângulo). |
| — | Remada Curvada com Barra | `treino_085` | OK | Curvada com barra, em pé. |
| — | Remada Articulada | `treino_117` | REVISAR_MANUALMENTE | Hash duplicado com `treino_093.jpg` (Remada Alta na Polia). Conferir se a máquina articulada aparece de fato. |

### Ombros

| Nº | Exercício | ID | Status | Observação |
|---|---|---|---|---|
| — | Remada Alta com Barra | `treino_094` | OK (após swap) | Agora usa `treino_084.jpg` (em pé com barra, cotovelos altos). |
| — | Remada Alta + Desenvolvimento com Barra | `treino_095` | TROCAR_IMAGEM | Hash duplicado com `treino_015.jpg`. Não mostra as duas fases. **Arte nova do combinado.** |
| — | Remada Alta na Polia | `treino_093` | TROCAR_IMAGEM | Hash duplicado com 117. Conferir polia. |
| — | Elevação Lateral no Banco | `treino_104` | TROCAR_IMAGEM | Hash compartilhado com 099/103/105. Banco não aparece. **Arte nova: sentada/apoiada no banco.** |
| — | Elevação Lateral com Halteres | `treino_106` | OK temporário | Agora usa `treino_102.jpg` (elevação lateral real). `treino_102` (Elevação Frontal com Halteres) ficou compartilhando essa arte — **gerar arte própria da frontal.** |
| — | Elevação Lateral + Desenvolvimento com Cotovelos | `treino_101` | TROCAR_IMAGEM | Voltou ao `treino_101.jpg` (infra na paralela, dono correto é o 014). **Não usar 052.jpg** (é sumô + elevação). **Arte nova do combinado.** |
| — | Elevação Lateral na Polia | `treino_103` | TROCAR_IMAGEM | Hash compartilhado; polia/cabo não aparece. **Arte nova com polia.** |
| — | Desenvolvimento na Máquina | `treino_098` | REVISAR_MANUALMENTE | Hash duplicado com `treino_096.jpg`. Conferir se a máquina (encosto) aparece. |
| — | Elevação Frontal na Polia com Barra Reta | `treino_099` | OK temporário | Agora usa `treino_100.jpg` (polia + barra). `treino_100` ficou compartilhando. **Gerar arte própria de 100.** |
| — | Desenvolvimento com Halteres | `treino_096` | OK | Usa `treino_095.jpg` (press com halteres, confirmado). **Gerar arte própria só do 095** (combinado remada alta + desenvolvimento). |
| — | Desenvolvimento Arnold em Pé | `treino_097` | REVISAR_MANUALMENTE | Hash duplicado com `treino_070.jpg`. Confirmar que está EM PÉ e com a rotação do Arnold Press. |

### Full Body — remoções pedidas

| Nome no prompt | IDs encontrados | Ação |
|---|---|---|
| Agachamento Sumô + Elevação | `treino_068` (frontal, kettlebell) e `treino_114` (lateral, halteres) | **Não arquivados.** A responsável precisa escolher qual(is). |
| Agachamento + Desenvolvimento | `treino_069` e `treino_070` (unilateral alternado) | **Não arquivados.** Idem. |

### Bíceps

| Nº | Exercício | ID | Status | Observação |
|---|---|---|---|---|
| — | Afundo com Recuo e Rosca Direta | `treino_053` | CATEGORIA corrigida + EXERCICIO_DUPLICADO arquivado | Movido para Full Body; imagem agora é `treino_113.jpg`. Registro arquivado; **113 é o principal.** |
| — | Rosca Direta na Polia Baixa com Barra Reta | `treino_086` | OK (após swap) | Agora usa `treino_089.jpg` (polia baixa + barra). Não é mais Rosca Scott. |
| — | Rosca Direta com Halteres | `treino_087` | TROCAR_IMAGEM | Temporariamente usa `treino_106.jpg` (rosca alternada). **Arte própria: dois halteres, simultânea.** |
| — | Bíceps Alternado / Unilateral | `treino_088` | TROCAR_IMAGEM | Mesma arte temporária (`treino_106.jpg`). **Arte própria: um braço de cada vez.** |
| — | Rosca Direta na Máquina | `treino_089` | OK (após swap) | Agora usa `treino_086.jpg` (máquina de rosca). |
| — | Rosca Direta Alternada com Rotação de Cotovelos | `treino_090` | TROCAR_IMAGEM | Mesma arte temporária. **Arte própria com a rotação visível.** |
| — | Rosca Martelo com Corda | `treino_091` | OK | Polia + corda + pegada neutra. |
| — | Rosca Unilateral na Polia Baixa | `treino_092` | OK (após swap) | Agora usa `treino_087.jpg` (unilateral na polia). |

### Tríceps

| Nº | Exercício | ID | Status | Observação |
|---|---|---|---|---|
| — | Tríceps com Corda | `treino_107` | REVISAR_MANUALMENTE | Hash compartilhado com 110/111/112. Conferir se é pushdown com corda. |
| — | Tríceps Francês com Corda | `treino_108`, `treino_110`, `treino_112` | EXERCICIO_DUPLICADO | **Três registros com o mesmo nome.** Decidir com a responsável qual manter. 110 e 112 compartilham hash com 107/111. |
| — | Tríceps Paralelo | `treino_109` | TROCAR_IMAGEM | **Precisa de arte de mergulho/paralela.** Não aceitar tríceps na polia. |
| — | Tríceps Testa na Polia | `treino_111` | TROCAR_IMAGEM | Hash compartilhado. **Arte nova: testa com polia/cabo.** |

### Alongamento e mobilidade

| Nº | Exercício | ID | Status | Observação |
|---|---|---|---|---|
| — | Alongamento de Superiores no Espaldar | `treino_016` | OK (após swap) | Estava invertido com 018. Agora usa `treino_018.jpg` (braços/ombros/escapular). |
| — | Alongamento de Membros Inferiores no Espaldar | `treino_018` | OK (após swap) | Agora usa `treino_016.jpg`. |

---

## Imagens faltantes

Nenhum exercício está sem **arquivo físico**. O que falta é **arte que realmente representa o movimento**. Esses casos estão na seção [IMAGENS QUE PRECISAM SER GERADAS](#imagens-que-precisam-ser-geradas).

| Nº | Exercício | Categoria | Imagem esperada | Situação |
|---|---|---|---|---|
| 082 | Pulldown com Barra Reta | Costas | Em pé, polia, barra reta | Arquivo existe, execução sentada |
| 083 | Puxada Alta com Corda | Costas | Polia alta + corda | Arquivo existe, parece pular corda |
| 013 | Abdominal na Máquina | Core | Máquina de abdominal | Usa abdominal de solo (014) temporariamente |
| 048 | Glúteo 4 Apoios Perna Estendida | Inferiores | 4 apoios, perna estendida, caneleira | Compartilha 055 |
| 069 | Agachamento com Desenvolvimento | Full Body | Combinado agachamento + press | Compartilha agachamento livre (037) |
| 087 | Rosca Direta com Halteres | Bíceps | Dois halteres simultâneos | Compartilha 106 |
| 088 | Bíceps Alternado / Unilateral | Bíceps | Um braço de cada vez | Compartilha 106 |
| 090 | Rosca Alternada com Rotação | Bíceps | Rotação de punho visível | Compartilha 106 |
| 095 | Remada Alta + Desenvolvimento | Ombros | Duas fases do combinado | Hash duplicado com 015 |
| 101 | Elevação Lateral + Desenvolvimento | Ombros | Combinado | Usa `treino_101.jpg` (infra na paralela, dono do 014). **Não** usa mais 052. |
| 020 | Agachamento com Salto | Cardio | Salto (plyo squat) | Arquivo 020 é búlgaro sem peso — dono do 116 |
| 022 | Agachamento com Salto Lateral no Step | Cardio | Salto lateral no step | Arquivo 022 é búlgaro com halteres — dono do 052 |
| 027 | Agachamento no TRX | Inferiores | TRX visível | Arquivo 027 é goblet — dono do 033 |
| 032 | Afundo com Halteres no Step | Inferiores | Halteres + step | Arquivo 032 é afundo no Smith — dono do 040 |
| 103 | Elevação Lateral na Polia | Ombros | Polia/cabo visível | Hash compartilhado |
| 104 | Elevação Lateral no Banco | Ombros | Banco visível | Hash compartilhado |
| 109 | Tríceps Paralelo | Tríceps | Mergulho nas paralelas | Arte incompatível |

---

## Imagens incorretas

Reatribuições **já aplicadas** (o exercício agora aponta para outro arquivo existente). Os que ainda precisam de arte nova estão marcados como pendentes.

| Nº | Exercício | Imagem atual (após correção) | Problema original | Correção |
|---|---|---|---|---|
| 013 | Abdominal na Máquina | `treino_014.jpg` | Arquivo 013 era cadeira abdutora | Abdutora foi para 046; 013 usa abdominal temporário |
| 014 | Abdominal Infra na Paralela | `treino_101.jpg` | Arquivo 014 era abdominal de solo | 101 mostrava elevação de pernas na paralela |
| 016 | Along. Superiores Espaldar | `treino_018.jpg` | Invertido com 018 | Swap 016 ↔ 018 |
| 017 | Aquecimento Inferiores | `treino_060.jpg` | Hash duplicado com 116 | Reatribuído |
| 018 | Along. Inferiores Espaldar | `treino_016.jpg` | Invertido com 016 | Swap |
| 026 | Aquecimento Agach. + Recuo + Avanço | `treino_044.jpg` | Arte cruzada | Reatribuído |
| 029 | Afundo no Step sem Peso | `treino_031.jpg` | Invertido com 031 | 031.jpg é o step sem peso (confirmado visualmente) |
| 030 | Agachamento no Banco | `treino_033.jpg` | Arte cruzada | 033.jpg é box squat (confirmado) |
| 031 | Afundo com Halteres | `treino_040.jpg` | 029.jpg tinha a perna de trás deformada | 040.jpg é o afundo com halteres mais limpo; compartilha com 054 |
| 033 | Agachamento Taça | `treino_027.jpg` | Relatório antigo achava que 027 era TRX | 027.jpg é goblet (confirmado). 027 (TRX) espera arte nova |
| 038 | Agachamento Smith | `treino_039.jpg` | Profundidade invertida com 039 | Swap 038 ↔ 039 |
| 039 | Agachamento Smith Profundo | `treino_038.jpg` | Idem | Swap |
| 040 | Afundo no Smith | `treino_032.jpg` | Relatório antigo achava que 032 era step | 032.jpg é Smith (trilhos visíveis). 032 (halteres no step) espera arte |
| 042 | Agachamento Livre com Halteres | `treino_030.jpg` | Arte cruzada | 030.jpg é agachamento com dois halteres, sem banco |
| 044 | Agachamento Pêndulo | `treino_069.jpg` | Máquina pêndulo estava no 069 | Reatribuído |
| 046 | Cadeira Abdutora | `treino_013.jpg` | Arquivo 046 era outro | Abdutora estava no 013 |
| 047 | Stiff Unilateral | `treino_088.jpg` | Hash duplicado com 065 (stiff bilateral) | Stiff unilateral estava no 088 |
| 048 | Glúteo 4 Apoios Perna Estendida | `treino_055.jpg` | Hash duplicado com 051 | Temporário |
| 049 | Glúteo 4 Apoios com Caneleira | `treino_055.jpg` | Cabo no arquivo 049 | 049 (cabo) foi para 055; 049 e 048 compartilham 055 |
| 052 | Agachamento Búlgaro com Halteres | `treino_022.jpg` | Relatório antigo achava que 022 era salto | 022.jpg é búlgaro com dois halteres (confirmado). 022 (salto) espera arte |
| 053 | Afundo Recuo + Rosca | `treino_113.jpg` | Arte de rosca Scott / hash compartilhado | Combinado correto; registro arquivado |
| 054 | Afundo com Recuo e Halteres | `treino_040.jpg` | Arte cruzada | Aproxima afundo com halteres; compartilha com 031 até ter arte de recuo |
| 055 | Coice no Cabo | `treino_049.jpg` | 4 apoios no arquivo 055 | Cabo estava no 049 |
| 060 | Búlgaro no Smith | `treino_026.jpg` | Arte cruzada | Reatribuído |
| 069 | Agachamento + Desenvolvimento | `treino_037.jpg` | Máquina pêndulo no 069 | Temporário (agachamento livre) |
| 072 | Supino Máquina Articulada | `treino_075.jpg` | Invertido com 075 | Swap 072 ↔ 075 |
| 073 | Supino Inclinado Pegada Neutra | `treino_074.jpg` | Invertido com 074 | Swap 073 ↔ 074 |
| 074 | Supino Inclinado Pegada Supinada | `treino_073.jpg` | Invertido | Swap |
| 075 | Supino Halteres Inclinado | `treino_072.jpg` | Invertido com 072 | Swap |
| 077 | Puxada Barra Longa | `treino_080.jpg` | Invertido com 080 | Swap 077 ↔ 080 |
| 080 | Puxada Barra W | `treino_077.jpg` | Invertido | Swap |
| 084 | Remada Sentada Triângulo | `treino_094.jpg` | Em pé com barra | Swap 084 ↔ 094 |
| 086 | Rosca Polia Baixa Barra Reta | `treino_089.jpg` | Rosca Scott | Swap 086 ↔ 089 |
| 087/088/090 | Roscas com halteres | `treino_106.jpg` | Polia / execução errada | Temporário |
| 089 | Rosca na Máquina | `treino_086.jpg` | Polia no lugar da máquina | Swap |
| 092 | Rosca Unilateral Polia | `treino_087.jpg` | Execução bilateral | Unilateral estava no 087 |
| 094 | Remada Alta com Barra | `treino_084.jpg` | Sentada com triângulo | Swap |
| 096 | Desenvolvimento com Halteres | `treino_095.jpg` | Hash duplicado com 098 | 095.jpg é press com halteres (confirmado). 096 OK; 095 espera arte do combinado |
| 099 | Elevação Frontal Polia | `treino_100.jpg` | Hash compartilhado | Temporário |
| 101 | Elev. Lateral + Desenv. | `treino_101.jpg` | Combinado ainda não existe | **Não** usa mais 052.jpg (sumô). 101.jpg ficou com o 014 (paralela). Espera arte nova |
| 106 | Elevação Lateral Halteres | `treino_102.jpg` | Arte cruzada | Lateral real estava no 102 |
| 114 | Sumô + Elevação Lateral | `treino_042.jpg` | Arte cruzada | 042.jpg **é** sumô + elevação (confirmado). Candidato a sair do Full Body |
| 116 | Búlgaro sem Peso | `treino_020.jpg` | Hash duplicado com 017 | 020.jpg **é** búlgaro sem peso (confirmado). 020 (salto) espera arte |

---

## Duplicidades

### Exercícios (cadastro)

| Exercício | ID 1 | ID 2 (e 3) | Recomendação |
|---|---|---|---|
| Afundo com Recuo e Rosca Direta | `treino_053` (arquivado) | `treino_113` (principal) | **Resolvido nesta auditoria.** 113 permanece; 053 arquivado. |
| Tríceps Francês com Corda | `treino_108` | `treino_110`, `treino_112` | Manter um só. 108 tem hash próprio; 110 e 112 compartilham hash com 107/111. Sugerido: manter 108, arquivar 110 e 112 após conferir o vídeo. |
| Agachamento Sumô + Elevação | `treino_068` | `treino_114` | Não são o mesmo movimento (frontal × lateral; kettlebell × halteres). A responsável pediu remover "Agachamento Sumô + Elevação" do Full Body — **escolher um, ambos, ou nenhum.** |
| Agachamento + Desenvolvimento | `treino_069` | `treino_070` | 070 é a variação unilateral. Idem: aguardando a responsável. |

### Imagens (mesmo MD5, nomes diferentes)

| Hash (prefixo) | Arquivos | Exercícios envolvidos | Ação |
|---|---|---|---|
| `afc0aaa6…` | 015, 095 | Mobilidade de Ombros / Remada Alta + Desenv. | 095 precisa de arte nova |
| `493553fa…` | 017, 116 | Aquecimento / Búlgaro sem peso | 017 reatribuído; 116 usa `treino_020.jpg` (búlgaro real). Arquivo 116.jpg órfão |
| `3f1305d6…` | 046, 050 | Abdutora / Abdução com caneleira | 046 reatribuído para 013; 050 permanece |
| `fb57db7d…` | 047, 065 | Stiff Unilateral / Stiff | 047 reatribuído para 088 |
| `e49b8a3f…` | 048, 051 | 4 apoios perna estendida / Coice em pé | 048 reatribuído para 055 |
| `3b63ea70…` | 053, 089, 090, 092 | Afundo+rosca / 3 roscas | Todos reatribuídos |
| `c3425aee…` | 070, 097 | Agach. + desenv. unilateral / Arnold | Revisar 097 |
| `ff52e364…` | 093, 117 | Remada Alta Polia / Remada Articulada | Revisar os dois |
| `55e45626…` | 096, 098 | Desenv. halteres / Desenv. máquina | 096 reatribuído; revisar 098 |
| `a23ba3ae…` | 099, 103, 104, 105 | 4 exercícios de ombro/peitoral | 099 reatribuído; 103/104/105 precisam de arte |
| `acdf813e…` | 107, 110, 111, 112 | 4 tríceps | Revisar 107; gerar artes para 109/111; arquivar duplicatas 110/112 |

---

## Assets sem uso

### Pasta `_incoming/` (17 arquivos — candidatas não aprovadas, fora do bundle)

Declaradamente excluídas do `pubspec.yaml`. Não apagar.

- `01_desenvolvimento_halteres.jpg`
- `02_supino_maquina_peitoral.jpg`
- `03_puxada_alta_barra.jpg`
- `04_remada_articulada.jpg`
- `05_remada_sentada_triangulo.jpg`
- `06_remada_curvada_barra.jpg`
- `07_remada_alta_barra.jpg`
- `08_prancha_alta.jpg`
- `09_prancha_antebraco_tapete.jpg`
- `10_prancha_antebraco_gym.jpg`
- `11_supino_maquina_variante.jpg`
- `12_elevacao_pelvica_banco.jpg`
- `13_triceps_corda_overhead.jpg`
- `14_supino_maquina_peito.jpg`
- `15_leg_press.jpg`
- `16_bike_horizontal.jpg`
- `17_bike_horizontal_academia.jpg`

Antes de gerar arte nova, **revisar essas 17** — várias coincidem com itens pendentes (desenvolvimento com halteres, remada articulada, remada sentada, remada alta, tríceps overhead, bikes).

### JPGs em `lily_exercicios/` que deixaram de ser o vínculo principal

Nenhum foi apagado. Continuam no disco porque outro exercício pode voltar a usá-los se uma reatribuição for revertida. Os hashes duplicados listados acima são o conjunto "arquivo extra".

Pasta `assets/lily_treinos/` (pack genérico de 24) continua em uso como **fallback** em `lilyTreinoAssetFor` quando o id não resolve — não é lixo.

---

## Problemas de caminho

| Caminho configurado | Caminho real | Situação |
|---|---|---|
| `assets/lily_exercicios/treino_XXX.jpg` | `assets/lily_exercicios/treino_XXX.jpg` | Os 117 arquivos existem. **Corrigido:** a pasta agora está no `pubspec.yaml`. |
| (antes) pasta não declarada | 117 JPGs no disco | Caminho "quebrado" no **build**, não no disco. Sem a declaração o Flutter não empacota. |
| `_incoming/` | `assets/lily_exercicios/_incoming/` | propositalmente **fora** do pubspec |

Nenhum `Image.asset` / `AssetImage` aponta para um arquivo inexistente nas capas do catálogo. O mapa `byId` cobre `treino_001`…`treino_117`.

---

## Cardio (busca especial)

| ID | Nome | Arquivo | Hash exclusivo | Cadastrado | No build |
|---|---|---|---|---|---|
| `treino_001` | Bike – Queima Gordura | `treino_001.jpg` | sim | sim | sim (após pubspec) |
| `treino_002` | Bike Horizontal – Queima Gordura | `treino_002.jpg` | sim | sim | sim |
| `treino_003` | Caminhada – Queima Gordura | `treino_003.jpg` | sim | sim | sim |
| `treino_004` | Esteira – Caminhada/Corrida | `treino_004.jpg` | sim | sim | sim |
| `treino_005` | Bike Spinning – Queima Gordura | `treino_005.jpg` | sim | sim | sim |

`treino_002` e `treino_003` têm status `revisar_link_duplicado_*` (mesmo vídeo cruzado no cadastro) — isso é problema de **link do YouTube**, não de imagem. As capas são distintas.

---

## Itens que precisam de revisão humana

Só o que não deu para validar com segurança:

1. **`treino_068` / `treino_114` / `treino_069` / `treino_070`** — a responsável pediu remover "Agachamento Sumô + Elevação" e "Agachamento + Desenvolvimento" do Full Body. Há dois IDs em cada família. Não arquivar sem escolha explícita.
2. **`treino_108` / `treino_110` / `treino_112`** — três "Tríceps Francês com Corda". Qual o principal?
3. **`treino_097`** — Desenvolvimento Arnold em Pé: hash igual ao 070. Confirmar posição em pé e a rotação.
4. **`treino_098`** — Desenvolvimento na Máquina: hash igual ao 096 (antes da reatribuição). Confirmar encosto/máquina.
5. **`treino_117` vs `treino_093`** — mesmo hash. Um deveria ser articulada, o outro polia.
6. **`treino_107`** — Tríceps com Corda: hash compartilhado com 3 franceses. Confirmar pushdown.
7. **`treino_015` vs `treino_095`** — mesmo hash. 015 (Mobilidade de Ombros) ficou com o arquivo; 095 precisa de arte nova. Confirmar se 015 é realmente mobilidade de ombros.
8. **Pasta `_incoming/`** — 17 artes candidatas. Podem cobrir vários itens "gerar nova" sem gerar nada.
9. **`treino_100` e `treino_102`** — categorias cadastradas como Peitoral (Elevação Frontal). Não alterei o nome. Confirmar se a seção visual correta é Ombros.
10. **`treino_002` / `treino_003`** — links do YouTube cruzados (status já marcado no catálogo).
11. **`treino_056`** — Glúteo na Polia com Cabo no Quadríceps, status `revisar`.
12. **Padronização visual pontual** — a biblioteca é coerente (personagem feminina, 1254×1254, fundo limpo), mas alguns combinados não mostram as duas fases e alguns equipamentos somem no enquadramento.

---

## Padronização visual Lili Fit

Avaliação da biblioteca como um todo (não de cada arquivo):

| Critério | Situação |
|---|---|
| Profissional / alta resolução | Sim — 1254×1254, JPG, ~250–380 KB |
| Personagem feminina fitness | Sim, identidade estável |
| Execução biomecanicamente compreensível | Na maioria; falha nos combinados (duas fases) e quando o equipamento some |
| Enquadramento / corpo visível | Sim na maior parte |
| Equipamento visível quando importa | Falha justamente nos itens TROCAR_IMAGEM (polia, banco, paralela, máquina) |
| Fundo limpo, sem texto aleatório, sem marca de terceiro | Sim |
| Sem corte / deformação / membro duplicado | Não vi deformação grave na inspeção; combinados e hashes duplicados são o problema real |
| Identidade visual coerente | Sim entre os 117 |

Nenhum arquivo corrompido. Nenhum nome com caractere problemático (`treino_NNN.jpg`). Extensão consistente (`.jpg`). Resolução abaixo de 800 px: nenhuma nas capas oficiais.

---

## Validação de assets (técnico)

- **Formatos incompatíveis:** não encontrados nas capas.
- **Corrompidos:** 0 (Pillow abriu os 117).
- **Referências no código que não existem:** 0 para `treino_001`…`treino_117`.
- **JSON local:** `assets/content/treinos_catalogo_oficial.json` — 117 ids.
- **Firebase / Storage / SQLite / Hive / API seed:** o catálogo da aluna é local-first (JSON). Imagens não vêm do Storage.
- **Dart contendo catálogo:** o vínculo de capa é só `LilyExercicioAssets`; a UI resolve em `lilyTreinoAssetFor` (`treino_catalog_visual.dart`).

---

## IMAGENS QUE PRECISAM SER GERADAS

Não inventar arte. Cada item abaixo precisa de geração no padrão Lili Fit (personagem feminina, 1:1, 1254×1254, fundo de academia limpo, sem texto, sem marca, equipamento visível, corpo inteiro ou 3/4).

Antes de gerar, conferir `_incoming/` — pode já existir candidata.

### Prompt-base (reutilizar, trocando só o movimento)

```
Professional fitness illustration, square 1:1, 1254x1254. Athletic Brazilian woman in her 30s, defined but feminine physique, dark hair in a high ponytail, matching premium gym set in black with lilac/pink accents, clean modern gym background, soft neon magenta and purple lighting, no text, no logos, no extra limbs, anatomically correct, full body or 3/4 framing, equipment clearly visible, biomechanically accurate.
```

| Nº | Nome | Categoria | Execução | Equipamento | Inicial | Final | Enquadramento | Prompt específico |
|---|---|---|---|---|---|---|---|---|
| 013 | Abdominal na Máquina | Core | Flexão de tronco sentada na máquina, pegando as alças, levando o peito em direção às coxas | Máquina de abdominal (encosto + alças na altura do ombro) | Sentada, tronco ereto, mãos nas alças | Tronco fletido, cotovelos apontando para as coxas | 3/4 frontal mostrando encosto e alças | `... seated on an abdominal crunch machine, holding the upper handles, torso crunching forward toward the thighs, machine clearly visible.` |
| 048 | Glúteo 4 Apoios Perna Estendida | Inferiores | Quadrúpede, uma perna estendida para trás e para cima (não só o joelho fletido) | Caneleira | 4 apoios, joelho no chão | Perna de trabalho estendida atrás, glúteo contraído | Lateral, mostrando as duas pernas | `... on all fours, one leg fully extended straight back and slightly up, ankle weight visible, other knee on the mat.` |
| 069 | Agachamento com Desenvolvimento | Full Body | Combinado: agacha com halteres nos ombros e, na subida, desenvolve acima da cabeça | Halteres | Agachamento, halteres na altura dos ombros | Em pé, braços estendidos acima da cabeça | Corpo inteiro, de 3/4 | `... holding dumbbells, shown at the top of a squat-to-press: standing tall, arms extended overhead, after rising from a squat. Optionally a subtle ghosted squat phase.` |
| 082 | Pulldown com Barra Reta | Costas | **EM PÉ**, cotovelos estendendo a barra reta da polia alta em direção às coxas (stiff-arm pulldown) | Polia alta + barra reta | Em pé, leve inclinação, barra à frente na altura do peito | Barra próxima às coxas, braços estendidos | Corpo inteiro de lado/3/4, cabo visível | `... STANDING (not seated) at a high cable pulley, holding a straight bar, performing a stiff-arm pulldown, bar traveling toward the thighs, cable clearly visible.` |
| 083 | Puxada Alta com Corda | Costas | Em pé de frente para a polia alta, puxando a **corda** em direção ao peito/rosto (não é pular corda) | Polia alta + corda | Braços estendidos à frente/acima | Corda junto ao peito, cotovelos altos | Composição semelhante ao Face Pull (`treino_081`) | `... standing facing a high cable machine with a ROPE attachment, pulling the rope toward the upper chest, elbows high. Similar composition to a face-pull, not jump rope.` |
| 087 | Rosca Direta com Halteres | Bíceps | Dois halteres simultâneos, pegada supinada, cotovelos fixos | Dois halteres | Braços ao lado do corpo | Halteres na altura dos ombros, palmas para cima | 3/4, da cintura para cima ou corpo inteiro | `... standing curl with TWO dumbbells at the same time, supinated grip, elbows close to the torso, dumbbells near the shoulders.` |
| 088 | Bíceps Alternado / Unilateral | Bíceps | Um halter de cada vez, o outro braço relaxado | Dois halteres | Um braço em baixo, o outro no topo da rosca | Contraste claro entre os dois braços | 3/4 | `... standing alternating dumbbell curl, one arm fully flexed, the other hanging, both dumbbells visible.` |
| 090 | Rosca Alternada com Rotação | Bíceps | Começa em pegada neutra e gira para supinação no topo | Dois halteres | Pegada neutra embaixo | Palmas para cima no topo | 3/4, mostrando o punho | `... standing alternating curl with visible wrist rotation: bottom position hammer grip, top position fully supinated.` |
| 095 | Remada Alta + Desenvolvimento | Ombros | Duas fases: remada alta (barra no peito, cotovelos altos) e desenvolvimento (barra acima da cabeça) | Barra | Fase 1: barra na altura do peito | Fase 2: barra acima da cabeça | Corpo inteiro; composição em duas poses ou pose no meio da transição | `... two-phase move with a barbell: upright row (bar at chest, elbows high) PLUS overhead press. Show both phases clearly, standing.` |
| 101 | Elevação Lateral + Desenvolvimento com Cotovelos à Frente | Ombros | Elevação lateral e, em seguida, press com cotovelos à frente | Halteres | Braços abertos na lateral | Halteres acima da cabeça, cotovelos à frente | Corpo inteiro, duas fases | `... combination lateral raise + front-elbow shoulder press with dumbbells. Standing. Show both phases.` |
| 103 | Elevação Lateral na Polia | Ombros | Em pé ao lado da polia baixa, um braço elevando o cabo na lateral | Polia baixa + cabo + pegada | Braço ao lado do corpo | Braço na altura do ombro, cabo tenso | 3/4, **cabo visível do início ao fim** | `... standing next to a LOW cable pulley, one-arm lateral raise, the cable clearly running from the stack to the hand. Not dumbbells.` |
| 104 | Elevação Lateral no Banco | Ombros | Sentada ou deitada de lado **no banco**, elevando o halter na lateral | Banco + halter | Braço ao longo do corpo | Braço na altura do ombro | Mostrar o banco inteiro | `... performing a lateral raise WHILE USING A BENCH (seated or side-lying on the bench), dumbbell in the working hand, bench clearly visible.` |
| 109 | Tríceps Paralelo | Tríceps | Mergulho nas barras paralelas, cotovelos para trás | Paralelas | Braços estendidos sustentando o corpo | Cotovelos fletidos, ombros pouco acima dos cotovelos | Corpo inteiro de lado | `... dip on parallel bars, body upright, elbows bending behind the torso, feet off the ground. Not a cable triceps exercise.` |
| 111 | Tríceps Testa na Polia | Tríceps | Deitada ou em pé, estendendo os cotovelos com a barra/corda da polia na direção da testa (skull crusher no cabo) | Polia + barra curta ou corda | Antebraços apontando para a polia, cotovelos fixos | Braços estendidos | 3/4, cabo visível | `... lying or standing triceps skull crusher using a CABLE/pulley (not free barbell), bar or rope near the forehead then extending.` |
| 020 | Agachamento com Salto | Cardio | Plyo squat: agacha e **salta**, pés saem do chão | Peso corporal | Agachada | No ar, joelhos estendidos, braços auxiliando | Corpo inteiro de lado/3/4 | `... jump squat (plyometric), athlete leaving the ground at the top of the squat, no bench, no dumbbells, knees extended in the air. Not a Bulgarian split squat.` |
| 022 | Agachamento com Salto Lateral no Step | Cardio | Salto **lateral** sobre o step, um lado de cada vez | Step | Pés no chão ao lado do step | No ar, deslocamento lateral sobre o step | Corpo inteiro, step visível | `... lateral jump over a step/aerobic platform, body in the air crossing sideways, step clearly visible. Not a Bulgarian split squat, no dumbbells.` |
| 027 | Agachamento no TRX | Inferiores | Agachamento segurando as **alças do TRX** | TRX | Em pé, alças na altura do peito | Agachada, TRX visível | Corpo inteiro frontal/3/4, fitas TRX nítidas | `... squat holding TRX suspension straps, straps clearly hanging from above, no dumbbell at the chest. Not a goblet squat.` |
| 032 | Afundo com Halteres no Step | Inferiores | Afundo com o pé da frente **no step**, dois halteres | Step + dois halteres | Passada, pé da frente no step | Joelho de trás descendo, halteres ao lado | Corpo inteiro de lado, step visível | `... dumbbell lunge with the FRONT foot on a step/box, two dumbbells at the sides. Not a Smith machine, guide rails must NOT appear.` |
| 100 | Elevação Frontal – Ombro e Peitoral | Peitoral/Ombros | Frontal com cabo ou halteres, ênfase peitoral+ombro | Conferir cadastro | — | — | — | Hoje compartilha a arte de 099. Gerar execução frontal distinta. |
| 102 | Elevação Frontal com Halteres | Peitoral/Ombros | Dois halteres à frente, na altura dos ombros | Dois halteres | Braços ao lado | Braços à frente, palmas para baixo | 3/4 | `... standing front raise with TWO dumbbells, arms raised forward to shoulder height, palms down. Not a lateral raise.` |

---

## Inventário exercício a exercício

Status possíveis: `OK` · `TROCAR_IMAGEM` · `IMAGEM_FALTANDO` · `CAMINHO_QUEBRADO` · `IMAGEM_INCORRETA` · `IMAGEM_DUPLICADA` · `EXERCICIO_DUPLICADO` · `CATEGORIA_INCORRETA` · `NOME_INCONSISTENTE` · `ASSET_NAO_UTILIZADO` · `REVISAR_MANUALMENTE`

"Arquivo vinculado" = o que `LilyExercicioAssets.pathForId` devolve **depois** das reatribuições.

| ID | Nº | Nome | Categoria | Arquivo vinculado | Status arquivo | Compatível? | Problema | Ação |
|---|---|---|---|---|---|---|---|---|
| treino_001 | 001 | Bike – Queima Gordura | Cardio | treino_001.jpg | existe | sim | — | OK |
| treino_002 | 002 | Bike Horizontal – Queima Gordura | Cardio | treino_002.jpg | existe | sim | Link YouTube cruzado com 003 | OK (imagem); revisar link |
| treino_003 | 003 | Caminhada – Queima Gordura | Cardio | treino_003.jpg | existe | sim | Link YouTube cruzado com 002 | OK (imagem); revisar link |
| treino_004 | 004 | Esteira – Caminhada/Corrida | Cardio | treino_004.jpg | existe | sim | — | OK |
| treino_005 | 005 | Bike Spinning – Queima Gordura | Cardio | treino_005.jpg | existe | sim | — | OK |
| treino_006 | 006 | Simulador de Escada | Cardio | treino_006.jpg | existe | sim | — | OK |
| treino_007 | 007 | Elíptico | Cardio | treino_007.jpg | existe | sim | — | OK |
| treino_008 | 008 | Abdominal Supra no Solo | Core | treino_008.jpg | existe | sim | — | OK |
| treino_009 | 009 | Abdominal – Queima Gordura | Core | treino_009.jpg | existe | sim | — | OK |
| treino_010 | 010 | Abdominal Supra Unilateral | Core | treino_010.jpg | existe | sim | — | OK |
| treino_011 | 011 | Abdominal Remador | Core | treino_011.jpg | existe | sim | — | OK |
| treino_012 | 012 | Prancha Abdominal | Core | treino_012.jpg | existe | sim | — | OK |
| treino_013 | 013 | Abdominal na Máquina | Core | treino_014.jpg | existe | parcial | Máquina ainda não aparece | TROCAR_IMAGEM (gerar 013) |
| treino_014 | 014 | Abdominal Infra na Paralela | Core | treino_101.jpg | existe | sim | Reatribuído | OK |
| treino_015 | 015 | Mobilidade de Ombros | Mobilidade | treino_015.jpg | existe | revisar | Hash = 095 | REVISAR_MANUALMENTE |
| treino_016 | 016 | Along. Superiores Espaldar | Mobilidade | treino_018.jpg | existe | sim | Swap com 018 | OK |
| treino_017 | 017 | Aquecimento Inferiores | Aquecimento | treino_060.jpg | existe | sim | Reatribuído | OK |
| treino_018 | 018 | Along. Inferiores Espaldar | Mobilidade | treino_016.jpg | existe | sim | Swap com 016 | OK |
| treino_019 | 019 | Simulação de Pular Corda | Cardio | treino_019.jpg | existe | sim | — | OK |
| treino_020 | 020 | Agachamento com Salto | Hipertrofia / Cardio | treino_020.jpg | existe | não | Arquivo é búlgaro sem peso (dono do 116) | TROCAR_IMAGEM |
| treino_021 | 021 | Agachamento com Passada Lateral | Hipertrofia / Cardio | treino_021.jpg | existe | sim | — | OK |
| treino_022 | 022 | Agachamento com Salto Lateral no Step | Cardio | treino_022.jpg | existe | não | Arquivo é búlgaro com halteres (dono do 052) | TROCAR_IMAGEM |
| treino_023 | 023 | Polichinelo | Cardio | treino_023.jpg | existe | sim | — | OK |
| treino_024 | 024 | Burpee | Cardio | treino_024.jpg | existe | sim | — | OK |
| treino_025 | 025 | Escalador | Cardio | treino_025.jpg | existe | sim | — | OK |
| treino_026 | 026 | Aquecimento Agach. + Recuo + Avanço | Cardio / Aquecimento | treino_044.jpg | existe | sim | Reatribuído | OK |
| treino_027 | 027 | Agachamento no TRX | Hipertrofia | treino_027.jpg | existe | não | Arquivo é goblet (dono do 033) | TROCAR_IMAGEM |
| treino_028 | 028 | Afundo no TRX | Hipertrofia | treino_028.jpg | existe | sim | — | OK |
| treino_029 | 029 | Afundo no Step sem Peso | Hipertrofia | treino_031.jpg | existe | sim | Swap com 031 | OK |
| treino_030 | 030 | Agachamento no Banco/Cadeira | Cardio / Funcional | treino_033.jpg | existe | sim | Reatribuído | OK |
| treino_031 | 031 | Afundo com Halteres | Hipertrofia | treino_040.jpg | existe | sim | 040.jpg é o afundo mais limpo; compartilha com 054 | OK |
| treino_032 | 032 | Afundo com Halteres no Step | Hipertrofia | treino_032.jpg | existe | não | Arquivo é afundo no Smith (dono do 040) | TROCAR_IMAGEM |
| treino_033 | 033 | Agachamento Taça | Hipertrofia | treino_027.jpg | existe | sim | 027.jpg é goblet (confirmado) | OK |
| treino_034 | 034 | Cadeira Extensora | Hipertrofia | treino_034.jpg | existe | sim | — | OK |
| treino_035 | 035 | Leg Press 45° | Hipertrofia | treino_035.jpg | existe | sim | — | OK |
| treino_036 | 036 | Agachamento Hack Squat | Hipertrofia | treino_036.jpg | existe | sim | — | OK |
| treino_037 | 037 | Agachamento Livre | Hipertrofia | treino_037.jpg | existe | sim | Compartilhado com 069 | OK (069 precisa de arte) |
| treino_038 | 038 | Agachamento Smith | Hipertrofia | treino_039.jpg | existe | sim | Swap profundidade | OK |
| treino_039 | 039 | Agachamento Smith Profundo | Hipertrofia | treino_038.jpg | existe | sim | Swap profundidade | OK |
| treino_040 | 040 | Afundo no Smith | Hipertrofia | treino_032.jpg | existe | sim | 032.jpg é Smith (trilhos visíveis) | OK |
| treino_041 | 041 | Leg Press Horizontal | Hipertrofia | treino_041.jpg | existe | sim | — | OK |
| treino_042 | 042 | Agachamento Livre com Halteres | Hipertrofia | treino_030.jpg | existe | sim | Reatribuído | OK |
| treino_043 | 043 | Máquina Adutora | Hipertrofia | treino_043.jpg | existe | sim | — | OK |
| treino_044 | 044 | Agachamento Pêndulo | Hipertrofia | treino_069.jpg | existe | sim | Reatribuído | OK |
| treino_045 | 045 | Elevação Pélvica no Solo | Ativação | treino_045.jpg | existe | sim | — | OK |
| treino_046 | 046 | Cadeira Abdutora | Hipertrofia | treino_013.jpg | existe | sim | Reatribuído | OK |
| treino_047 | 047 | Stiff Unilateral | Hipertrofia | treino_088.jpg | existe | sim | Reatribuído | OK |
| treino_048 | 048 | Glúteo 4 Apoios Perna Estendida | Hipertrofia | treino_055.jpg | existe | parcial | Variação estendida não aparece | TROCAR_IMAGEM |
| treino_049 | 049 | Glúteo 4 Apoios com Caneleira | Hipertrofia | treino_055.jpg | existe | sim | Compartilha com 048 | OK |
| treino_050 | 050 | Abdução com Caneleira | Hipertrofia | treino_050.jpg | existe | sim | Hash = antigo 046 | OK |
| treino_051 | 051 | Glúteo em Pé – Coice | Hipertrofia | treino_051.jpg | existe | sim | — | OK |
| treino_052 | 052 | Agachamento Búlgaro com Halteres | Hipertrofia | treino_022.jpg | existe | sim | 022.jpg é búlgaro com dois halteres (confirmado) | OK |
| treino_053 | 053 | Afundo Recuo + Rosca Direta | Full Body | treino_113.jpg | existe | sim | Duplicata arquivada | EXERCICIO_DUPLICADO (arquivado) |
| treino_054 | 054 | Afundo com Recuo e Halteres | Inferiores | treino_040.jpg | existe | sim | Compartilha afundo com 031; recuo ainda não aparece | OK (arte de recuo pendente) |
| treino_055 | 055 | Coice no Cabo – Polia Baixa | Inferiores | treino_049.jpg | existe | sim | Reatribuído | OK |
| treino_056 | 056 | Glúteo na Polia Cabo no Quadríceps | Inferiores | treino_056.jpg | existe | revisar | Status cadastro `revisar` | REVISAR_MANUALMENTE |
| treino_057 | 057 | Agachamento Sumô no Step | Inferiores | treino_057.jpg | existe | sim | — | OK |
| treino_058 | 058 | Levantamento Terra Sumô | Inferiores | treino_058.jpg | existe | sim | — | OK |
| treino_059 | 059 | Agachamento Sumô na Máquina | Inferiores | treino_059.jpg | existe | sim | — | OK |
| treino_060 | 060 | Búlgaro no Smith | Inferiores | treino_026.jpg | existe | sim | Reatribuído | OK |
| treino_061 | 061 | Elevação Pélvica | Inferiores | treino_061.jpg | existe | sim | — | OK |
| treino_062 | 062 | Máquina de Elevação Pélvica | Inferiores | treino_062.jpg | existe | sim | — | OK |
| treino_063 | 063 | Cadeira Flexora | Inferiores | treino_063.jpg | existe | sim | — | OK |
| treino_064 | 064 | Mesa Flexora | Inferiores | treino_064.jpg | existe | sim | — | OK |
| treino_065 | 065 | Stiff | Inferiores | treino_065.jpg | existe | sim | — | OK |
| treino_066 | 066 | Panturrilha Sentada | Panturrilhas | treino_066.jpg | existe | sim | — | OK |
| treino_067 | 067 | Subida no Caixote | Inferiores | treino_067.jpg | existe | sim | — | OK |
| treino_068 | 068 | Sumô com Elevação Frontal | Full Body | treino_068.jpg | existe | sim | Candidato a sair do Full Body | REVISAR_MANUALMENTE |
| treino_069 | 069 | Agachamento com Desenvolvimento | Full Body | treino_037.jpg | existe | não | Falta a fase de desenvolvimento | TROCAR_IMAGEM |
| treino_070 | 070 | Agach. + Desenv. Unilateral | Full Body | treino_070.jpg | existe | revisar | Hash = 097; candidato a sair do Full Body | REVISAR_MANUALMENTE |
| treino_071 | 071 | Supino Reto Articulado Neutra | Peitoral | treino_071.jpg | existe | sim | — | OK |
| treino_072 | 072 | Supino Reto Máquina Supinada | Peitoral | treino_075.jpg | existe | sim | Swap com 075 | OK |
| treino_073 | 073 | Supino Inclinado Neutra | Peitoral | treino_074.jpg | existe | sim | Swap com 074 | OK |
| treino_074 | 074 | Supino Inclinado Supinada | Peitoral | treino_073.jpg | existe | sim | Swap | OK |
| treino_075 | 075 | Supino Halteres Inclinado | Peitoral | treino_072.jpg | existe | sim | Swap | OK |
| treino_076 | 076 | Peitoral no Peck Fly | Peitoral | treino_076.jpg | existe | sim | — | OK |
| treino_077 | 077 | Puxada com Barra Longa | Costas | treino_080.jpg | existe | sim | Swap com 080 | OK |
| treino_078 | 078 | Barra Fixa no Graviton | Costas | treino_078.jpg | existe | sim | — | OK |
| treino_079 | 079 | Puxada com Triângulo | Costas | treino_079.jpg | existe | sim | — | OK |
| treino_080 | 080 | Puxada com Barra W | Costas | treino_077.jpg | existe | sim | Swap | OK |
| treino_081 | 081 | Face Pull | Costas | treino_081.jpg | existe | sim | — | OK |
| treino_082 | 082 | Pulldown com Barra Reta | Costas | treino_082.jpg | existe | não | Pessoa sentada | TROCAR_IMAGEM |
| treino_083 | 083 | Puxada Alta com Corda | Costas | treino_083.jpg | existe | não | Parece pular corda | TROCAR_IMAGEM |
| treino_084 | 084 | Remada Sentada com Triângulo | Costas | treino_094.jpg | existe | sim | Swap com 094 | OK |
| treino_085 | 085 | Remada Curvada com Barra | Costas | treino_085.jpg | existe | sim | — | OK |
| treino_086 | 086 | Rosca Polia Baixa Barra Reta | Bíceps | treino_089.jpg | existe | sim | Swap com 089 | OK |
| treino_087 | 087 | Rosca Direta com Halteres | Bíceps | treino_106.jpg | existe | parcial | Arte de alternada | TROCAR_IMAGEM |
| treino_088 | 088 | Bíceps Alternado / Unilateral | Bíceps | treino_106.jpg | existe | parcial | Mesma arte | TROCAR_IMAGEM |
| treino_089 | 089 | Rosca Direta na Máquina | Bíceps | treino_086.jpg | existe | sim | Swap | OK |
| treino_090 | 090 | Rosca Alternada com Rotação | Bíceps | treino_106.jpg | existe | parcial | Mesma arte | TROCAR_IMAGEM |
| treino_091 | 091 | Rosca Martelo com Corda | Bíceps | treino_091.jpg | existe | sim | — | OK |
| treino_092 | 092 | Rosca Unilateral na Polia Baixa | Bíceps | treino_087.jpg | existe | sim | Reatribuído | OK |
| treino_093 | 093 | Remada Alta na Polia | Ombros | treino_093.jpg | existe | revisar | Hash = 117 | REVISAR_MANUALMENTE |
| treino_094 | 094 | Remada Alta com Barra | Ombros | treino_084.jpg | existe | sim | Swap com 084 | OK |
| treino_095 | 095 | Remada Alta + Desenvolvimento | Ombros | treino_095.jpg | existe | não | Hash = 015; sem duas fases | TROCAR_IMAGEM |
| treino_096 | 096 | Desenvolvimento com Halteres | Ombros | treino_095.jpg | existe | sim | 095.jpg é press com halteres (confirmado); 095 espera combinado | OK |
| treino_097 | 097 | Desenvolvimento Arnold em Pé | Ombros | treino_097.jpg | existe | revisar | Hash = 070 | REVISAR_MANUALMENTE |
| treino_098 | 098 | Desenvolvimento na Máquina | Ombros | treino_098.jpg | existe | revisar | Hash = antigo 096 | REVISAR_MANUALMENTE |
| treino_099 | 099 | Elevação Frontal na Polia | Ombros | treino_100.jpg | existe | sim | Compartilha com 100 | OK (100 precisa de arte) |
| treino_100 | 100 | Elevação Frontal Ombro e Peitoral | Peitoral | treino_100.jpg | existe | parcial | Categoria peitoral vs ombro | NOME_INCONSISTENTE / TROCAR_IMAGEM |
| treino_101 | 101 | Elev. Lateral + Desenv. Cotovelos | Ombros | treino_101.jpg | existe | não | Infra na paralela (dono do 014). 052.jpg é sumô, não usar | TROCAR_IMAGEM |
| treino_102 | 102 | Elevação Frontal com Halteres | Peitoral | treino_102.jpg | existe | parcial | Compartilha com 106 (lateral) | TROCAR_IMAGEM |
| treino_103 | 103 | Elevação Lateral na Polia | Ombros | treino_103.jpg | existe | não | Sem polia; hash compartilhado | TROCAR_IMAGEM |
| treino_104 | 104 | Elevação Lateral no Banco | Ombros | treino_104.jpg | existe | não | Sem banco; hash compartilhado | TROCAR_IMAGEM |
| treino_105 | 105 | Elevação Frontal com Anilha | Peitoral | treino_105.jpg | existe | revisar | Hash compartilhado | REVISAR_MANUALMENTE |
| treino_106 | 106 | Elevação Lateral com Halteres | Ombros | treino_102.jpg | existe | sim | Reatribuído | OK |
| treino_107 | 107 | Tríceps com Corda | Tríceps | treino_107.jpg | existe | revisar | Hash = 110/111/112 | REVISAR_MANUALMENTE |
| treino_108 | 108 | Tríceps Francês com Corda | Tríceps | treino_108.jpg | existe | revisar | Duplicata de nome | EXERCICIO_DUPLICADO |
| treino_109 | 109 | Tríceps Paralelo | Tríceps | treino_109.jpg | existe | não | Não é mergulho | TROCAR_IMAGEM |
| treino_110 | 110 | Tríceps Francês com Corda | Tríceps | treino_110.jpg | existe | revisar | Duplicata + hash compartilhado | EXERCICIO_DUPLICADO |
| treino_111 | 111 | Tríceps Testa na Polia | Tríceps | treino_111.jpg | existe | não | Hash compartilhado | TROCAR_IMAGEM |
| treino_112 | 112 | Tríceps Francês com Corda | Tríceps | treino_112.jpg | existe | revisar | Duplicata + hash compartilhado | EXERCICIO_DUPLICADO |
| treino_113 | 113 | Full Body – Afundo Recuo + Rosca | Full Body | treino_113.jpg | existe | sim | Principal da duplicata 053 | OK |
| treino_114 | 114 | Sumô com Elevação Lateral | Full Body | treino_042.jpg | existe | sim | 042.jpg é o movimento (confirmado). Candidato a sair do Full Body | REVISAR_MANUALMENTE |
| treino_115 | 115 | Afundo Recuo + Remada Curvada | Full Body | treino_115.jpg | existe | sim | — | OK |
| treino_116 | 116 | Búlgaro sem Peso | Inferiores | treino_020.jpg | existe | sim | 020.jpg é búlgaro sem peso (confirmado) | OK |
| treino_117 | 117 | Remada Articulada | Costas | treino_117.jpg | existe | revisar | Hash = 093 | REVISAR_MANUALMENTE |

---

## Contagens finais (após correções de código)

```
AUDITORIA LILI FIT FINALIZADA
Total de exercícios:           117  (116 visíveis para a aluna)
Imagens OK:                     68
Imagens corrigidas (vínculo):   44 reatribuições
Imagens ainda faltando:          0 arquivos físicos
Imagens que precisam ser geradas: 28
Duplicidades corrigidas:         1 (treino_053 arquivado; 113 principal)
Pendências manuais:             12
Artes compartilhadas (visíveis): 12 grupos
```

Inspeção visual de inferiores e ombros (2026-09-17) corrigiu donos invertidos: 020/022/027/032 esperam arte nova; 033/040/052/116 ficaram OK com arquivos já existentes. `treino_101` não usa mais `treino_052.jpg`.

Validação automática (`flutter analyze` / `flutter test`) **não rodou**: o shell deste ambiente não devolve status. Rode localmente:

```
flutter analyze
flutter test test/lily_exercicio_assets_test.dart test/treino_catalog_validation_test.dart
```

Depois de gerar as artes novas: coloque o JPG em `assets/lily_exercicios/` com o número do exercício **ou** acrescente uma entrada em `reatribuicoesAuditoria`, e atualize `kArtesCompartilhadasConhecidas` no teste para o grupo correspondente desaparecer.
