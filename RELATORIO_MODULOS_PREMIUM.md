# Relatório — Dashboard Premium, Certificados, Indicação, Cupons e Relatórios

## ⚠️ Mesmo aviso de sempre
Não tenho Flutter instalado aqui — nada disso foi compilado de verdade.
Fiz auditoria estática (imports, dependências, balanceamento de chaves) em
100% dos arquivos novos e editados, mas **você precisa rodar `flutter pub
get && flutter analyze` antes de confiar nisso em produção**. Adicionei 5
pacotes novos (`pdf`, `printing`, `share_plus`, e os já usados `table_calendar`/
`just_audio`/`pdfx` de rodadas anteriores) — é a primeira vez que essas
combinações específicas rodam juntas neste projeto.

## ✅ Infraestrutura de dados que faltava (pré-requisito dos 5 módulos)
Antes de construir os módulos, completei 3 coisas que estavam pela metade e
que os módulos novos precisavam de dado real (não inventado):
- **Corrida**: o botão "Salvar e concluir" só resetava a tela — não
  salvava nada. Agora persiste de verdade (Firestore `running_sessions` ou
  local sem Firebase), e a Cloud Function que já existia
  (`onRunningSessionCreated`) volta a fazer sentido.
- **Água**: era estado efêmero da tela (sumia ao trocar de aba). Agora
  persiste por dia.
- **Macros da alimentação**: `FoodEntry` ganhou proteína/carbo/gordura
  (opcional, default 0 — não quebra registros antigos); a foto por IA agora
  estima isso também.
- **Corrigido bug de segurança pré-existente**: `totalKm` podia ser editado
  pelo próprio app (não estava na lista de campos protegidos do Firestore).
  Isso quebraria a legitimidade dos certificados de 500km/1000km. Corrigido
  junto com `referralCount`/`referralCode`.

## ✅ Módulo 4 — Dashboard Premium
Gráficos reais (peso/IMC, água, calorias+macros, corridas, hábitos) com
filtro Dia/Semana/Mês/Ano, usando `fl_chart` (já era dependência). XP/nível/
sequência/km total no topo.

## ✅ Módulo 6 — Certificados em PDF
7 certificados (30/90/365 dias de sequência, 100 treinos, 500km, 1000km, 1
mês de conta) com desbloqueio automático baseado em dado real. PDF gerado
na hora com a identidade visual do app, compartilhável nativamente.

## ✅ Módulo 7 — Sistema de Indicação
Código único gerado no cadastro, campo opcional "código de indicação" na
tela de registro, tela de compartilhamento com contador. **Importante**: a
recompensa (+100 XP, +50 moedas) é creditada por uma Cloud Function nova
(`onUserCreated`), nunca pelo cliente — evita autoconcessão fraudulenta.

## ✅ Módulo 8 — Cupons e Promoções
CRUD real de cupons pro admin (Firestore, protegido por `isAdmin()`). Tela
de resgate pra usuária chama uma Cloud Function nova (`redeemCoupon`) que
valida expiração/limite/duplicidade numa transação atômica e só então
credita — impossível de burlar client-side.

**Limitação que preciso ser honesta sobre**: a recompensa "dias Premium"
credita um contador (`premiumUntilExtraDays`) no perfil, mas eu **não
conectei isso à lógica real de acesso Premium**, porque essa lógica hoje
vive no RevenueCat (fonte de verdade das assinaturas) e eu não devo inventar
um caminho paralelo de liberar Premium sem entender como o RevenueCat já
decide isso — poderia abrir brecha ou conflitar com a assinatura paga de
verdade. Fica documentado como pendência real, não como concluído.

## ✅ Módulo 9 — Relatórios em PDF
Exportação com período (7/30/90/365 dias) e seções escolhíveis (peso/IMC,
água, calorias, corridas, hábitos), compartilhável nativamente.

## Regras de segurança atualizadas
- `audio_courses`, `pdf_recipes` (da rodada anterior — confirmado ok)
- `referral_codes`: cliente só cria o PRÓPRIO código, nunca lê nem sobrescreve
- `coupons`: leitura pra usuária logada, escrita só admin
- `coupon_redemptions`: só a Cloud Function escreve (Admin SDK)
- `totalKm`, `referralCount`, `referralCode` agora protegidos contra edição
  direta pelo cliente

## Cloud Functions novas (`functions/src/index.js`)
- `onUserCreated`: credita recompensa de indicação
- `redeemCoupon`: valida e credita resgate de cupom (exige token de auth)
- `calorieVision`: atualizada pra também estimar macros

## Rotas e atalhos
Todos os 5 módulos têm rota no GoRouter e atalho na Home (só adicionei
itens ao grid existente). O admin de cupons também ganhou um link real no
painel administrativo (antes só tinha ações mock "conecte ao Firestore").
