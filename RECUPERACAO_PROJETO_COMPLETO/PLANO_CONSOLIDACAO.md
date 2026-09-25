# Plano de consolidacao segura (NAO EXECUTADO — aguarda aprovacao)

Branch: consolidacao-recuperacao (criada a partir de master @ 1335db6)
master permanece intacta no mesmo commit.

## A) Assets dos backups — varredura

| Criterio | Resultado |
|----------|-----------|
| Arquivos com nome inexistente em assets/ | 0 |
| Nomes no indice backup_visual_* ausentes de assets/ | 0 |
| Duplicatas exatas (mesmo nome + mesmo hash) | 57 |
| Variantes (mesmo nome, hash diferente) | 103 (muitas repetidas entre pastas backup) |

### Conclusao de assets
NAO ha arquivo de midia/icone realmente unico para importar.
Importar variantes so substituiria ou duplicaria o que o app ja usa — fora do escopo.

Variantes ja isoladas (referencia, sem integrar) em
RECUPERACAO_PROJETO_COMPLETO/icones_variantes_diferentes_do_assets/:
- icon_hydration (backup vs atual)
- icon_recipes (backup vs atual)

Codigo antigo (GPS/nav/PT/nutricao): NAO restaurar.

Segredos: nao serao enviados ao GitHub.

## B) Pendencias de producao — classificacao

| Pendencia | Classificacao |
|-----------|---------------|
| Assinatura Android (keystore + key.properties) + AAB | CRITICA PARA PUBLICACAO |
| google-services.json no ambiente de build | CRITICA PARA PUBLICACAO |
| RevenueCat + produtos loja + dart-define das chaves | CRITICA PARA PUBLICACAO |
| iOS Firebase REPLACE_ME + pasta ios/ | CRITICA se lancar iOS; IMPORTANTE se so Android na 1a wave |
| Deploy Functions + secret OpenAI | CRITICA PARA PUBLICACAO |
| App Check enforce em producao | IMPORTANTE |
| Privacy / Data Safety lojas | CRITICA PARA PUBLICACAO |
| Health Sync stub | OPCIONAL |
| Admin mock | OPCIONAL |
| Web Firebase REPLACE_ME | OPCIONAL |

## C) Plano de correcao (ordem) — AGUARDAR "pode executar"

### Fase 0 — Consolidacao Git (leve)
1. Trabalhar so em consolidacao-recuperacao
2. Opcional: commit so de documentacao / pasta RECUPERACAO
3. Nao adicionar assets duplicados/variantes
4. Nao mergear codigo de backup_nav / backup_visual

### Fase 1 — Publicacao Android (CRITICA)
1. Backup privado keystore + key.properties + google-services.json
2. flutter build appbundle --release (+ defines RevenueCat se billing no lancamento)
3. Play Console (Data Safety, screenshots, politica)

### Fase 2 — Billing (CRITICA se Premium no lancamento)
1. Produtos mensal/anual nas lojas
2. Entitlement premium no RevenueCat
3. Build com REVENUECAT_ANDROID_KEY / REVENUECAT_IOS_KEY
4. Depois: webhook -> Firestore isPremium / premiumExpiresAt

### Fase 3 — Backend (CRITICA)
1. firebase deploy rules + functions
2. Secret OpenAI; depois ENFORCE_APP_CHECK=true

### Fase 4 — iOS (CRITICA so se iOS no lancamento)
1. flutter create . (gerar ios/ sem sobrescrever lib/)
2. Firebase iOS + flutterfire configure
3. Assinatura Apple / APNs

### Fase 5 — OPCIONAL
1. Health Sync real
2. Completar Admin
3. Trocar variante de icone so com aprovacao visual explicita

## D) Nao farei sem nova ordem
- Substituir lib/ por backups
- Copiar variantes para assets/ no automatico
- Commit de segredos
- Reset/checkout destrutivo em master
- Executar Fases 1-5

Proximo passo: (1) so documentar/commitar este plano na branch e/ou (2) executar qual fase.
