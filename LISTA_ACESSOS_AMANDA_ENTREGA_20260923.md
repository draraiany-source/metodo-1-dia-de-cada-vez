# LISTA DE ACESSOS E MATERIAIS — AMANDA LOPES
## Método 1 Dia de Cada Vez — Entrega ao programador — 23/09/2026

**Importante:** este arquivo **não contém senhas**. Entregar credenciais por canal seguro (1Password, Bitwarden, mensagem criptografada). Não colar senhas em PDF, Git ou WhatsApp aberto.

---

## 1. Contas e acessos (convidar o programador)

| # | Serviço | Ação da Amanda | Observação |
|---|---|---|---|
| 1 | Firebase Console `metodo1dia-app` | Convidar e-mail do programador (Editor ou Owner temporário) | Projeto já existente |
| 2 | Google Play Console | Acesso de desenvolvedor no app | Conta **dela** |
| 3 | Apple Developer Program | Acesso + Mac disponível | Conta **dela** |
| 4 | RevenueCat (se IAP) | Dashboard + permissão | Só se autorizar cobrança |
| 5 | Domínio / e-mail suporte | Confirmar `1diadecadavezsuporte@gmail.com` | Já usado em docs |
| 6 | Hosting Firebase | Já no mesmo projeto | Homolog canal `homologacao` |

---

## 2. Arquivos / segredos (canal seguro)

| # | Item | Formato | Nunca no Git |
|---|---|---|---|
| 1 | Keystore Android + senhas | `.jks` / `.keystore` + `key.properties` | Sim |
| 2 | Contas de teste (3 perfis) | E-mails + senhas | Senhas fora do PDF |
| 3 | UID Admin para `admins/{uid}` | UID após 1º login | Tech grava no FS |
| 4 | Chaves RevenueCat (se IAP) | Public/SDK keys | `--dart-define` / CI |
| 5 | GoogleService-Info.plist (iOS) | Após registrar app iOS no Firebase | Sim (ou via flutterfire) |
| 6 | Service account (só se CI) | JSON | Sim |

---

## 3. Material de loja (Amanda)

| # | Item |
|---|---|
| 1 | Textos Play Store e App Store (PT-BR) |
| 2 | Screenshots telefones (e tablet se exigir) |
| 3 | Ícone / feature graphic (se ainda não final) |
| 4 | Política de privacidade / termos revisados juridicamente |
| 5 | Respostas Data Safety / App Privacy |
| 6 | Autorização **escrita** para ligar cobrança real |

---

## 4. Decisões comerciais (bloquear ou liberar IAP)

| # | Pergunta | Resposta Amanda |
|---|---|---|
| 1 | Ativar assinatura paga no lançamento? | |
| 2 | Preços mensal / trimestral / anual | |
| 3 | Trial 7 dias só no app ou também na loja? | |
| 4 | Países / moedas | |
| 5 | Cancelamento: só loja ou também suporte? | |

---

## 5. Contas de teste — modelo de entrega segura

1. Amanda cria 3 e-mails (ex.: `teste.aluna@…`, `teste.personal@…`, `teste.admin@…`).  
2. Envia **apenas e-mails** neste checklist ou por e-mail.  
3. Envia **senhas** só no cofre compartilhado.  
4. Programador: login uma vez → anota UID Admin → grava `admins/{uid}` → marca Personal no doc do usuário.  
5. Executa `CHECKLIST_E2E_TRES_PERFIS_ENTREGA_20260923.md`.

**Nesta auditoria:** contas **não** foram criadas.

---

## 6. URLs úteis (públicas)

- Homolog: https://metodo1dia-app--homologacao-cw9j2u83.web.app  
- Privacidade: https://metodo1dia-app.web.app/privacidade.html  
- Termos: https://metodo1dia-app.web.app/termos.html  

---

## 7. Contato técnico de referência no projeto

Relatório completo: `AUDITORIA_FINAL_ENTREGA_PROGRAMADOR_20260923.md`  
Pendências tech: `PENDENCIAS_PROGRAMADOR.md`  
Pendências Amanda: `PENDENCIAS_AMANDA.md`
