# COMO TESTAR NO CELULAR — passo a passo simples

Este projeto já vem com um "robô de compilação" embutido (GitHub Actions). Você
NÃO precisa instalar Flutter nem programar nada. O robô monta o app na nuvem e
te devolve o APK pronto para instalar no Android.

São 3 etapas: (1) criar conta e repositório, (2) subir esta pasta, (3) baixar o
APK. Leva ~15 min na primeira vez.

---

## Jeito mais fácil (sem linha de comando): GitHub Desktop

### 1) Conta + programa
- Crie uma conta grátis em https://github.com (se ainda não tem).
- Baixe e instale o **GitHub Desktop**: https://desktop.github.com
  (é um programa com botões, sem terminal).
- Abra o GitHub Desktop e faça login com sua conta.

### 2) Subir o projeto
- Descompacte o ZIP que recebi (vai virar a pasta `metodo_1_dia`).
- No GitHub Desktop: **File → New repository** OU **Add → Add existing
  repository** e aponte para a pasta `metodo_1_dia`.
  - Se ele disser que não é um repositório, clique em **"create a repository"**.
- Nome: `metodo_1_dia`. Deixe como **Private**. Clique em **Create repository**.
- Ele vai listar todos os arquivos. Clique em **Commit to main** (embaixo).
- Clique em **Publish repository** (no topo). Deixe "Keep this code private"
  marcado. Confirme.
- Pronto: seus arquivos estão no GitHub.

### 3) Rodar o robô e baixar o APK
- No navegador, abra seu repositório em github.com (o GitHub Desktop tem um
  botão **"View on GitHub"**).
- Clique na aba **Actions** (no topo).
- Você verá o workflow **build** rodando (ou clique nele → **Run workflow**).
- Espere terminar (uns 5–10 min; a bolinha fica verde ✅ ou vermelha ❌).
- Clique na execução e role até **Artifacts** (rodapé). Baixe:
  - **android-apk** → dentro tem o `app-release.apk` e `app-debug.apk`.
  - **analyze-log** → o arquivo `analyze.txt` (importante, ver abaixo).
- Transfira o `.apk` para o celular Android e instale (permita "fontes
  desconhecidas" se pedir).

---

## MUITO IMPORTANTE — sobre a primeira vez

Como este código nunca foi compilado, é **provável que a primeira tentativa
falhe** (bolinha vermelha ❌) e o APK não seja gerado ainda. **Isso é esperado
e faz parte do processo.**

Quando isso acontecer:
1. Baixe mesmo assim o artefato **analyze-log** (`analyze.txt`).
2. Me mande o conteúdo desse arquivo aqui.
3. Eu corrijo os erros reais em lote e te devolvo os arquivos.
4. Você atualiza no GitHub Desktop (**Commit → Push**) e o robô roda de novo.

Repetimos isso até a bolinha ficar **verde** e o APK instalar. Aí sim está
pronto para rodar.

---

## Alternativa pelo site (sem instalar o GitHub Desktop)
Em github.com → **New repository** → depois **"uploading an existing file"** →
arraste os arquivos. Obs.: o site sobe no máximo 100 arquivos por vez, então
pode ser preciso repetir; por isso o GitHub Desktop é mais fácil para este
projeto (são muitos arquivos).

## Observações honestas
- O APK "release" gerado é assinado com chave de **teste** (serve para instalar
  e testar, **não** para publicar na Play Store — isso exige seu keystore).
- iOS/iPhone: o robô também compila, mas gerar um app instalável no iPhone
  exige conta Apple Developer paga (certificado). Para testar, comece pelo
  Android.
- Firebase: o app abre e funciona; recursos de nuvem só ligam depois que você
  colocar os arquivos do Firebase (ver `README_BUILD_ANDROID_IOS.md`).
