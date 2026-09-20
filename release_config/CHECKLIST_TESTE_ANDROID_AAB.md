# Checklist — instalar e testar AAB Android (3 perfis)

**App:** Método 1 Dia de Cada Vez (`com.metodo1dia.app`)  
**Data do AAB:** 19/09/2026  
**Cobrança:** desligada (`PAYMENTS_ENABLED=false` — não passou `true` no build)  
**Loja:** este AAB **não** foi enviado à Google Play.

E2E permanece **PENDENTE** até cada item ser marcado no aparelho.  
Não commite e-mail, senha, UID nem keystore.

## Pacote gerado

| Campo | Valor |
|---|---|
| AAB | `C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2\build\app\outputs\bundle\release\app-release.aab` |
| Tamanho AAB | 626.693.231 bytes (597,66 MB) |
| APK (instalar no celular) | `C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2\build\app\outputs\flutter-apk\app-release.apk` |
| Tamanho APK | 632.583.442 bytes (603,28 MB) |
| Version | `1.0.0+1` |
| Suporte | `1diadecadavezsuporte@gmail.com` |
| Privacidade | https://metodo1dia-app.web.app/privacidade.html |
| Termos | https://metodo1dia-app.web.app/termos.html |

## 0. Instalar no aparelho (sem Play)

Use o **APK release** (já gerado). Transfira o arquivo para o celular e instale, ou com cabo USB:

```bat
adb install -r "build\app\outputs\flutter-apk\app-release.apk"
```

O `.aab` não instala direto e **não** deve ir à Play neste passo. Se precisar converter o AAB:

1. Converter com [bundletool](https://github.com/google/bundletool/releases) (não versionar o JAR se baixar local):

```bat
java -jar bundletool.jar build-apks --bundle="build\app\outputs\bundle\release\app-release.aab" --output="build\app\outputs\bundle\release\app-release.apks" --mode=universal
java -jar bundletool.jar install-apks --apks="build\app\outputs\bundle\release\app-release.apks"
```

2. Alternativa de homologação local (não substitui o AAB da pasta `bundle`): `flutter install --release` só depois de um APK gerado à parte.
3. Desinstale qualquer build debug antigo do mesmo `applicationId` se o instalador recusar assinatura.

## 1. Provisionar contas (Firebase Console)

Authentication → Users → Add user (e-mail/senha). Anote **fora do Git**.

| Perfil | Depois do cadastro |
|---|---|
| Aluno | Nada. Cadastro pelo app também serve (sempre nasce aluno). |
| Personal | Firestore `users/{uid}`: `isPersonalTrainer: true`. **Não** criar `admins/{uid}`. |
| Admin Técnico | Criar `admins/{uid}` (doc vazio serve). Flag `users.isAdmin` sozinha **não** eleva. |

Sem os 3 UIDs, **não** marque E2E como PASSOU.

## 2. Aluno — no aparelho

- [ ] Login ou cadastro (checkbox legal).
- [ ] Home: saudação sem “Olá, !”.
- [ ] Treino → cronômetro → concluir → histórico.
- [ ] Hidratação: registrar copo.
- [ ] Vídeo (um Short) → play → voltar.
- [ ] Áudio → play/pause.
- [ ] Desafio: marcar **hoje**; dia futuro bloqueado.
- [ ] Evolução: uma medida.
- [ ] Abrir `/admin` (deep link/URL) → deve ir para Home.
- [ ] Configurações: Privacidade e Termos abrem as URLs oficiais.
- [ ] Logout.

**Resultado Aluno:** PENDENTE / PASSOU (só no aparelho)

## 3. Personal — outra conta, sem reutilizar sessão

- [ ] Login → destino `/personal-trainer`.
- [ ] Painel: aluno, anamnese, conteúdo, vídeos, Quem sou eu, agenda.
- [ ] Tentar `/admin` (raiz) → Central da Personal.
- [ ] `/admin/videos` pode abrir (CMS).
- [ ] Apostilas: consultar; **não** publicar (só Admin grava).
- [ ] Logout.

**Resultado Personal:** PENDENTE / PASSOU (só no aparelho)

## 4. Admin Técnico

- [ ] Login → `/admin`.
- [ ] Usuários / papéis visíveis.
- [ ] Logout no AppBar.

**Resultado Admin:** PENDENTE / PASSOU (só no aparelho)

## 5. Troca de contas

- [ ] Sair → Aluno → sair → Personal → sair → Admin.
- [ ] Sem sessão residual, guest nem “Olá, !”.

**Resultado troca:** PENDENTE / PASSOU (só no aparelho)

## 6. O que este checklist NÃO autoriza

- Enviar o AAB à Google Play.
- Ligar `PAYMENTS_ENABLED=true`.
- Marcar E2E como PASSOU sem evidência no aparelho.
- Versionar `.env`, keystore, senha ou secret.

Roteiro detalhado: `release_config/ROTEIRO_E2E_TRES_PERFIS.md`.
