# CHECKLIST PUBLICAÇÃO ANDROID E iOS (ENTREGA)
## Método 1 Dia de Cada Vez — 23/09/2026

Marcar só o que foi verificado. Plataformas **não** se substituem.

---

## ANDROID (Play)

| # | Item | Status 23/09 |
|---|---|---|
| AN1 | `applicationId` `com.metodo1dia.app` | OK no Gradle |
| AN2 | minSdk ≥23 / targetSdk ≥36 | OK |
| AN3 | AAB release gerado | Existe ~148 MB local |
| AN4 | AAB assinado keystore Amanda | **PENDENTE** (não validar no Git) |
| AN5 | Working tree = commit de release | **NÃO** (~971 dirty) |
| AN6 | `PAYMENTS_ENABLED` produção | **false** (correto até autorização) |
| AN7 | Privacy / Terms URLs no app | `.html` 200; bare path 404 |
| AN8 | Data Safety / conteúdo | **PENDENTE** Amanda+tech |
| AN9 | Screenshots / ícone / feature graphic | **PENDENTE** |
| AN10 | Conta teste Play + E2E Aluna/Personal/Admin | **PENDENTE** |
| AN11 | Exclusão de conta testada | **PENDENTE** |
| AN12 | Internal testing track | **PENDENTE** |

**Android pronto para publicar?** **NÃO**

---

## iOS (App Store)

| # | Item | Status 23/09 |
|---|---|---|
| IO1 | Bundle `com.metodo1dia.app` | OK no projeto |
| IO2 | Firebase iOS real (`REPLACE_ME` removido) | **BLOQUEADO** |
| IO3 | Mac + Xcode + Archive | **PENDENTE** |
| IO4 | TestFlight build | **PENDENTE** |
| IO5 | App Privacy / ATT se aplicável | **PENDENTE** |
| IO6 | Screenshots iPhone | **PENDENTE** |
| IO7 | IAP StoreKit + RevenueCat (se decisão) | **PENDENTE** |
| IO8 | E2E 3 perfis em device iOS | **PENDENTE** |

**iOS pronto para publicar?** **NÃO**

---

## COMUM

| # | Item | Status |
|---|---|---|
| CM1 | Homolog web HTTP 200 | OK canal |
| CM2 | Homolog = build atual | **Validar** (possível atraso) |
| CM3 | Regras Firestore catch-all | No repo |
| CM4 | Guest mode off | OK |
| CM5 | Autorização escrita cobrança | **PENDENTE** Amanda |

---

## COMANDOS RÁPIDOS

Ver `AUDITORIA_FINAL_ENTREGA_PROGRAMADOR_20260923.md` §1.5.
