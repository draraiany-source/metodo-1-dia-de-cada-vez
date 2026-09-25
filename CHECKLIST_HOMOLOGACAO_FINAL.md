# CHECKLIST DE HOMOLOGAÇÃO FINAL
## Método 1 Dia de Cada Vez — Amanda Lopes

**Data:** 22/09/2026  
**Regra:** marcar PASSOU somente com evidência (print, vídeo ou log). Sem aparelho/conta = PENDENTE.

**Contas necessárias (preencher):**

| Perfil | E-mail | UID | Quem cria |
|---|---|---|---|
| Aluno | ________ | ________ | Amanda / Prog |
| Personal | ________ | ________ | Amanda / Prog |
| Admin (`admins/{uid}`) | ________ | ________ | Prog + Amanda |

**APK sugerido para teste físico:**  
`build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (~104,61 MB)

---

## Legenda de status

- [ ] PENDENTE
- [x] PASSOU
- [!] FALHOU
- [-] N/A

Colunas: Teste | Resultado | Evidência | Aprovado?

---

## A. Instalação e sessão

| ID | Tela/funcionalidade | Procedimento | Resultado esperado | Resultado encontrado | Status | Bloqueia? | Evidência |
|---|---|---|---|---|---|---|---|
| H-01 | Instalar APK arm64 | Instalar release; abrir | Abre splash → login/home | | [ ] | Sim | |
| H-02 | Cadastro aluno | Criar conta nova e-mail/senha | Conta criada como aluno | | [ ] | Sim | |
| H-03 | Login | Entrar com aluno | Home autenticada | | [ ] | Sim | |
| H-04 | Logout | Sair | Volta ao login; não volta logado | | [ ] | Sim | |
| H-05 | Login novamente | Relogar | Home OK | | [ ] | Sim | |
| H-06 | Recuperar senha | Esqueci senha | E-mail enviado / mensagem clara | | [ ] | Não | |
| H-07 | Conta desabilitada | (se aplicável) | Bloqueia acesso | | [ ] | Sim | |
| H-08 | Fechar/reabrir app | Kill e abrir | Sessão consistente | | [ ] | Sim | |

## B. Home e navegação

| ID | Tela/funcionalidade | Procedimento | Resultado esperado | Resultado encontrado | Status | Bloqueia? | Evidência |
|---|---|---|---|---|---|---|---|
| H-10 | Home | Abrir após login | Saudação sem “Olá, !”; cards OK | | [ ] | Sim | |
| H-11 | Bottom nav | Percorrer abas | Sem loop; volta OK | | [ ] | Sim | |
| H-12 | Botão voltar Android | Em cada fluxo | Não prende; não fecha indevido | | [ ] | Sim | |
| H-13 | Gesto voltar | Idem | Igual botão | | [ ] | Sim | |

## C. Treinos / Lily

| ID | Tela/funcionalidade | Procedimento | Resultado esperado | Resultado encontrado | Status | Bloqueia? | Evidência |
|---|---|---|---|---|---|---|---|
| H-20 | Catálogo treinos | Abrir lista | Imagens Lily/treinos carregam | | [ ] | Sim | |
| H-21 | Detalhe exercício | Abrir 3 exercícios | Nome, imagem, YouTube se houver | | [ ] | Sim | |
| H-22 | Sessão / timer | Iniciar e pausar | Timer OK; sem freeze | | [ ] | Sim | |
| H-23 | Voltar pós-treino | Voltar várias vezes | Sem tela presa | | [ ] | Não | |

## D. Hidratação / metas / conquistas

| ID | Tela/funcionalidade | Procedimento | Resultado esperado | Resultado encontrado | Status | Bloqueia? | Evidência |
|---|---|---|---|---|---|---|---|
| H-30 | Meta água | Definir meta; adicionar ml | Histórico atualiza | | [ ] | Não | |
| H-31 | Metas | Abrir metas | Lista coerente | | [ ] | Não | |
| H-32 | Conquistas | Abrir | Sem crash | | [ ] | Não | |

## E. Receitas / PDFs / apostilas

| ID | Tela/funcionalidade | Procedimento | Resultado esperado | Resultado encontrado | Status | Bloqueia? | Evidência |
|---|---|---|---|---|---|---|---|
| H-40 | Receitas | Abrir lista e 1 detalhe | Ícones/textos OK | | [ ] | Não | |
| H-41 | PDF/apostila | Abrir PDF previsto | Carrega; zoom; scroll; voltar | | [ ] | Sim* | |
| H-42 | PDF offline | Sem internet | Erro claro, sem crash | | [ ] | Não | |

\*Se apostila for conteúdo principal prometido na loja.

## F. Vídeos (área SEPARADA)

| ID | Tela/funcionalidade | Procedimento | Resultado esperado | Resultado encontrado | Status | Bloqueia? | Evidência |
|---|---|---|---|---|---|---|---|
| H-50 | Tela Vídeos | Abrir biblioteca | Lista própria (não dentro de lição) | | [ ] | Sim | |
| H-51 | Thumbnail | Conferir capas | Thumb YouTube aparece | | [ ] | Sim | |
| H-52 | Abrir Short | Abrir 1 vídeo | Player/WebView abre | | [ ] | Sim | |
| H-53 | Voltar pós-vídeo | Botão voltar | Volta à lista | | [ ] | Sim | |
| H-54 | Troca de vídeo | Abrir 2º vídeo | Conteúdo correto | | [ ] | Sim | |
| H-55 | Short `lLfcuiW32iI` | Se existir na lista | **Substituído por `akKcU1UVUYw`** | ID não no repo local — conferir Firestore/CMS | [ ] | Sim se estiver publicado | |

## G. Meditações / Programa 7 Dias (YouTube)

| ID | Tela/funcionalidade | Procedimento | Resultado esperado | Resultado encontrado | Status | Bloqueia? | Evidência |
|---|---|---|---|---|---|---|---|
| H-60 | Lista meditações | Abrir 7 itens | Títulos corretos | | [ ] | Sim | |
| H-61 | Cada um dos 7 | Abrir, play, pause, voltar | Short correto; sem MP3 local | Já testado Android (migração) — **revalidar neste APK** | [ ] | Sim | |
| H-62 | Programa 7 Dias | Abrir dias 1–7 | Mesmos Shorts; progresso OK | | [ ] | Sim | |
| H-63 | Sem internet | Abrir meditação offline | Erro claro | | [ ] | Não | |
| H-64 | Wi-Fi / 4G | Alternar rede | Reproduz | | [ ] | Não | |

## H. Perfil / Amanda / Personal / Admin

| ID | Tela/funcionalidade | Procedimento | Resultado esperado | Resultado encontrado | Status | Bloqueia? | Evidência |
|---|---|---|---|---|---|---|---|
| H-70 | Perfil aluno | Editar campos básicos | Salva | | [ ] | Não | |
| H-71 | Quem sou eu | Abrir | Conteúdo Amanda | | [ ] | Não | |
| H-72 | Exclusão conta | Fluxo (conta teste) | Conta removida / confirmação | | [ ] | Sim* | |
| H-73 | Personal | Login personal | Área gestão | | [ ] | Sim | |
| H-74 | CMS vídeos | Personal edita vídeo | Firestore atualiza | | [ ] | Não | |
| H-75 | Admin | Login admin | Roles sem acesso indevido aluno | | [ ] | Sim | |
| H-76 | Troca de perfil | Logout/login outro papel | Sem residual de sessão | | [ ] | Sim | |

## I. Notificações / permissões / rede

| ID | Tela/funcionalidade | Procedimento | Resultado esperado | Resultado encontrado | Status | Bloqueia? | Evidência |
|---|---|---|---|---|---|---|---|
| H-80 | Permissão notificação | Negar / aceitar | App não trava | | [ ] | Não | |
| H-81 | Internet lenta | Throttle | Loading; sem freeze eterno | | [ ] | Não | |
| H-82 | Sem internet na home | Abrir offline | Mensagem; cache quando houver | | [ ] | Não | |

## J. Assinatura (sandbox — sem produção)

| ID | Tela/funcionalidade | Procedimento | Resultado esperado | Resultado encontrado | Status | Bloqueia? | Evidência |
|---|---|---|---|---|---|---|---|
| H-90 | Tela planos | Abrir | Preços/catálogo; sem cobrança real | | [ ] | Não* | |
| H-91 | PAYMENTS_ENABLED | Conferir build | false em release loja até autorização | | [ ] | Sim | |

\*Compra sandbox só quando Amanda autorizar e produtos estiverem criados.

## K. Performance / crashes

| ID | Tela/funcionalidade | Procedimento | Resultado esperado | Resultado encontrado | Status | Bloqueia? | Evidência |
|---|---|---|---|---|---|---|---|
| H-100 | Scroll listas longas | Treinos/vídeos | Sem jank grave | | [ ] | Não | |
| H-101 | Duplo toque | Botões CTA | Sem navegação duplicada | | [ ] | Não | |
| H-102 | Crashlytics | Forçar erro teste (dev) | Reporta (opcional pré-loja) | | [ ] | Não | |

---

## Fluxo obrigatório “caminho feliz”

```
CADASTRO → LOGIN → HOME → CONTEÚDOS → TREINO → ÁUDIO/MEDITAÇÃO → VÍDEO → PDF → HIDRATAÇÃO → METAS → PERFIL → NOTIFICAÇÕES → LOGOUT → LOGIN
```

- [ ] Fluxo completo Aluno executado
- [ ] Fluxo Personal executado
- [ ] Fluxo Admin executado
- [ ] Sem internet coberto
- [ ] Voltar Android coberto

**Assinatura Amanda (homologação):** _______________ Data: ____/____/______  
**Assinatura técnica:** _______________ Data: ____/____/______
