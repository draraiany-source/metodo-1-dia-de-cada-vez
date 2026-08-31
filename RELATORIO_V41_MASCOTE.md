# Relatório V41 — Substituição da mascote Lili Fit (arte oficial)

> Ambiente sem Flutter SDK/rede: `flutter pub get`/`analyze` seguem para a sua
> máquina ou o CID (build.yml). O que segue foi validado por análise estática e
> inspeção real das imagens (PIL).

## 1. Material recebido
`Lili_Fit_Mascote_Organizada_2.zip` — 25 PNGs **1024×1024 RGBA**, cantos
transparentes, recorte limpo (verificado imagem a imagem): 18 em `png/` +
7 em `extras/`. Nomes já batem com o sistema centralizado da v35.

## 2. Integração REAL feita (não só cópia de arquivos)
O app renderiza a mascote por dois caminhos; alimentei os dois:
- **`assets/images/mascote/avatar_*.png` (18 arquivos)** — usados por 34 telas
  via o widget `LiliMascot`. **Conteúdo substituído** pela arte nova mapeada
  pose a pose. Assim as 34 telas mostram a nova Lili **sem editar código**.
- **`assets/mascot/png/` + `assets/mascot/extras/`** — fonte oficial do sistema
  centralizado (`MascotWidget`/`MascotAssets`). Placeholders substituídos pela
  arte real; extras adicionados.
- **`MascotConfig.useNewMascot = true`** — ativa a arte nova como oficial, com
  fallback automático (nunca quebra por asset ausente).
- **Nome preservado:** a arte nova É a Lili Fit; `MascotConfig.name` continua
  "Lili Fit" (corrigido para não virar "NOVA MASCOTE").
- **pubspec:** `assets/mascot/extras/` declarado.
- **Acesso centralizado:** `MascotAssets` ganhou constantes para as 7 poses
  extras + squat/running/dumbbell_seated.

## 3. Verificação final
- ✅ Todos os constantes de mascote em `AppAssets` resolvem para arquivo real.
- ✅ Nenhum caminho de mascote referenciado no código está quebrado.
- ✅ As 15 poses do enum resolvem nos dois lados (novo e legado).
- ✅ 43 imagens (18 legado + 18 png + 7 extras) validadas: 1024² RGBA, íntegras.
- ✅ Nenhuma arte antiga da Lili sobrou no projeto (bytes substituídos; backup
  guardado fora do entregável).
- ✅ Folha de contato gerada: 25 poses, personagem consistente, sem distorção.

## 4. Poses (mapa nova arte → uso)
`mascot_default`=padrão, `welcome`=onboarding/boas-vindas, `pointing`=orientando,
`thumbs_up`=incentivo, `celebrating`=conquista, `heart`=coração/motivação,
`hydration`=água, `dumbbell`/`strong`/`squat`/`dumbbell_seated`=treino,
`running`=corrida, `meditation`=descanso, `sad`=erro/vazio, `trophy`/`queen`=
premium/conquista, `checklist`=metas, `profile`=perfil; extras: `calendar`,
`healthy_food`, `meal_prep`, `progress`, `thinking`, `medal`, `promo`.

## 5. Sobre a organização em pasta (nota honesta)
Você sugeriu `assets/images/lily_fit/` com nomes `lily_fit_*`. Mantive
`assets/mascot/` + `assets/images/mascote/` porque **34 telas e o sistema
centralizado já apontam para lá**, e o próprio pacote foi exportado com esses
nomes — criar uma 3ª pasta exigiria reescrever 34+ telas sem ganho funcional e
com risco à estabilidade. A integração pedida está feita (arte nova em todas as
telas, centralizada, com fallback). Se ainda preferir a pasta/nome `lily_fit_*`,
faço a renomeação + ajuste das referências como passo dedicado — é só confirmar.

## 6. Pendente
- **Ícones (item 2):** aguardando seu upload ("depois vou mandar os ícones").
  Não criei `assets/icons/` nem inventei ícones. Quando enviar, integro igual.
- Build real (`analyze`) na sua máquina/CI para o carimbo final de "compila".
