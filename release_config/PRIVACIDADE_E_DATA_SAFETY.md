# Privacidade, LGPD e Data Safety — Método 1 Dia de Cada Vez

> Documento-base para publicação. Revise com apoio jurídico antes de publicar.
> A política de privacidade precisa ficar hospedada em uma **URL pública**
> (exigência de Play Store e App Store) — por exemplo em uma página do site.

## 1. Dados que o app coleta (auditado no código)

| Dado | Onde/por quê | Serviço |
|---|---|---|
| E-mail e senha | Cadastro e login | Firebase Authentication |
| Nome, peso, altura, medidas, metas, treinos, corridas, hidratação | Funcionalidade do app | Cloud Firestore |
| Localização (GPS) | Registrar distância/trajeto da corrida (só em uso) | geolocator |
| Fotos (câmera/galeria) | Foto de perfil, progresso, scanner de alimentos | image_picker |
| Eventos de uso | Métricas de produto | Firebase Analytics |
| Relatórios de falha | Estabilidade | Firebase Crashlytics |
| Texto enviado à IA | Treinadora virtual (Amanda) | Cloud Function → OpenAI |
| Token de notificação | Envio de push/lembretes | Firebase Messaging |

**Não coletado:** áudio/microfone (não há gravação); dados de saúde de wearables
(o pacote `health` não está integrado); IDFA/rastreamento entre apps.

## 2. Política de Privacidade (rascunho)

**Coleta e uso.** Coletamos os dados acima exclusivamente para operar o app:
autenticar sua conta, salvar seu progresso, registrar corridas, personalizar
recomendações e melhorar a estabilidade. Não vendemos seus dados.

**Localização.** Usada apenas enquanto você usa a tela de corrida, para medir
distância e trajeto. Não rastreamos sua localização em segundo plano.

**Fotos.** Usadas apenas quando você escolhe tirar/enviar uma foto. Ficam
associadas à sua conta.

**Compartilhamento.** Usamos processadores (Google Firebase; OpenAI para a
funcionalidade de IA). Cada um trata dados conforme suas próprias políticas.

**Direitos (LGPD).** Você pode acessar, corrigir, exportar e **excluir** seus
dados e sua conta a qualquer momento pelo app (Perfil → Conta), ou solicitando
por e-mail. A exclusão remove seus dados dos nossos sistemas ativos.

**Saúde.** O app é de bem-estar e atividade física e **não substitui avaliação
médica**. Consulte um profissional antes de iniciar exercícios ou dietas.

**Menores.** O app não é direcionado a menores de idade sem consentimento dos
responsáveis.

**Contato do controlador:** [NOME/EMPRESA] — [e-mail de privacidade].

## 3. Mapa para o formulário "Data Safety" (Play Console)

- **Dados coletados:** sim.
- **Categorias:** Informações pessoais (e-mail, nome); Localização (aproximada
  e precisa, em uso); Fotos; Informações de saúde e fitness (peso, treinos);
  Atividade no app; Registros de falhas.
- **Criptografia em trânsito:** sim (Firebase/HTTPS).
- **Exclusão de dados:** sim — o usuário pode solicitar exclusão da conta.
- **Compartilhado com terceiros:** com processadores (Google, OpenAI), não para
  publicidade.
- **Localização em segundo plano:** **NÃO** (declarar como "em uso" apenas).

## 4. App Store — Privacy Nutrition Labels

- **Data Used to Track You:** Nenhum (não há IDFA/ATT).
- **Data Linked to You:** e-mail, nome, saúde/fitness, localização (em uso),
  fotos, uso, diagnósticos.
- **Data Not Linked to You:** —
- Preencher em App Store Connect → App Privacy.

## 5. Checklist de loja

**Play Store**
- [ ] Política de privacidade em URL pública
- [ ] Formulário Data Safety preenchido (seção 3)
- [ ] Se ativar background location no futuro: declaração de permissão + vídeo
- [ ] Classificação de conteúdo (questionário)
- [ ] AAB assinado com keystore de upload

**App Store**
- [ ] Privacy Nutrition Labels (seção 4)
- [ ] `ITSAppUsesNonExemptEncryption=false` no Info.plist (já no snippet)
- [ ] Descrições de permissão (câmera, fotos, localização) — já no snippet
- [ ] Conta Apple Developer + certificado + provisioning para o IPA
