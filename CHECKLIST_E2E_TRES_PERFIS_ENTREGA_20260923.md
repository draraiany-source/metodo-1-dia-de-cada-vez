# CHECKLIST E2E — TRÊS PERFIS (ENTREGA PROGRAMADOR)
## Método 1 Dia de Cada Vez — 23/09/2026

**Regra:** marcar PASSOU só com teste real na plataforma indicada.  
**Senhas:** nunca neste arquivo — só canal seguro.

| Campo | Preencher |
|---|---|
| Data execução | |
| Executor | |
| Build / commit | |
| Web homolog URL | https://metodo1dia-app--homologacao-cw9j2u83.web.app |
| APK usado | `app-arm64-v8a-release.apk` ou regenerado |
| Conta Aluna (e-mail) | |
| Conta Personal (e-mail) | |
| Conta Admin (e-mail) | |

Legenda: `[ ]` pendente · `[P]` passou · `[F]` falhou · `N/A`

---

## A) ALUNA — Web

| # | Caso | Web |
|---|---|---|
| A1 | Cadastro / login | [ ] |
| A2 | Recuperação de senha | [ ] |
| A3 | Home / navegação abas | [ ] |
| A4 | Treinos / exercício / Lily | [ ] |
| A5 | Vídeo YouTube abre | [ ] |
| A6 | Meditação (ordem 1–7) | [ ] |
| A7 | Áudio / meditação player | [ ] |
| A8 | Cronômetro | [ ] |
| A9 | Desafio semanal | [ ] |
| A10 | Hidratação + histórico | [ ] |
| A11 | Receitas / PDF | [ ] |
| A12 | Calendário / metas / conquistas | [ ] |
| A13 | Anamnese | [ ] |
| A14 | Agenda / consultoria | [ ] |
| A15 | Chat | [ ] |
| A16 | Quem sou eu | [ ] |
| A17 | Planos (UI; sem cobrança real) | [ ] |
| A18 | Logout → login; Voltar não reabre protegida | [ ] |

## A) ALUNA — Android

Repetir A1–A18 com coluna Android: botão/gesto Voltar em cada fluxo.

---

## B) PERSONAL — Web

| # | Caso | Web |
|---|---|---|
| P1 | Login Personal | [ ] |
| P2 | Dashboard; **Sair** visível | [ ] |
| P3 | Voltar interno / hub | [ ] |
| P4 | Voltar sistema na raiz **não** abre Aluna | [ ] |
| P5 | CMS: vídeo / meditação / receita | [ ] |
| P6 | Alunas / anamnese / agenda (escopo) | [ ] |
| P7 | Sem rotas Admin técnico | [ ] |
| P8 | Logout → login; sem histórico protegido | [ ] |

## B) PERSONAL — Android

Repetir P1–P8.

---

## C) ADMIN — Web  ⚠️ BLOQUEADOR HISTÓRICO

| # | Caso | Web |
|---|---|---|
| D1 | Login Admin | [ ] |
| D2 | **Sair** visível e funcional | [ ] |
| D3 | Telas internas: Voltar | [ ] |
| D4 | Raiz: Voltar **não** abre Aluna/Personal | [ ] |
| D5 | Painel / usuários / cupons (somente leitura assinaturas) | [ ] |
| D6 | Logout → login; sem histórico protegido | [ ] |
| D7 | Sem dados de aluna indevidos | [ ] |

## C) ADMIN — Android

Repetir D1–D7. **Obrigatório** antes de marcar BLK-01 como resolvido.

---

## D) CRITÉRIO DE ACEITE GLOBAL

- [ ] Aluna Web + Android sem `[F]` crítico  
- [ ] Personal Web + Android Voltar/Sair `[P]`  
- [ ] Admin Web + Android Voltar/Sair `[P]`  
- [ ] Prints anexados (Drive)  
- [ ] Nenhuma senha neste checklist  

**Status deste documento na auditoria 23/09:** todos os itens **pendentes** (E2E não executado nesta etapa).
