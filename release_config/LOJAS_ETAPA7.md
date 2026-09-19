# Etapa 7 — Material de lojas e conformidade

Não publicar o app ainda. Não ativar cobrança. Não preencher Data Safety / App Privacy com suposição.

E-mail oficial: `1diadecadavezsuporte@gmail.com`  
Privacidade: `https://metodo1dia-app.web.app/privacidade.html`  
Termos: `https://metodo1dia-app.web.app/termos.html`  
Site: `https://metodo1dia-app.web.app`

Após corrigir os HTML locais, republicar só o Hosting:

`firebase deploy --only hosting --project metodo1dia-app`

---

## Google Play — checklist

| Item | Situação |
|---|---|
| Nome | Método 1 Dia de Cada Vez (título até 50). Launcher atual: “Método 1 Dia” |
| Descrição curta / completa | Rascunho abaixo |
| Categoria sugerida | Saúde e fitness (confirmar na Console) |
| E-mail de suporte | 1diadecadavezsuporte@gmail.com |
| Site | https://metodo1dia-app.web.app |
| Política de privacidade | URL acima (republicar Hosting depois desta etapa) |
| Ícone 512 | PENDENTE — falta `assets/app_icon/app_icon.png` 1024 |
| Screenshots | PENDENTE — ver plano |
| Feature graphic 1024×500 | PENDENTE |
| Classificação indicativa | PENDENTE — questionário IARC |
| Data Safety | PENDENTE — usar só a tabela verificada |
| Anúncios | Não há SDK de anúncio. Analytics sem Advertising ID |
| Acesso para revisão | PENDENTE — conta aluna de teste |
| Exclusão de conta | Botão no app; URL da política |
| IAP | Estrutura existe; `PAYMENTS_ENABLED=false`. Não declarar IAP ativo até ligar |

### Data Safety — fatos verificados (não é o formulário preenchido)

Preencha a Console só depois de revisar com jurídico.

Coletados e ligados à conta, quando o recurso é usado:

- Nome, e-mail
- Fotos (perfil, progresso, refeição, chat)
- Fitness (treinos, hidratação, peso/medidas informados no app)
- Localização precisa só em uso (corrida GPS). Sem segundo plano
- Mensagens in-app com a Personal
- Token de notificação
- Diagnóstico (Crashlytics) e interação (Analytics), sem AD_ID

Processadores: Google Firebase; OpenAI via Functions quando configurada; RevenueCat quando cobrança estiver ligada.

Não verificado / não preencher como se fosse fato:

- HealthKit / Health Connect (não integrados)
- Login Google (pacote no pubspec, sem uso no `lib`)
- Microfone (sem gravação no código)
- Venda de dados
- Rastreamento entre apps / IDFA

Criptografia em trânsito: HTTPS/Firebase.  
Exclusão: sim, no app; retenções listadas na política.

---

## App Store — checklist

| Item | Situação |
|---|---|
| Nome | Método 1 Dia de Cada Vez |
| Subtítulo | Rascunho abaixo |
| Descrição / keywords | Rascunho abaixo |
| Categoria | Health & Fitness (confirmar) |
| URL de suporte | mailto ou página do Hosting + e-mail |
| URL da Política | mesma URL HTTPS |
| Screenshots | PENDENTE |
| Ícone 1024 | PENDENTE (`Icon-App-1024` referenciado; PNG 1024 do app ainda não gerado pelo fluxo oficial) |
| Classificação etária | PENDENTE |
| App Privacy | PENDENTE — `PrivacyInfo.xcprivacy` existe; revisar Health (HealthKit não está no app) |
| IAP | Não ativar até autorização |
| TestFlight | PENDENTE — build iOS |
| Review notes | Conta de teste PENDENTE |
| ATT / tracking | `NSPrivacyTracking=false` |

---

## Textos — Google Play (rascunho)

**Título:** Método 1 Dia de Cada Vez

**Curta (80):** Treinos, hidratação, evolução e hábitos. Um dia de cada vez.

**Completa:**

Método 1 Dia de Cada Vez é um aplicativo de hábitos e treino para o dia a dia.

No app você encontra:

- Home e navegação da sua rotina
- Treinos com cronômetro
- Hidratação
- Registro de evolução (peso e medidas)
- Receitas e organização alimentar
- Desafio semanal e Programa 7 Dias
- Vídeos e áudios
- Perfil e configurações, inclusive exclusão da conta

Há conteúdos da Personal Amanda e avisos de que treino, alimentação e qualquer estimativa não substituem profissional de saúde. O app não promete resultado físico.

Planos e assinatura existem na estrutura do app. A cobrança nas lojas permanece desligada até autorização.

Suporte: 1diadecadavezsuporte@gmail.com  
Privacidade: https://metodo1dia-app.web.app/privacidade.html

Não incluímos na vitrine recursos que ainda dependem de servidor (IA na nuvem e calorias por foto) até o teste real passar.

---

## Textos — App Store (rascunho)

**Nome:** Método 1 Dia de Cada Vez  
**Subtítulo:** Treino e hábitos, um dia de cada vez  
**Promotional text:** Organize treino, água e evolução no seu ritmo.  
**Descrição:** igual ao texto completo da Play, em português.  
**Keywords (100 caracteres, sem repetir o nome):** treino,habitos,hidratacao,fitness,evolucao,desafio,receitas,bem estar,cronometro

---

## Plano de screenshots

Capturar em aparelho/emulador com conta de demonstração, sem e-mail real, sem foto pessoal, sem anamnese real.

1. Home  
2. Treinos / cronômetro  
3. Hidratação  
4. Evolução (peso vazio ou número fictício óbvio de demo)  
5. Desafio  
6. Vídeos  
7. Perfil / Configurações (privacidade e excluir conta visíveis)

Não usar tela quebrada, dados de aluna real, conversa da Personal com nome verdadeiro, nem resultado de IA inventado.

Tamanhos típicos (produzir na hora do envio):

- Play telefone: 1080×1920 ou 1440×2560  
- Play destaque: 1024×500  
- App Store iPhone 6.7": 1290×2796  
- App Store iPad: se for enviar iPad

---

## Ícone e splash

- SVGs em `assets/app_icon/`  
- Falta raster 1024 PNG e rodar `flutter_launcher_icons` / `flutter_native_splash`  
- Android label e iOS display name: “Método 1 Dia”  
- Package: `com.metodo1dia.app`  
- Splash nativo hoje: cor `#111111` sem marca se o PNG não existir

---

## Permissões (auditadas)

Usadas: internet, câmera, fotos, localização em uso (corrida), notificações, vibração, wake lock, billing (plugin).  
Removido nesta etapa: texto de microfone no iOS (não há gravação).  
Não pedir tracking.
