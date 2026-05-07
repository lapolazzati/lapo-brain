---
date: 2026-05-07
type: learnings
project: catone
topic: customer email updates
---

# Catone Customer Email - Learnings

## Context

Prima email ai clienti dopo 3 settimane (15 aprile - 7 maggio 2026). Conteneva: nuova verifica VL8/VL33, UI redesign (Coda revisione), rename Documenti→Archivio, export PPTX, protezione classificazioni manuali.

## Key Learnings - Voice & Tone

### ❌ Non funziona:

1. **Codici tecnici senza contesto**
   - "Il sistema verifica che VL8 corrisponda a VL33"
   - I commercialisti conoscono i codici, ma l'email non è un manuale

2. **"Perché è cruciale" + spiegazione ovvia**
   - "Perché è cruciale: se la società dichiara..."
   - Sanno già perché è cruciale, non serve spiegare l'ovvio

3. **Marketing speak**
   - "Siamo entusiasti di..."
   - "Con piacere presentiamo..."
   - Tono troppo SaaS, non colleghi

4. **Troppo lungo**
   - V1: 650 parole → troppo dettaglio tecnico
   - Obiettivo: <500 parole

5. **Micro-dettagli implementativi**
   - "I pulsanti ora usano scale(0.96) invece di translateY(0.5px)"
   - Nessuno se ne accorge o se ne importa

### ✅ Funziona:

1. **Beneficio + risk assessment frame**
   - "È un modo per capire se la target gestisce correttamente la contabilità fiscale"
   - Non "perché è importante" ma "come lo usi nella DD"

2. **Prima/Dopo con esempio concreto**
   - "Prima: tre card confuse. Adesso: verdetto rosso/giallo/verde"
   - "Su 180 documenti, vedete subito se 3 bloccanti o zero problemi"

3. **Tono collega al lunedì mattina**
   - "Sono passate alcune settimane"
   - "Niente di rivoluzionario, ma..."
   - No fluff, dritto al punto

4. **Raggruppare micro-miglioramenti**
   - Non "5 piccole cose", ma "Interfaccia riprogettata" con esempio d'uso

5. **Screenshot placeholder espliciti**
   - Mostra dove servono le immagini
   - Alternativa: text description molto visiva

## Email Structure Template

```
Oggetto: [Catone] {cosa più importante} + {seconda cosa}
Non: "Aggiornamento settimanale"

Intro (2 frasi):
- Quanto tempo è passato
- Cosa abbiamo fatto (alto livello)

Sezioni (max 5):
H2: {Beneficio chiaro}
P1: Cosa fa
P2: Come si usa nella DD / perché cambia il workflow
[Screenshot placeholder]

Footer:
- "Già attivi, non serve fare nulla"
- Firma Luca dal team
```

## Iterazioni su Verifica VL8/VL33

### V1 (troppo tecnico):
> "Il sistema verifica che VL8 corrisponda a VL33 dell'anno precedente"

### V2 (spiega troppo l'ovvio):
> "Perché è cruciale: se la società dichiara 50k ma l'anno prima era 35k..."

### V3 FINALE (risk assessment):
> "È un modo per capire se la target gestisce correttamente la contabilità fiscale o se ci sono errori ricorrenti"

**Lezione:** Non spiegare perché è importante (ovvio). Spiega come usano questa info per valutare il rischio d'impresa.

## Iterazioni su UI Changes

### V1 (micro-dettagli inutili):
> "I pulsanti reagiscono visivamente, contatori usano tabular-nums, barre più fluide"

### V2 (venduto come redesign):
> **Prima:** Card confuse, lista piatta
> **Adesso:** Verdetto rosso/giallo/verde, raggruppamento per gravità
> **Esempio:** Su 180 documenti, vedi subito se 3 bloccanti o zero

**Lezione:** Vendi il redesign con prima/dopo + esempio d'uso concreto, non lista di micro-miglioramenti.

## Archivio Rename

### V1 (troppo breve):
> "Documenti ora si chiama Archivio"

### V2 FINALE:
> "La sezione 'Documenti' ora si chiama 'Archivio'.
> Stesso contenuto, nome più chiaro: un archivio è dove si conservano i file del cliente, 'documenti' è troppo generico."

**Lezione:** Anche per rename semplice, spiega il ragionamento (perché Archivio è più chiaro).

## Tech Stack Setup

- **Resend API** per invio email
- **Template HTML inline** matching onboarding style (Bodoni Moda, palette stone/amber)
- **Dominio non verificato** → usa `onboarding@resend.dev` per test, poi verifica `catone.ai`
- **Node.js script** con helper functions (`p()`, `h2()`, `bold()`, `img()`)

## Automazione Friday Morning

**Scheduled task:** Ogni venerdì 9:00 Roma (7:00 UTC)
- Git pull Tax-DueDiligence-Tool
- Estrai commit ultimi 7 giorni
- Filtra client-facing (no refactoring, CI/CD, tests)
- Genera email stile Catone
- Invia preview a lapo@catone.ai
- Aspetta approvazione prima di mandare ai clienti

**Task ID:** 1778175502967-ext1at.json

## Screenshot Needs

Per email future, aggiungere:
1. Verifica VL8 con "Non applicabile"
2. Banner rosso/giallo/verde Coda revisione
3. Menu "Archivio"
4. Esportazione PPTX

## Files Created

- `/workspace/group/catone-update-aprile-maggio.md` - V1 (650 parole)
- `/workspace/group/catone-update-v2.md` - V2 (420 parole, con screenshot)
- `/workspace/group/catone-update-final-final.js` - V3 FINALE (Node.js + Resend)

## Customer List

**Per ora:** Solo lapo.lazzati@gmail.com (test)

**Prossimi passi:**
1. Verificare dominio catone.ai su Resend
2. Cambiare from: a `luca@catone.ai`
3. Sostituire destinatari con lista clienti reale

## Voice DNA

**Language:** Italiano 100%
**Tone:** Collega preparato al lunedì mattina
**Anti-patterns:** Marketing speak, "siamo entusiasti", spiegare l'ovvio
**Firma:** Luca dal team di Catone
**Max words:** 500
**Oggetto:** Specifico, mai generico

**Template framing:**
- Non "perché è importante" → "come lo usi nella DD"
- Non "abbiamo aggiunto" → "ora potete"
- Non micro-dettagli → redesign con prima/dopo
