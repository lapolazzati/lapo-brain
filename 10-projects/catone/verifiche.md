---
type: Note
_width: normal
---
# Verifiche iva

### Verifiche Credito anno precedente

<https://app.catone.ai/api/documents/673/file>

VL 8 sia uiguale a VL33 from previous year

VL 9 sia pare a utilizzi del credito in F24 codice tributo 6099 con anno di riferimento,anno di imposta in cui il credito é maturato

![BlockNote image](attachments/1777903126714-Screenshot_2026-05-04_at_15.58.42.png)

<https://www.agenziaentrate.gov.it/portale/documents/20143/9602686/IVA_ANNUALE_2026_istr.pdf/2a42fb92-1b76-229a-d0f5-06069d79b514?t=1768504755711>

> Rigo VL9 indicare il credito IVA riportato in detrazione o in compensazione nella dichiarazione precedente (dichiarazione IVA/2025 e relativa all’anno 2024) ed utilizzato in compensazione con il modello F24 anteriormente alla presentazione della dichiarazione relativa all’anno 2025 Nello stesso rigo deve essere compreso anche l’eventuale maggior credito riconosciuto con comunicazione dell’Agenzia delle entrate inviata ai sensi dell’art. 54-bis ed ugualmente utilizzato per compensare altre somme dovute prima della presentazione della presente dichiarazione.

VL 30 colonna 2 sia pai a lipe sum of VP4 col1 di ciascun mese o trimestre

<https://www.agenziaentrate.gov.it/portale/documents/20143/5986193/IVA+period_2024.pdf/04990f53-edc9-048a-c953-49592ebea05f?t=1742281742832>

VL 30 col 3 sia pari ai versamenti dell'F24 (Codice 6001 al 6012, se mensile, check for trimestrali)

Dovrei avere un errore su IVA periodica versata

SE dovuta != da versata → alert

VL38 e 39 siano uguali al VP14 dellla lipe del 4o trimestre o mese dicembre, se a credito e differenti allora verificare se VL 33 = VP14 col 2 - utilizzi credito F24 fino alla data di presentazione della dichiarazione iva relativa all'anno a cui la lipe si riferisce (con credito <https://app.catone.ai/api/documents/649/file> che coincide con <https://app.catone.ai/api/documents/645/file>)
