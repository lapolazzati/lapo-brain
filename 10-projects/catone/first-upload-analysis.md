---
date: 2026-05-07
type: analysis
project: catone
topic: customer acquisition
status: draft
---

# Problema: Farli arrivare al primo upload

## Contesto

**Situazione attuale:**
- 0 clienti paganti
- 3 design partner attivi (bloccati su Phase A3)
- 1 nuovo lead (Angelo Colombo - non contattato)
- Nessun onboarding manuale disponibile
- Q2 target: 5 contratti entro 30 giugno (€1K MRR)

**Domanda chiave:** Come ottenere il primo upload da commercialisti che si registrano autonomamente?

## ICP Reality Check

**Chi sono:**
- Commercialisti 35-65 anni, non-digital
- Vivono in Outlook, Excel, OneDrive, Word
- Non hanno mai usato un SaaS per DD
- **NON leggeranno docs, tutorial, o configurazioni**

**Cosa vogliono:**
- Non perdere nulla (completezza > velocità)
- Rimanere in controllo (verificare e sovrascrivere l'AI)
- Tool che funziona immediatamente o abbandonano

**Comportamento d'acquisto:**
- Decisione: senior partner decide dopo che junior testa
- Abbonamento preferito vs pay-per-DD
- ~€100-150/mese se risparmia ore reali
- Discovery: passaparola, agenti software studio (Profis/TeamSystem)
- **Churn risk: alto durante onboarding, basso dopo adozione**

## Flow Attuale: Signup → First Upload

```
1. Login page (/login)
   ↓
2. Email submission
   ↓
3. isActive=false → "Richiesta ricevuta, in fase di verifica"
   ↓
4. WAIT for admin approval (BLOCKER)
   ↓
5. Admin approves: node scripts/create-user.cjs --approve --email=...
   ↓
6. Magic link email sent
   ↓
7. User clicks link → /engagements (empty state)
   ↓
8. Click "Nuova pratica"
   ↓
9. Form: P.IVA, ragione sociale, anni fiscali (slider), ambito, team, note
   ↓
10. Submit → /engagements/{id}/ingest
   ↓
11. 🎯 PRIMO UPLOAD (finalmente!)
```

**Time to first upload (best case):**
- Con admin approval immediata: 3-5 minuti
- Con admin approval ritardata: ore o giorni

**Punti di abbandono:**
1. **Pending approval screen** (67% drop atteso)
2. **Empty engagements page** (confuso, cosa fare?)
3. **7-field form before upload** (friczione cognitiva)
4. **No esempio/demo practice** (non capisce cosa farà il tool)

## Benchmark: Best Practice Onboarding SaaS B2B

Dalla ricerca su AI agents personali + copywriting skills:

**Tempo al valore (Time-to-Value):**
- Best-in-class: <2 minuti
- Accettabile: 5 minuti
- Danger zone: >10 minuti (drop >70%)

**Principi:**
1. **Immediate value before signup** (demo interattiva, sample data)
2. **Progressive disclosure** (chiedi solo il minimo necessario, poi raffina)
3. **Quick win first** (risultato tangibile entro 60 secondi)
4. **Educate in-context** (tooltips dove servono, non tutorial separati)
5. **Pre-load with defaults** (anni fiscali: ultimi 3 anni; ambito: fiscale)

## Analisi: Perché Non Arrivano al Primo Upload

### Blocker #1: Admin Approval (CRITICO)

**Codice attuale** (`lib/auth/magic-link.js:16-35`):
```javascript
if (!user) {
  // Self-registration: save email, await admin approval.
  user = await prisma.user.create({
    data: { email, name: '', isActive: false },
  });
}
if (!user.isActive) {
  return { status: 'pending' };
}
```

**Problema:**
- Ogni signup richiede intervento manuale
- Non scalabile (Lapo non può approvare 24/7)
- Commercialista riceve "in fase di verifica" → abbandona o dimentica

**Possibili soluzioni:**
1. **Auto-approve con domain whitelist** (email `@*.commercialisti.it`, `@*.consulenti.it`)
2. **Trial limitato senza approvazione** (1 pratica, 3 giorni, no export)
3. **Email verification invece di admin approval** (doppio opt-in)
4. **Calendly link nella pending screen** ("Prenota una call, ti attivo subito")

**Raccomandazione:** Opzione #2 + #4
- Auto-approve per trial (1 pratica, no export fino a payment)
- Pending screen con Calendly per design partner track
- Rimuove il blocker per self-serve, mantiene controllo per partner

### Blocker #2: Empty State Confusion

**Schermata attuale** (`app/(app)/engagements/page.js:209-226`):
```
"Nessuna pratica"
"Crea la prima pratica per iniziare la due diligence."
[Nuova pratica button]
```

**Problema:**
- Non mostra cosa fa il tool
- User non sa se vale la pena creare una pratica
- "Cosa succede dopo che clicco?"

**Soluzioni possibili:**
1. **Sample practice pre-loaded** (pratica demo con dati fittizi)
2. **Interactive tour** (frecce, highlights, "carica qui")
3. **Video demo** (15 secondi, silent, autoplay)
4. **Screenshot prima/dopo** ("Carica ZIP → Vedi risultati in 3 minuti")

**Raccomandazione:** #1 (sample practice) + #4 (screenshot)
- Pre-load pratica "Demo: Olivetti Carta S.r.l." (read-only)
- Mostra verifiche già eseguite, documenti classificati
- Banner: "Questa è una pratica di esempio. Crea la tua per iniziare"
- CTA: "Crea la tua prima pratica" (non generico "Nuova pratica")

### Blocker #3: 7-Field Form Prima dell'Upload

**Form attuale** (`app/(app)/engagements/new/page.js`):
- Codice fiscale / P.IVA (con lookup Anagrafe)
- Ragione sociale (auto-fill se trovato)
- Anni fiscali (slider da/a)
- Ambito (solo Fiscale disponibile)
- Team (assegnata a)
- Note interne

**Problema:**
- Troppi campi prima del valore
- Commercialista non ha ancora visto cosa fa il tool
- Potrebbe non avere P.IVA/CF a portata (è in fase esplorativa)

**Soluzioni possibili:**
1. **Skip form, upload diretto** (chiedi metadati dopo upload)
2. **Minimal form** (solo nome pratica, anni default ultimi 3)
3. **Split flow** (nome → upload → poi metadati)
4. **Template quick-start** ("DD tipica: ultimi 3 anni, fiscale, solo tu")

**Raccomandazione:** #3 (split flow)
- Step 1: "Nome cliente" + default (ultimi 3 anni, fiscale, solo me)
- Step 2: Upload documenti (il valore!)
- Step 3: Dopo upload, raffina metadati se serve

### Blocker #4: Nessun Onboarding In-Product

**Email sequence attuale** (marketing-onboard.md):
- 5 email spalmate su 14 giorni
- Email 1: benvenuto, cosa fa Catone
- Email 2: come funziona caricamento (giorno 2)
- Email 3: verifiche automatiche (giorno 4)
- Email 4: pannello documenti (giorno 7)
- Email 5: consigli pratici (giorno 14)

**Problema:**
- Assume che user abbia già caricato documenti
- Email 2 spiega upload, ma arriva 48h dopo signup
- ICP non legge email lunghe (abitudine: scansiona, archivia)

**Soluzioni possibili:**
1. **Onboarding checklist in-app** (sidebar: "Crea pratica ✓ → Carica ZIP → Rivedi classificazioni")
2. **Contextual tooltips** (dove serve, quando serve)
3. **Success milestones** (badge: "Primo upload!", "Prima verifica completata!")
4. **Collapse email sequence** (da 14 giorni a 3 giorni, più brevi)

**Raccomandazione:** #1 + #2 + #4
- Checklist in-app (non dismissible per prima pratica)
- Tooltips contestuali sulla pagina upload
- Email sequence: Day 0 (benvenuto), Day 1 (nudge se no upload), Day 3 (caso d'uso)

## Proposta: Nuovo Flow "Upload-First"

### Obiettivo
Ridurre **time-to-first-upload** da 3-5 minuti a **< 90 secondi**.

### Flow Riprogettato

```
1. Login page con value prop chiara
   "Carica ZIP dichiarazioni → Vedi anomalie in 3 minuti"
   ↓
2. Email submission (no approval wait)
   ↓
3. Magic link immediato (auto-approve trial)
   ↓
4. Click link → /onboarding/welcome
   ↓
5. Welcome screen:
   - "Benvenuto! Ecco cosa fa Catone" (15s video o 3 screenshot)
   - "Esplora pratica demo" (link a sample practice)
   - CTA: "Carica i tuoi documenti" (grande, verde)
   ↓
6. Click CTA → /onboarding/upload
   ↓
7. Upload page semplificata:
   - "Trascina ZIP o PDF delle dichiarazioni"
   - Nome pratica pre-compilato: "Pratica {timestamp}"
   - Default: ultimi 3 anni, fiscale, solo me
   - No altri campi
   ↓
8. Upload starts → Classificazione automatica
   ↓
9. 🎯 PRIMO UPLOAD (< 90 secondi da signup)
   ↓
10. Mentre classifica, mostra progress + educazione:
    "Catone sta classificando... Redditi SC, IVA, 770, F24..."
    ↓
11. Classificazione completa → /engagements/{id}/review
    "Rivedi classificazioni (3 documenti da confermare)"
    ↓
12. User conferma → Estrazione automatica
    ↓
13. Estrazione completa → Verifiche eseguibili
    "Pratica pronta! Esegui le verifiche fiscali"
```

**Tempo stimato:** 60-90 secondi (vs 3-5 minuti attuali)

### Modifiche Tecniche Richieste

#### 1. Auto-Approve Trial Mode

**File:** `lib/auth/magic-link.js`

**Cambiamento:**
```javascript
// Invece di isActive=false, crea trial user:
user = await prisma.user.create({
  data: {
    email,
    name: '',
    isActive: true,           // auto-approve
    accountType: 'trial',     // nuovo campo
    trialEndsAt: Date.now() + 7 * 24 * 60 * 60 * 1000, // 7 giorni
    maxPractices: 1,          // limite trial
  },
});
```

**Limiti trial:**
- 1 pratica massimo
- No export report (PPTX/DOCX/PDF)
- No team collaboration
- 7 giorni durata
- Badge "Trial" in UI
- CTA upgrade su ogni pagina (discreto)

#### 2. Onboarding Welcome Screen

**Nuovo file:** `app/(app)/onboarding/welcome/page.js`

**Contenuto:**
- Video 15 secondi (silent, autoplay, skippable)
- 3 benefit cards:
  1. "Carica ZIP → Classificazione automatica"
  2. "Verifiche incrociate in secondi"
  3. "Report pronto per il cliente"
- Link: "Esplora pratica demo" → `/engagements/demo`
- CTA primario: "Carica i miei documenti" → `/onboarding/upload`
- Link secondario: "Ho già usato Catone" → `/engagements`

#### 3. Upload-First Form

**Nuovo file:** `app/(app)/onboarding/upload/page.js`

**UI:**
- Dropzone grande (60vh)
- "Trascina ZIP o seleziona PDF"
- Sotto dropzone:
  - Input: "Nome pratica" (default: "Pratica {DD/MM/YYYY}")
  - Small text: "Anni: 2022-2024 · Ambito: Fiscale · Solo tu"
  - Link: "Modifica dettagli" (apre drawer laterale con full form)
- Submit: "Inizia classificazione"

**Comportamento:**
- User può caricare senza fill form
- Form completo opzionale (se vuole P.IVA lookup, team, anni custom)
- Metadati raffinabili dopo upload

#### 4. Sample Practice (Demo Read-Only)

**Implementazione:**
- Seed database con pratica demo (Olivetti Carta S.r.l.)
- 15 documenti classificati (Redditi SC, IVA, 770, F24, Bilancio)
- Tutte verifiche eseguite con risultati misti (2 pass, 1 warning, 1 critical)
- Banner persistente: "Pratica demo - Crea la tua per iniziare"
- Disable: edit, delete, export
- Link ogni pagina: "Crea la tua prima pratica"

**Beneficio:**
- User vede subito il valore
- Capisce workflow prima di uploadare
- Riduce "paura del foglio bianco"

#### 5. Onboarding Checklist In-App

**Componente:** Sidebar collapsible (solo per user con 0-1 pratiche)

**Checklist:**
- [x] Account creato
- [ ] Prima pratica creata
- [ ] Documenti caricati
- [ ] Classificazioni confermate
- [ ] Prima verifica eseguita
- [ ] Report esportato

**Interazione:**
- Auto-check quando completa
- Click per navigare a step successivo
- Dismissible dopo "Prima verifica eseguita"

#### 6. Contextual Tooltips

**Implementazione:** Libreria `react-joyride` o custom

**Tour punti:**
1. Upload page: "Trascina ZIP con tutte le dichiarazioni"
2. Review page: "Conferma le classificazioni (AI è 94% accurato)"
3. Verifiche page: "Esegui verifiche fiscali incrociate"
4. Export page: "Genera report per il cliente"

**Trigger:** First-time user (0 pratiche completate)

#### 7. Email Sequence Ridotta

**Nuovo timing:**
- **Day 0 (immediato):** Magic link + benvenuto (come attuale)
- **Day 1 (se no upload):** Nudge email
  - Subject: "[Catone] Hai 10 minuti? Prova con un cliente reale"
  - Body: Link a pratica demo + video 30s + CTA upload
- **Day 3 (se upload ma no verifica):** Caso d'uso
  - Subject: "[Catone] Come trovare versamenti IVA mancanti in 20 secondi"
  - Body: Screenshot verifica IVA + spiegazione

**Contenuto Day 1 (nudge):**
```markdown
Oggetto: [Catone] Hai 10 minuti? Prova con un cliente reale

---

Gentile dottore,

ieri ha attivato il suo account Catone. Ho notato che non ha ancora caricato documenti.

Se vuole vedere cosa fa il sistema senza impegno:

1. [Esplora la pratica demo](link) — una DD già completata (2 minuti)
2. Oppure carica un suo caso reale: [Nuova pratica](link)

La pratica demo mostra:
- 15 documenti classificati automaticamente (Redditi SC, IVA, 770, F24)
- 6 verifiche fiscali già eseguite
- Report di sintesi pronto

Se ha dubbi, risponda a questa email.

Buon lavoro,
Luca
dal team di Catone
```

## Metriche di Successo

**Primary metric:**
- **Time-to-first-upload:** < 90 secondi (target), < 2 minuti (acceptable)

**Secondary metrics:**
- **Signup → first upload rate:** >40% (da attuale ~10% stimato)
- **First upload → first verification rate:** >70%
- **Trial → paid conversion:** >15% (industry standard: 10-20%)

**Drop-off tracking:**
- Signup page → email sent
- Email sent → magic link click
- Magic link click → welcome screen
- Welcome screen → upload page
- Upload page → first upload
- First upload → classification confirmed
- Classification → first verification
- Trial end → payment

## Rischi & Mitigazioni

### Rischio 1: Spam/Abuse con Auto-Approve

**Scenario:** Bot o concorrenti si registrano massivamente

**Mitigazioni:**
- reCAPTCHA v3 sulla login page
- Rate limiting (max 3 signup/ora dallo stesso IP)
- Email domain validation (non temp mail)
- Trial cap: 50 utenti pending max (come attuale)
- Manual review flag per comportamenti sospetti (0 documenti upload dopo 7 giorni)

### Rischio 2: Trial User Non Convertono

**Scenario:** User testa, poi abbandona senza pagare

**Mitigazioni:**
- In-app upgrade prompts (discreti ma visibili)
- Export bloccato fino a payment (crea dipendenza se hanno già fatto DD)
- Email al giorno 5/7 trial: "2 giorni rimasti, converti ora"
- Calendly link per design partner track (se vogliono supporto)

### Rischio 3: Sample Practice Confonde

**Scenario:** User pensa sia la sua pratica, modifica dati demo

**Mitigazioni:**
- Banner persistente giallo: "Pratica demo - I tuoi dati sono in pratiche separate"
- Lock icon su ogni azione (edit, delete, export)
- Tooltip su click: "Questa è una demo. Crea la tua pratica per modificare"
- Separata visivamente (colore diverso nella lista pratiche)

### Rischio 4: Upload-First Manca Metadati Critici

**Scenario:** User carica senza P.IVA, poi serve per fatturazione

**Mitigazioni:**
- Chiedi P.IVA al momento del payment
- Link "Aggiungi dettagli cliente" nella pratica (sempre accessibile)
- Nudge quando va a export: "Aggiungi P.IVA per fattura?"

## Priorità Implementazione

### Phase 1: Quick Wins (1-2 giorni dev)
1. **Auto-approve trial mode** (rimuove blocker #1)
2. **Email nudge Day 1** (riduce drop-off dopo signup)
3. **Default form values** (ultimi 3 anni, fiscale, solo me)
4. **Welcome screen semplice** (testo + CTA, no video)

**Impact:** Riduce time-to-first-upload da 3-5 min a ~2 min

### Phase 2: Onboarding Redesign (3-5 giorni dev)
5. **Sample practice demo** (pre-seed database)
6. **Upload-first form** (split flow, metadati opzionali)
7. **Progress indicator** (checklist in-app)
8. **Contextual tooltips** (primi 4 step)

**Impact:** Porta time-to-first-upload sotto 90 secondi

### Phase 3: Conversion Optimization (2-3 giorni dev)
9. **Trial limits enforcement** (max 1 pratica, no export)
10. **In-app upgrade prompts** (banner + modal)
11. **Trial end email sequence** (day 5, day 7, day 14 scaduto)
12. **Analytics tracking** (Plausible events per ogni step)

**Impact:** Trial → paid conversion >15%

### Phase 4: Scale & Polish (ongoing)
13. **Video demo 15s** (registra + edit)
14. **Interactive tour** (Joyride o custom)
15. **A/B test email copy** (nudge, trial end)
16. **Referral program** (invita collega → sconto)

**Impact:** Riduce CAC, aumenta LTV

## Prossimi Passi

1. **Validare assunzioni** con design partner
   - Gianni: "Cosa ti avrebbe fatto caricare subito?"
   - Vincenzo: "Cosa ti ha confuso durante primo uso?"

2. **Prioritize Phase 1** (quick wins)
   - Auto-approve trial: BLOCKER removal
   - Email nudge: recovery immediato
   - Default form: friction reduction

3. **Build sample practice** (one-time seed)
   - Olivetti Carta S.r.l. (nome fittizio)
   - 2022-2024, 15 documenti
   - Verifiche miste (pass, warning, critical)
   - Deploy su staging per test

4. **Measure baseline** (prima di cambiamenti)
   - Attuale signup → first upload rate (chiedere a Gianni?)
   - Tempo medio signup → first verification
   - Trial users creati vs attivati

5. **Ship Phase 1 entro 10 maggio**
   - Test con 1-2 nuovi lead
   - Monitora metriche per 7 giorni
   - Iterate su Phase 2 in base a feedback

---

## Appendice: Competitor Benchmark

### Dyogene (AI fiscal assistant)
- **Onboarding:** Email verification → dashboard vuoto → tutorial video (8 min)
- **Time-to-value:** ~15 minuti (lungo tutorial)
- **Friction:** Alta, assume competenza tecnica

### LexRoom (legal DD platform)
- **Onboarding:** Demo account pre-loaded → esplora → crea tuo
- **Time-to-value:** < 2 minuti (explora demo)
- **Friction:** Bassa, ma target avvocati (più digital di commercialisti)

### Normo (compliance tracker)
- **Onboarding:** Questionario setup (10 domande) → dashboard
- **Time-to-value:** 5-7 minuti
- **Friction:** Media, richiede setup manuale

### Genya Dichiarativi (tax filing)
- **Onboarding:** Calendly call obbligatoria (white-glove)
- **Time-to-value:** giorni (call + setup)
- **Friction:** Altissima, ma target studi grandi

**Takeaway:**
- Catone può essere **best-in-class** con upload-first (<90s)
- Sample practice è differenziatore vs Dyogene/Normo
- Auto-approve trial batte Genya per SMB segment

---

*Documento creato: 2026-05-07*
*Autore: Andy + Lapo*
*Status: Draft per review*
