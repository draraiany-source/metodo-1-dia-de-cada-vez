# INVENTÁRIO DE ENTREGA TÉCNICA
## Método 1 Dia de Cada Vez — continuidade sem dependência exclusiva do desenvolvedor

**Data:** 22/09/2026  
**Regra deste arquivo:** NÃO listar senhas, tokens, private keys ou segredos completos. Apenas existência, controle e ação.

---

## 1. Código-fonte

| Ativo | Existe? | Quem controla | Onde | Amanda tem acesso? | Ação necessária |
|---|---|---|---|---|---|
| Repositório Git local | Sim | Dev na máquina atual | Desktop `metodo 1 dia perfil premium 2` | Verificar | Garantir remote GitHub/GitLab no nome dela |
| Branch `finalizacao-metodo-1-dia-de-cada-vez` | Sim | Dev | Git | Verificar | Push + convite Owner |
| Tag `backup-pre-homologacao-final-20260922` | Criada nesta fase | Dev | Git tags | Após push de tags | `git push --tags` |
| Tags de backup anteriores | Sim | Dev | Git | Após push | Manter |
| Working tree otimização tamanho | Sim (não commitada) | Dev | Working copy | N/A | Commit organizado (P1) |

---

## 2. Backend / Firebase

| Ativo | Existe? | Quem controla | Onde | Amanda tem acesso? | Ação necessária |
|---|---|---|---|---|---|
| Projeto Firebase `metodo1dia-app` | Sim | Conta Google do projeto | console.firebase.google.com | **Confirmar Owner** | Amanda = Owner |
| Auth | Sim | Firebase | Console | Via Owner | Contas teste |
| Firestore | Sim | Firebase | Console | Via Owner | Backup export periódico |
| Storage | Sim | Firebase | Console | Via Owner | Idem |
| Hosting | Sim (`metodo1dia-app.web.app`) | Firebase | Console | Via Owner | Deploy legais |
| Cloud Functions | Código no repo | Firebase + Dev | `functions/` | Via Owner | Revalidar deploy |
| App Check | Parcial | Firebase | Console | Via Owner | Decisão enforce |
| Analytics / Crashlytics | Sim | Firebase | Console | Via Owner | Acesso leitura Amanda |
| `google-services.json` | Sim | Repo Android | `android/app/` | Via repo | Não é secret de servidor |
| `firebase_options.dart` iOS | Incompleto (`REPLACE_ME`) | Dev | `lib/` | Via repo | `flutterfire configure` |

**Homolog = produção:** um único projeto. Qualquer teste mexe em dados reais.

---

## 3. Assinatura Android

| Ativo | Existe? | Quem controla | Onde | Amanda tem acesso? | Ação necessária |
|---|---|---|---|---|---|
| Upload keystore `.jks` | Sim (máquina local) | Dev local | `android/keystore/` (não versionar) | **Deve ter cópia** | Backup criptografado com Amanda |
| `key.properties` | Sim | Dev local | `android/key.properties` gitignored | Deve ter cópia segura | Nunca commit; guardar senha no cofre dela |
| Play App Signing | A configurar | Play Console | Google Play | Conta dela | Aceitar Play App Signing |

---

## 4. Apple / iOS

| Ativo | Existe? | Quem controla | Onde | Amanda tem acesso? | Ação necessária |
|---|---|---|---|---|---|
| Apple Developer | ? | Amanda | developer.apple.com | Obrigatório Owner | Criar/renovar |
| Certificados / profiles | ? | Mac + conta | Keychain / ASC | Amanda | Emitir no Mac dela ou serviço |
| Bundle ID `com.metodo1dia.app` | Planejado | ASC | App Store Connect | Amanda | Registrar |

---

## 5. Lojas

| Ativo | Existe? | Quem controla | Onde | Amanda tem acesso? | Ação necessária |
|---|---|---|---|---|---|
| Google Play Console | ? | Amanda | play.google.com/console | Owner | Criar app + convidar Dev |
| App Store Connect | ? | Amanda | appstoreconnect.apple.com | Owner | Criar app |
| Screenshots / listing | Parcial | Amanda + Dev | A produzir | Amanda aprova | Pacote final |
| Data Safety / App Privacy | Não preenchido | Amanda + Dev | Consoles | Amanda responde | Formulários |

---

## 6. Pagamentos

| Ativo | Existe? | Quem controla | Onde | Amanda tem acesso? | Ação necessária |
|---|---|---|---|---|---|
| RevenueCat projeto | Estrutura no app | Amanda + Dev | dashboard.revenuecat.com | **Confirmar** | Conta dela Owner |
| Produtos Play/Apple | IDs no código | Lojas | Consoles | Amanda | Criar produtos alinhados aos IDs |
| `PAYMENTS_ENABLED` | false | Build | dart-define | Amanda autoriza mudança | Só ligar após OK escrito |

---

## 7. Domínio, e-mail, suporte

| Ativo | Existe? | Quem controla | Onde | Amanda tem acesso? | Ação necessária |
|---|---|---|---|---|---|
| Hosting Firebase URL | Sim | Firebase | metodo1dia-app.web.app | Via Firebase | Manter |
| Domínio próprio | ? | Amanda | DNS | Confirmar | Se houver, transferir/controle |
| E-mail suporte | Sim (referência) | Amanda | Gmail suporte | Deve ter | Acesso à caixa `1diadecadavezsuporte@gmail.com` |

---

## 8. Serviços externos

| Ativo | Existe? | Quem controla | Nota |
|---|---|---|---|
| OpenAI (Functions) | Desenho servidor | Conta OpenAI | Chave **só** no servidor Firebase; Amanda Owner da conta |
| YouTube (embeds) | Sim | Canal Amanda | Shorts públicos/não listados |
| Maps API | Opcional dart-define | Google Cloud | Restringir key |

---

## 9. Documentação gerada nesta fase

| Arquivo | Função |
|---|---|
| `RELATORIO_FINAL_METODO_1_DIA_DE_CADA_VEZ.md` | Visão executiva |
| `CHECKLIST_HOMOLOGACAO_FINAL.md` | Roteiro de teste |
| `PENDENCIAS_PROGRAMADOR.md` | P0/P1/P2 técnicos |
| `PENDENCIAS_AMANDA.md` | Itens da proprietária |
| `CHECKLIST_PUBLICACAO_ANDROID_IOS.md` | Passo a passo lojas |
| Este inventário | Continuidade |

---

## 10. Checklist mínimo “Amanda independente”

- [ ] Owner Firebase
- [ ] Owner Play Console
- [ ] Owner Apple Developer (se iOS)
- [ ] Owner/admin repositório Git
- [ ] Cópia keystore + instrução de senha em cofre dela
- [ ] Acesso e-mail suporte
- [ ] Acesso RevenueCat (se usar IAP)
- [ ] Cópias dos 6 documentos desta entrega
