# Catone - Novità di aprile e inizio maggio (v2 - VERSIONE BREVE)

**Oggetto:** [Catone] Nuova verifica credito IVA + interfaccia riprogettata

---

Gentile dottore,

sono passate alcune settimane dall'ultimo aggiornamento. Abbiamo rilasciato una nuova verifica fiscale e riprogettato completamente la fase di revisione documenti.

## Nuova verifica: Credito IVA anno precedente

Il sistema ora verifica automaticamente che il credito IVA riportato in **VL8** corrisponda al **VL33** dell'anno precedente.

Se manca la dichiarazione precedente (perché fuori dal perimetro della DD), lo stato risulta "Non applicabile" invece di segnalare un falso errore.

Trovate questa verifica nella sezione IVA insieme alle altre.

## Interfaccia riprogettata: dalla revisione all'export in meno passaggi

Abbiamo ripensato la pagina **"Coda revisione"** per renderla più chiara:

**Prima:** Tre card con metriche poco chiare ("13/7" — cosa significa?), documenti sparsi in una lista piatta, nessuna indicazione di dove iniziare.

**Adesso:** Verdetto immediato in alto con tre stati possibili:

- 🔴 **Rosso:** "N documenti bloccano l'export" → pulsante "Vai al primo bloccante" che vi porta direttamente al documento da correggere
- 🟡 **Giallo:** "Nessun blocco — N documenti da verificare prima dell'export" → pulsante "Inizia revisione" + link secondario per export immediato
- 🟢 **Verde:** "Pratica pronta per l'export" → pulsante primario "Genera report"

I documenti sono ora raggruppati per gravità (Bloccanti → Da verificare → Da classificare → Modello non supportato) invece di essere mescolati in una lista unica.

**Risultato:** Su una pratica con 180 documenti caricati, vedete immediatamente se ci sono 3 bloccanti o zero problemi, senza dover scorrere tutta la lista.

## Archivio al posto di Documenti

La sezione "Documenti" ora si chiama **"Archivio"**.

Stesso contenuto, nome più chiaro: un archivio è dove si conservano i file del cliente, "documenti" è troppo generico.

## Esportazione PowerPoint

Dalla pagina Panoramica potete ora esportare i risultati in formato **PPTX**, già formattati per la presentazione finale. Si aggiunge a XLSX, DOCX, PDF.

## Tempestività dichiarazioni

La Panoramica mostra una tabella sintetica dello stato dichiarazioni per anno fiscale (Redditi USC, 770, IVA): vedete subito se presentate nei termini, in ritardo, o mancanti. Un clic vi porta al dettaglio con date e giorni di ritardo.

## Protezione classificazioni manuali

Le correzioni manuali ora sono protette: se correggete la classificazione di un documento, quella modifica non viene più sovrascritta anche se ri-eseguite la classificazione automatica.

---

Come sempre, questi aggiornamenti sono già attivi.

Per qualsiasi domanda, rispondete a questa email.

Buon lavoro,
Luca

---

## Note per implementation:

**Screenshot da aggiungere:**

1. **Verifica VL8/VL33** - Screenshot della sezione IVA con la nuova verifica che mostra "Non applicabile" quando manca anno precedente
2. **Verdetto rosso** - Screenshot del banner rosso "3 documenti bloccano l'export" con pulsante "Vai al primo bloccante"
3. **Verdetto verde** - Screenshot del banner verde "Pratica pronta per l'export" con pulsante "Genera report"
4. **Archivio** - Screenshot del menu laterale che mostra "Archivio" invece di "Documenti"

**Posizionamento screenshot:**
- Dopo ogni sezione principale (Nuova verifica → screenshot; Interfaccia riprogettata → 2 screenshot side-by-side prima/dopo; Archivio → screenshot)
- Larghezza massima: 564px (width del container email)
- Formato: PNG con bordo sottile #e7e5e4 per staccare dallo sfondo bianco
- Alt text descrittivo per accessibilità

**Lunghezza finale:** ~420 parole (vs 650 della v1)
