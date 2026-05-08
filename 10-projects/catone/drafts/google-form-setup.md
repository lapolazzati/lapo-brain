# Setup Google Form → Auto-Onboard Catone

## 1. Crea Google Form

Link: https://forms.google.com/

**Campi form:**

1. **Email** (short answer, required, validation: email)
   - Domanda: "Email professionale"
   - Descrizione: "Useremo questa email per inviarti il link di accesso"

2. **Nome completo** (short answer, required)
   - Domanda: "Nome e cognome"
   - Descrizione: "Come vuoi essere chiamato in Catone"

3. **Nome studio** (short answer, required)
   - Domanda: "Nome dello studio"
   - Descrizione: "Es. Studio Rossi & Associati"
   - Questo diventa il nome dell'Organization

4. **Partita IVA** (short answer, optional)
   - Domanda: "Partita IVA o Codice Fiscale studio (opzionale)"
   - Descrizione: "Puoi aggiungerlo dopo"

5. **Privacy checkbox** (required)
   - Testo: "Acconsento al trattamento dei dati personali secondo la Privacy Policy di Catone"

**Impostazioni form:**
- Title: "Inizia con Catone - Due Diligence Fiscale Assistita"
- Description: "Compila il form e riceverai il link di accesso via email in pochi secondi. Nessuna carta di credito richiesta."
- Responses → "Limit to 1 response" (impedisce spam)

## 2. Collega Google Form a webhook

**Opzione A: Google Apps Script (gratis, semplice)**

1. Nel form: More → Script editor
2. Incolla questo codice:

```javascript
function onFormSubmit(e) {
  const WEBHOOK_URL = 'https://catone-onboard.vercel.app/api/onboard';
  const WEBHOOK_SECRET = 'TUO_SECRET_QUI'; // Generalo con: openssl rand -hex 32

  const responses = e.namedValues;

  const payload = {
    email: responses['Email professionale'][0],
    name: responses['Nome e cognome'][0],
    studio: responses['Nome dello studio'][0],
    piva: responses['Partita IVA o Codice Fiscale studio (opzionale)'] ? responses['Partita IVA o Codice Fiscale studio (opzionale)'][0] : null,
    secret: WEBHOOK_SECRET
  };

  const options = {
    method: 'POST',
    contentType: 'application/json',
    payload: JSON.stringify(payload),
    muteHttpExceptions: true
  };

  try {
    const response = UrlFetchApp.fetch(WEBHOOK_URL, options);
    const result = JSON.parse(response.getContentText());

    if (!result.success) {
      Logger.log('Onboard failed: ' + result.error);
      // Opzionalmente, invia email di errore all'admin
    } else {
      Logger.log('Onboard success: ' + result.user.email);
    }
  } catch (error) {
    Logger.log('Error calling webhook: ' + error.toString());
  }
}
```

3. Salva script
4. Triggers → Add trigger:
   - Function: `onFormSubmit`
   - Event source: From form
   - Event type: On form submit
5. Autorizza script quando richiesto

**Opzione B: Zapier/Make (no-code, 5 min)**

1. Google Forms trigger → Webhook action
2. Map fields: email → email, nome → name, etc.
3. Done

## 3. Deploy webhook script su Vercel

**Prerequisiti:**
- Account Vercel (gratis)
- Vercel CLI: `npm install -g vercel`

**Deploy:**

```bash
cd /workspace/group

# Crea vercel.json
cat > vercel.json << 'EOF'
{
  "version": 2,
  "builds": [
    {
      "src": "catone-auto-onboard.js",
      "use": "@vercel/node"
    }
  ],
  "routes": [
    {
      "src": "/api/(.*)",
      "dest": "catone-auto-onboard.js"
    }
  ],
  "env": {
    "DATABASE_URL": "@database_url",
    "RESEND_API_KEY": "@resend_api_key",
    "TELEGRAM_BOT_TOKEN": "@telegram_bot_token",
    "TELEGRAM_CHAT_ID": "@telegram_chat_id",
    "WEBHOOK_SECRET": "@webhook_secret",
    "APP_BASE_URL": "https://app.catone.ai"
  }
}
EOF

# Deploy
vercel --prod

# Add secrets
vercel secrets add database_url "postgresql://..."
vercel secrets add resend_api_key "re_..."
vercel secrets add telegram_bot_token "your_bot_token"
vercel secrets add telegram_chat_id "your_chat_id"
vercel secrets add webhook_secret "$(openssl rand -hex 32)"
```

**Vercel dashboard:**
- Project settings → Environment variables
- Aggiungi tutte le variabili sopra

**URL finale:** `https://catone-onboard.vercel.app/api/onboard`

## 4. Test end-to-end

**Test locale (prima di deploy):**

```bash
# In Tax-DueDiligence-Tool directory
cd /workspace/group/Tax-DueDiligence-Tool

# Copia script
cp ../catone-auto-onboard.js .

# Install deps se mancano
npm install express

# Crea .env con DATABASE_URL, RESEND_API_KEY, etc.

# Run
node catone-auto-onboard.js

# In altro terminale, testa:
curl -X POST http://localhost:3001/api/onboard \
  -H "Content-Type: application/json" \
  -d '{
    "email": "mario.test@studio.it",
    "name": "Mario Rossi Test",
    "studio": "Studio Test Rossi",
    "piva": "12345678901",
    "secret": "your_webhook_secret_here"
  }'
```

**Aspettati:**
```json
{
  "success": true,
  "organization": {
    "id": 123,
    "name": "Studio Test Rossi",
    "slug": "studio-test-rossi"
  },
  "user": {
    "id": 456,
    "email": "mario.test@studio.it",
    "name": "Mario Rossi Test",
    "role": "admin"
  },
  "magicLinkSent": true
}
```

**Check:**
1. Database: verifica org e user creati
2. Email: controlla inbox mario.test@studio.it
3. Telegram: dovresti ricevere notifica

**Test Google Form dopo deploy:**
1. Compila form con email di test
2. Submit
3. Controlla email entro 30 secondi
4. Click magic link → dovresti entrare in Catone

## 5. Condividi link con Gianni

**Link Google Form:** `https://forms.gle/ABC123` (copia da form settings)

**Messaggio WhatsApp per Gianni:**

```
Ciao Gianni,

ecco il link per far testare Catone ai tuoi contatti:
https://forms.gle/ABC123

Chi compila il form riceve il link di accesso automaticamente via email in 30 secondi.

Non serve più che mi chiami per ogni onboarding - è tutto automatico.

Fammi sapere se serve qualcosa.
Lapo
```

## 6. Monitoraggio

**Telegram notifications:** Riceverai notifica per ogni nuovo signup con:
- Nome studio
- Email
- Nome utente
- Slug organization

**Vercel logs:** Dashboard → Project → Logs per vedere richieste webhook

**Database:** Query per vedere nuovi signup:
```sql
SELECT
  o.name as studio,
  u.email,
  u.name,
  u.created_at
FROM users u
JOIN organizations o ON u.organization_id = o.id
WHERE u.created_at > NOW() - INTERVAL '24 hours'
ORDER BY u.created_at DESC;
```

## 7. Limiti & Mitigazioni

**Problema:** Spam signup
**Soluzione:**
- Google Form ha built-in "Limit to 1 response" (IP based)
- WEBHOOK_SECRET impedisce chiamate dirette
- Puoi aggiungere reCAPTCHA v3 al form

**Problema:** Email non arriva
**Soluzione:**
- Verifica catone.ai domain su Resend
- Check spam folder
- Fallback: console.log magic link se RESEND_API_KEY mancante

**Problema:** User crea account ma non usa
**Soluzione:**
- Email Day 1 nudge (già schedulato con nanoclaw)
- Trial expiry dopo 7 giorni
- Query per vedere signup non attivati

## 8. Metriche da trackare

- **Signup rate:** Form views → Submits
- **Activation rate:** Signup → Magic link click
- **Engagement rate:** Magic link click → First practice created
- **Conversion rate:** Trial start → Payment

**Plausible/Google Analytics:**
- Event: "form_submit" quando submit Google Form
- Event: "magic_link_click" quando click link (redirect via Catone)
- Event: "first_practice_created" nel Catone app

---

## Next Steps

1. Crea Google Form (10 min)
2. Deploy script su Vercel (15 min)
3. Collega Form → Script con Apps Script (5 min)
4. Test con tua email (2 min)
5. Manda link a Gianni
6. Monitor Telegram notifications

**Timeline:** 30-40 minuti totali

**Costo:** €0 (Google Forms gratis, Vercel hobby tier gratis, Resend 100 email/giorno gratis)
