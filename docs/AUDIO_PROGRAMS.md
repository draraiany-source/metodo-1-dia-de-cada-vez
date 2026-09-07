# Audios & Meditacoes — Programa 7 Dias

## Storage
programs/programa_7_dias_um_dia_de_cada_vez/audios/*.mp3

## Assets locais (fallback)
assets/audio_programs/*.mp3

## Firestore
programs/{id}
programs/{id}/audios/{audioId}
programs/{id}/private/audios
users/{uid}/programProgress/{programId}

## Seed / upload
1. Coloque service account ou ADC
2. cd tools/audio_seed
3. npm i firebase-admin
4. node upload_and_seed.js metodo1dia-app.appspot.com

## Rotas
/audios-meditations
/audio-programs/:programId
/audio-programs/:programId/play/:audioId