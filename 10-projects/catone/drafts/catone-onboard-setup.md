# Catone Auto-Onboard Setup (Google Form → Production)

## Architettura

```
Google Form
    ↓
Google Apps Script (webhook trigger)
    ↓
POST https://catone.ai/api/onboard
    ↓
Next.js API route → Creates org + user + magic link
    ↓
Resend email + Telegram notification
```

**Deploy:** L'endpoint `/api/onboard` gira **dentro il container app esistente** (Hetzner), non su Vercel separato.

---

## Step 1: Deploy API route (già fatto)

Il file è qui: `app/api/onboard/route.js`

**Deploy su production:**

```bash
# SSH nel server Hetzner
ssh catone

# Pull latest code
cd ~/app
git pull origin main

# Rebuild + restart
cd deploy
./deploy.sh
```

**Verify endpoint:**

```bash
curl -X POST https://catone.ai/api/onboard \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@studio.it",
    "name": "Mario Test",
    "studio": "Studio Test",
    "piva": "12345678901",
    "secret": "your_webhook_secret"
  }'
```

Aspettati:
```json
{
  "success": true,
  "organization": { "id": 123, "name": "Studio Test", "slug": "studio-test" },
  "user": { "id": 456, "email": "test@studio.it", "name": "Mario Test", "role": "admin" },
  "magicLinkSent": true
}
```

---

## Step 2: Aggiungi environment variables

**Nel server Hetzner:**

```bash
ssh catone
cd ~/app/deploy
nano .env.production
```

**Aggiungi queste variabili:**

```bash
# Webhook secret (genera con: openssl rand -hex 32)
WEBHOOK_SECRET=your_generated_secret_here

# Telegram notification (opzionale)
TELEGRAM_BOT_TOKEN=your_bot_token
TELEGRAM_CHAT_ID=your_chat_id
```

**Restart app per caricare nuove env vars:**

```bash
docker compose restart app
```

---

## Step 3: Crea Google Form

**Link:** https://forms.google.com/

### Campi form:

1. **Email professionale** (short answer, required, email validation)
   - Descrizione: "Useremo questa email per inviarti il link di accesso"

2. **Nome e cognome** (short answer, required)
   - Descrizione: "Come vuoi essere chiamato in Catone"

3. **Nome dello studio** (short answer, required)
   - Descrizione: "Es. Studio Rossi & Associati"

4. **Partita IVA o Codice Fiscale** (short answer, optional)
   - Descrizione: "Puoi aggiungerlo dopo se non ce l'hai a portata"

5. **Privacy** (checkbox, required)
   - Testo: "Acconsento al trattamento dei dati personali secondo la Privacy Policy di Catone"

### Impostazioni form:

- **Title:** "Inizia con Catone - Due Diligence Fiscale Assistita"
- **Description:**
  ```
  Compila il form e riceverai il link di accesso via email in pochi secondi.
  Nessuna carta di credito richiesta.
  ```
- **Settings → Responses:**
  - ✅ "Limit to 1 response" (impedisce spam dallo stesso IP)
  - ✅ "Collect email addresses" (Google chiede conferma email)

---

## Step 4: Collega Google Form → Webhook

### Opzione A: Google Apps Script (gratis, 5 minuti)

1. Nel Google Form: More (⋮) → **Script editor**

2. Incolla questo codice:

```javascript
const WEBHOOK_URL = 'https://catone.ai/api/onboard';
const WEBHOOK_SECRET = 'PASTE_YOUR_SECRET_HERE'; // Da .env.production

function onFormSubmit(e) {
  const responses = e.namedValues;

  const payload = {
    email: responses['Email professionale'][0],
    name: responses['Nome e cognome'][0],
    studio: responses['Nome dello studio'][0],
    piva: responses['Partita IVA o Codice Fiscale'] ? responses['Partita IVA o Codice Fiscale'][0] : null,
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
      Logger.log('❌ Onboard failed: ' + result.error);
      // Opzionalmente, invia email di errore all'admin
      MailApp.sendEmail({
        to: 'lapo@catone.ai',
        subject: 'Catone onboard failed',
        body: 'Error: ' + result.error + '\n\nPayload: ' + JSON.stringify(payload, null, 2)
      });
    } else {
      Logger.log('✅ Onboard success: ' + result.user.email);
    }
  } catch (error) {
    Logger.log('❌ Error calling webhook: ' + error.toString());
    // Notifica errore di rete/infra
    MailApp.sendEmail({
      to: 'lapo@catone.ai',
      subject: 'Catone onboard webhook error',
      body: 'Error: ' + error.toString() + '\n\nPayload: ' + JSON.stringify(payload, null, 2)
    });
  }
}
```

3. **Salva** (Ctrl+S)

4. **Setup trigger:**
   - Click icon: ⏰ (Triggers)
   - **Add Trigger** (bottom right)
   - Function: `onFormSubmit`
   - Event source: **From form**
   - Event type: **On form submit**
   - **Save**

5. **Autorizza script** quando richiesto (Google chiederà permessi)

6. **Test:**
   - Compila il form con una email di test
   - Check: Extensions → Apps Script → Executions (vedi se ha girato)
   - Check inbox: dovresti ricevere magic link entro 30 secondi

### Opzione B: Zapier/Make (no-code, 10 min)

Se non vuoi scrivere codice:

1. Zap: **Google Forms → Webhooks by Zapier**
2. Trigger: New Form Response
3. Action: POST to `https://catone.ai/api/onboard`
4. Map fields: `email`, `name`, `studio`, `piva`, `secret`
5. Test & Enable

---

## Step 5: Test end-to-end

**Test flow completo:**

1. Compila Google Form con tua email (usa alias tipo `you+test1@gmail.com`)
2. Submit
3. Aspetta 30 secondi
4. Check inbox → dovresti avere email "Il tuo account Catone è attivo"
5. Click magic link → redirect a `/engagements`
6. Check Telegram → dovresti avere notifica con dettagli signup

**Se qualcosa non funziona:**

- **Email non arriva:**
  - Check Resend dashboard (Logs)
  - Check spam folder
  - Check `.env.production` ha `RESEND_API_KEY` e `EMAIL_FROM` corretti

- **Webhook non si attiva:**
  - Check Apps Script → Executions
  - Verifica trigger è attivo (icona ⏰)

- **Errore 401 "Invalid webhook secret":**
  - Verifica `WEBHOOK_SECRET` in Apps Script == `.env.production`

- **Telegram notification non arriva:**
  - Normale se `TELEGRAM_BOT_TOKEN` non è settato
  - Opzionale, non blocca l'onboarding

---

## Step 6: Condividi link con Gianni

**Link Google Form:** Copia da Form settings → Send (link icon)

Esempio: `https://forms.gle/ABC123XYZ`

**WhatsApp message template per Gianni:**

```
Ciao Gianni,

ecco il link per far testare Catone ai tuoi contatti:
https://forms.gle/ABC123XYZ

Chi compila il form riceve il link di accesso automaticamente via email in 30 secondi.

Non serve più che mi chiami per ogni onboarding - è tutto automatico.

Se qualcuno ha problemi, fammi sapere.

Lapo
```

---

## Step 7: Monitoring

### Telegram notifications (se configurato)

Ogni signup ti manda:
```
🆕 Nuovo signup Catone

Studio: Studio Rossi
Email: mario@studio.it
Nome: Mario Rossi
Slug: studio-rossi

Magic link inviato ✅
```

### Database query (SSH sul server)

```bash
ssh catone
docker compose exec postgres psql -U catone catone -c "
  SELECT
    o.name as studio,
    u.email,
    u.name,
    u.created_at,
    o.slug
  FROM users u
  JOIN organizations o ON u.organization_id = o.id
  WHERE u.created_at > NOW() - INTERVAL '24 hours'
  ORDER BY u.created_at DESC;
"
```

### App logs

```bash
ssh catone
cd ~/app/deploy
docker compose logs app --tail 50 -f | grep onboard
```

Vedrai:
```
[onboard] Created organization: Studio Rossi (studio-rossi)
[onboard] Created user: mario@studio.it (admin)
[onboard] Created magic link (expires in 15min)
[onboard] Sent magic link email to mario@studio.it
```

---

## Security

### Rate limiting

Il Google Form ha built-in "Limit to 1 response" per IP, ma per extra protezione puoi aggiungere rate limiting in Caddy.

**Caddyfile snippet** (se serve):

```
rate_limit {
  zone api_onboard {
    key {remote_host}
    events 5
    window 1h
  }
}

route /api/onboard* {
  rate_limit api_onboard
  reverse_proxy app:3000
}
```

### Webhook secret

Il `WEBHOOK_SECRET` impedisce chiamate dirette all'endpoint senza passare dal form.

**Se secret leak:**

```bash
# Genera nuovo secret
openssl rand -hex 32

# Update .env.production sul server
# Update Apps Script con nuovo secret
# Restart app
docker compose restart app
```

---

## Metriche da trackare

**Google Form analytics** (built-in):
- Form views → Submits (conversion rate)

**Database queries:**

```sql
-- Signup rate (ultimi 7 giorni)
SELECT
  DATE(created_at) as day,
  COUNT(*) as signups
FROM users
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY DATE(created_at)
ORDER BY day;

-- Activation rate (signup → first practice created)
SELECT
  COUNT(DISTINCT u.id) as total_users,
  COUNT(DISTINCT e.created_by_id) as users_with_practice,
  ROUND(100.0 * COUNT(DISTINCT e.created_by_id) / COUNT(DISTINCT u.id), 1) as activation_rate
FROM users u
LEFT JOIN engagements e ON e.created_by_id = u.id
WHERE u.created_at > NOW() - INTERVAL '30 days';
```

**Resend dashboard:**
- Email delivery rate
- Open rate (se enabled tracking)
- Click rate (magic link clicks)

---

## Costi

- **Google Forms:** Gratis (illimitato)
- **Apps Script:** Gratis (6 min runtime/execution, 90 min/giorno)
- **Resend:** 100 email/giorno gratis (poi $10/mese per 50K email)
- **Hetzner:** Già pagato (server esistente)

**Stima:** €0/mese fino a ~3000 signup/mese (poi Resend diventa paid)

---

## Troubleshooting

### "User already exists"

Normale se qualcuno ri-compila il form. Google Form "Limit to 1 response" limita IP, non email.

**Soluzione:** L'errore viene loggato, puoi approvare manualmente o dire al lead di usare altra email.

### Magic link scade prima che utente clicca

Default: 15 minuti. Se troppo breve:

```bash
# In .env.production
MAGIC_LINK_EXPIRY_MINUTES=60  # 1 ora invece di 15 min
```

Restart app.

### Spam signup

Se ricevi spam:

1. Aggiungi reCAPTCHA v3 al Google Form (Settings → Presentation)
2. Blocca dominio email: aggiungi validation in Apps Script
   ```javascript
   const email = responses['Email professionale'][0];
   if (email.endsWith('@tempmail.com')) {
     Logger.log('Blocked spam domain: ' + email);
     return; // Don't call webhook
   }
   ```

---

## Next Steps

1. ✅ Deploy `/api/onboard` route su production
2. ✅ Aggiungi `WEBHOOK_SECRET` a `.env.production`
3. ✅ Crea Google Form
4. ✅ Collega Form → Apps Script trigger
5. ✅ Test con tua email
6. ✅ Manda link a Gianni

**Timeline totale:** 20-30 minuti

**Deployment:** Già fatto, gira dentro container app esistente su Hetzner.
