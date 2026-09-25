# PENDÊNCIAS DA PROPRIETÁRIA (AMANDA LOPES)
## Método 1 Dia de Cada Vez

**Data:** 22/09/2026  
Somente o que **precisa de decisão, conteúdo ou acesso** da Amanda. Itens técnicos → `PENDENCIAS_PROGRAMADOR.md`.

---

## 1. Contas e testes (bloqueia homologação)

| Item | Por quê | Ação Amanda | Status |
|---|---|---|---|
| Conta Aluno de teste | Validar app como usuária | Criar/fornecer e-mail+senha | 👩‍💼 DEPENDE DA PROPRIETÁRIA |
| Conta Personal | Validar CMS/alunos | Criar/fornecer | 👩‍💼 |
| Conta Admin | Validar painel (com apoio técnico) | Autorizar UID em `admins/` | 👩‍💼 + 👨‍💻 |
| Conta revisor Google Play | Exigência da loja | Criar e guardar senha | 👩‍💼 |
| Conta revisor App Store | Idem Apple | Criar | 👩‍💼 |
| Executar roteiro no celular | Homologação final | Seguir `CHECKLIST_HOMOLOGACAO_FINAL.md` e marcar PASSOU/FALHOU | 👩‍💼 |

---

## 2. Conteúdo

| Item | Por quê | Ação Amanda | Status |
|---|---|---|---|
| Trocar Shorts `lLfcuiW32iI` → `akKcU1UVUYw` | Vídeo não está no código local; provavelmente no app/CMS | Abrir área Personal → Vídeos → editar o card → colar novo link `https://youtube.com/shorts/akKcU1UVUYw` **mantendo título/ordem/categoria** | 👩‍💼 (ou 👨‍💻 no Firestore) |
| Confirmar 7 meditações | Já testadas uma vez; revalidar neste APK | Abrir cada uma; play/voltar | 👩‍💼 |
| PDFs/apostilas finais | Nenhuma aula com placeholder | Conferir cada PDF no app | 👩‍💼 |
| Textos “Quem sou eu” / Amanda | Identidade | Aprovar textos/fotos | 👩‍💼 |
| Vídeo boas-vindas (`boas_vindas_metodo_1_dia`) | Seed sem URL YouTube | Fornecer Short/vídeo final se for obrigatório no lançamento | 👩‍💼 |

---

## 3. Lojas (Google Play / App Store)

| Item | Ação Amanda |
|---|---|
| Conta Google Play Console **no nome dela** | Criar/possuir; programador só como acesso convidado |
| Conta Apple Developer **no nome dela** | Idem |
| Nome, descrição curta/longa, subtítulo | Aprovar textos finais |
| Screenshots / feature graphic | Aprovar artes (ou fornecer fotos) |
| Classificação de conteúdo / idade | Responder questionários |
| Política de Privacidade / Termos no ar | Autorizar deploy Hosting se necessário; revisar textos com jurídico se quiser |
| Data Safety / App Privacy | Responder quais dados o app coleta (com apoio do programador) |
| Países de publicação | Decidir |
| Preços / assinaturas | Decidir se lança com IAP ligado ou só catálogo informativo (`PAYMENTS_ENABLED` permanece false até autorização **escrita**) |

---

## 4. Decisões comerciais / jurídicas

| Item | Nota |
|---|---|
| Ligar cobrança real | **Só com autorização explícita** da Amanda |
| Revisão jurídica de Termos/Privacidade | Não inventamos conformidade; se precisar advogado, é decisão dela |
| Suporte oficial | Confirmar uso contínuo de `1diadecadavezsuporte@gmail.com` |

---

## 5. Propriedade e continuidade

| Ativo | Ação Amanda |
|---|---|
| Acesso Firebase `metodo1dia-app` (Owner) | Garantir que **ela** é owner; programador Editor se necessário |
| Cópia segura do keystore Android + senhas | Guardar em local seguro **dela** (não só no PC do programador) |
| Acesso GitHub/repositório | Owner ou admin |
| Play Console / App Store Connect | Owner |
| Domínio / e-mails | Controle dela |

Ver inventário completo: `INVENTARIO_ENTREGA_TECNICA.md`.

---

## 6. O que Amanda **não** precisa fazer

- Reescrever o app
- Mexer em código Dart
- Ligar `PAYMENTS_ENABLED` sozinha
- Publicar sem checklist de homologação assinada
