# Relatório — Quem Sou Eu / Conheça a Amanda

## O que já existia
- Rota `/amanda/perfil` → `AmandaProfileScreen`
- Painel `/admin/amanda-profile` → `AmandaProfileEditScreen`
- Fotos: `amanda_assets` + Storage `public/amanda_assets/`
- Textos: Firestore `amanda_profile/main`
- Galeria com lightbox

## O que foi reaproveitado
- Toda a feature `personal_amanda`
- Providers, repositório, categorias de foto (capa, perfil, galeria, trajetória)
- Entradas na Central da Personal e Admin

## O que foi criado / expandido
- Conteúdo completo da Amanda em **seções** (história, formação, método, filosofia, contato etc.)
- Defaults no modelo (não ficam “presos” se houver doc vazio — salvos no Firebase ao editar)
- CTA **Quero começar** configurável: WhatsApp / URL / Planos
- Instagram pessoal + Instagram do Método
- Cards de formação, passos de acompanhamento, frases de destaque
- UI “Editar Quem Sou Eu” com seções expansíveis
- Labels na Central: **Editar Quem Sou Eu**

## Firebase
- Documento: `amanda_profile/main` (merge)
- Assets: `amanda_assets` + Storage (inalterado na regra)

## Imagens necessárias (painel Fotos da Amanda)
| Categoria | Uso |
|-----------|-----|
| `capa` | Hero |
| `principal` | Avatar |
| `profissional` | Seção “Por que Personal” (fallback) |
| `trajetoria` / `galeria` / `treinos` | Galeria e história |

URLs opcionais por seção também editáveis no painel de textos.

## Testes
- Estrutura de seções + edição alinhada ao modelo
- Persistência: salvar no painel → reabrir Quem Sou Eu
- Pendente em device: Instagram/WhatsApp reais após preencher números/URLs

## Pendências
- Amanda salvar uma vez o perfil no app para gravar defaults no Firestore
- Configurar WhatsApp e revisar links Instagram no painel
- Enviar capa/perfil/galeria em Fotos da Amanda
