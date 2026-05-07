# IVA Verifiche Implementation - Step-by-Step

**Issue Type:** Feature Implementation
**Priority:** High (blocking commercialista outreach)
**Module:** Compliance Quality Checks

---

## Context

This implements the automated IVA (VAT) verification checks that validate consistency between:
- Annual IVA declaration (VL fields)
- Periodic IVA declarations (VP fields / LIPE)
- F24 tax payments

These verifiche are critical for the commercialist pitch — we cannot demonstrate product completeness without them.

---

## Requirements Overview

Implement 5 core IVA verification rules based on Agenzia delle Entrate requirements:

1. **Verifica Credito Anno Precedente (VL8 = VL33 previous year)**
2. **Verifica Utilizzo Credito F24 (VL9 validation)**
3. **Verifica IVA Periodica Dovuta (VL30 col2 = sum VP4)**
4. **Verifica Versamenti F24 (VL30 col3 = F24 payments)**
5. **Verifica Credito/Debito Finale (VL38/39 vs VP14 ultimo periodo)**

---

## Step-by-Step Implementation

### Step 1: Data Model Preparation

**What:** Ensure we can access all required fields

**Files to check/modify:**
- Document parser for IVA Annuale (VL fields)
- Document parser for IVA Periodica/LIPE (VP fields)
- F24 payment records parser

**Required data access:**
```typescript
// IVA Annuale fields needed
VL8: number   // Credito anno precedente
VL9: number   // Credito utilizzato in compensazione
VL30_col2: number  // IVA periodica dovuta
VL30_col3: number  // Versamenti IVA periodica
VL33: number  // Credito risultante
VL38: number  // IVA a debito
VL39: number  // IVA a credito

// IVA Periodica fields needed
VP4_col1: number[]  // IVA dovuta per ogni mese/trimestre
VP14_col1: number   // IVA a debito (ultimo periodo)
VP14_col2: number   // IVA a credito (ultimo periodo)

// F24 payments needed
F24_6099: Payment[]  // Compensazioni credito IVA (with anno riferimento)
F24_6001_6012: Payment[]  // Versamenti IVA periodica mensile
// TODO: add codici for trimestrale if needed
```

**Acceptance:**
- [ ] All VL fields accessible from parsed IVA Annuale document
- [ ] All VP fields accessible from parsed IVA Periodica documents (array, one per period)
- [ ] F24 payments filterable by codice tributo and anno riferimento
- [ ] Unit tests confirm data access

---

### Step 2: Implement Verifica #1 - Credito Anno Precedente

**What:** VL8 (current year) must equal VL33 (previous year)

**Logic:**
```typescript
function verificaCreditoAnnoPrecedente(
  currentYear: IVAAnnuale,
  previousYear: IVAAnnuale
): VerificationResult {
  const vl8 = currentYear.VL8
  const vl33_prev = previousYear.VL33

  if (vl8 !== vl33_prev) {
    return {
      status: 'ERROR',
      rule: 'VL8 = VL33 anno precedente',
      message: `VL8 dichiarazione ${currentYear.anno} (${vl8}€) non coincide con VL33 dichiarazione ${previousYear.anno} (${vl33_prev}€)`,
      expected: vl33_prev,
      actual: vl8,
      difference: vl8 - vl33_prev
    }
  }

  return { status: 'OK', rule: 'VL8 = VL33 anno precedente' }
}
```

**Reference:** [IVA Annuale Instructions](https://www.agenziaentrate.gov.it/portale/documents/20143/9602686/IVA_ANNUALE_2026_istr.pdf)

**Acceptance:**
- [ ] Function written and exported
- [ ] Unit test: matching values returns OK
- [ ] Unit test: mismatched values returns ERROR with delta
- [ ] Unit test: handles missing previous year gracefully

---

### Step 3: Implement Verifica #2 - Utilizzo Credito F24

**What:** VL9 must equal sum of F24 payments (codice 6099) with matching anno riferimento

**Logic:**
```typescript
function verificaUtilizzoCredito(
  currentYear: IVAAnnuale,
  f24Payments: F24Payment[]
): VerificationResult {
  const vl9 = currentYear.VL9
  const annoRiferimento = currentYear.anno - 1  // Credito maturato anno precedente

  // Sum F24 compensazioni with codice 6099 and correct anno riferimento
  // made BEFORE submission of current year's declaration
  const compensazioni = f24Payments.filter(p =>
    p.codiceTributo === '6099' &&
    p.annoRiferimento === annoRiferimento &&
    p.data < currentYear.dataPresentazione  // Only payments before declaration submission
  )

  const totaleCompensazioni = compensazioni.reduce((sum, p) => sum + p.importo, 0)

  if (vl9 !== totaleCompensazioni) {
    return {
      status: 'ERROR',
      rule: 'VL9 = utilizzi credito F24 (6099)',
      message: `VL9 (${vl9}€) non coincide con totale compensazioni F24 (${totaleCompensazioni}€)`,
      expected: totaleCompensazioni,
      actual: vl9,
      difference: vl9 - totaleCompensazioni,
      detail: `Trovate ${compensazioni.length} compensazioni F24 con codice 6099 e anno ${annoRiferimento}`
    }
  }

  return { status: 'OK', rule: 'VL9 = utilizzi credito F24' }
}
```

**Reference:** IVA Annuale instructions, Rigo VL9 (see verifiche.md line 19)

**Acceptance:**
- [ ] Function correctly filters F24 by codice tributo 6099
- [ ] Function correctly filters by anno riferimento
- [ ] Function correctly filters by data < dataPresentazione
- [ ] Unit test: matching sum returns OK
- [ ] Unit test: mismatched sum returns ERROR with breakdown
- [ ] Unit test: handles empty F24 array

---

### Step 4: Implement Verifica #3 - IVA Periodica Dovuta

**What:** VL30 col2 must equal sum of VP4 col1 for all periods (monthly or quarterly)

**Logic:**
```typescript
function verificaIVAPeriodicaDovuta(
  annuale: IVAAnnuale,
  periodiche: IVAPeriodica[]  // Array of monthly or quarterly declarations
): VerificationResult {
  const vl30_col2 = annuale.VL30_col2

  // Sum VP4 col1 from all periods in the year
  const totaleVP4 = periodiche
    .filter(p => p.anno === annuale.anno)
    .reduce((sum, p) => sum + p.VP4_col1, 0)

  if (vl30_col2 !== totaleVP4) {
    return {
      status: 'ERROR',
      rule: 'VL30 col2 = sum(VP4 col1)',
      message: `VL30 col2 (${vl30_col2}€) non coincide con somma VP4 col1 delle periodiche (${totaleVP4}€)`,
      expected: totaleVP4,
      actual: vl30_col2,
      difference: vl30_col2 - totaleVP4,
      detail: `Verificate ${periodiche.length} dichiarazioni periodiche per anno ${annuale.anno}`
    }
  }

  return { status: 'OK', rule: 'VL30 col2 = sum(VP4 col1)' }
}
```

**Reference:** [IVA Periodica Instructions](https://www.agenziaentrate.gov.it/portale/documents/20143/5986193/IVA+period_2024.pdf)

**Acceptance:**
- [ ] Function correctly sums VP4_col1 across all periods
- [ ] Function handles both monthly (12 periods) and quarterly (4 periods) regimes
- [ ] Unit test: matching sum returns OK
- [ ] Unit test: mismatched sum returns ERROR
- [ ] Unit test: handles missing periods gracefully

---

### Step 5: Implement Verifica #4 - Versamenti F24

**What:** VL30 col3 must equal sum of F24 versamenti IVA periodica (codici 6001-6012 for monthly, check trimestrale codes)

**Logic:**
```typescript
function verificaVersamentiF24(
  annuale: IVAAnnuale,
  f24Payments: F24Payment[]
): VerificationResult {
  const vl30_col3 = annuale.VL30_col3

  // Codici tributo for monthly IVA payments
  const codiciMensili = ['6001', '6002', '6003', '6004', '6005', '6006',
                         '6007', '6008', '6009', '6010', '6011', '6012']

  // TODO: Add trimestrale codes if needed
  const codiciTrimestrale = ['6031', '6032', '6033', '6034']  // Verify these

  const codiciValidi = [...codiciMensili, ...codiciTrimestrale]

  // Sum F24 payments with IVA periodica codes for this year
  const versamenti = f24Payments.filter(p =>
    codiciValidi.includes(p.codiceTributo) &&
    p.annoRiferimento === annuale.anno
  )

  const totaleVersamenti = versamenti.reduce((sum, p) => sum + p.importo, 0)

  if (vl30_col3 !== totaleVersamenti) {
    return {
      status: 'ERROR',
      rule: 'VL30 col3 = versamenti F24 IVA periodica',
      message: `VL30 col3 (${vl30_col3}€) non coincide con totale versamenti F24 (${totaleVersamenti}€)`,
      expected: totaleVersamenti,
      actual: vl30_col3,
      difference: vl30_col3 - totaleVersamenti,
      detail: `Trovati ${versamenti.length} versamenti F24 IVA periodica per anno ${annuale.anno}`
    }
  }

  return { status: 'OK', rule: 'VL30 col3 = versamenti F24' }
}
```

**Note from verifiche.md:** "Dovrei avere un errore su IVA periodica versata SE dovuta != da versata → alert"

**Acceptance:**
- [ ] Function correctly filters F24 by codici tributo 6001-6012
- [ ] Research and add correct trimestrale codes if needed
- [ ] Function correctly filters by anno riferimento
- [ ] Unit test: matching sum returns OK
- [ ] Unit test: mismatched sum returns ERROR with breakdown
- [ ] Unit test: handles both monthly and quarterly regimes

---

### Step 6: Implement Verifica #5 - Credito/Debito Finale

**What:** VL38/39 must match VP14 from last period (December or Q4)

**Complex logic with two scenarios:**

**Scenario A: A debito (VL38 populated)**
```typescript
function verificaDebitoFinale(
  annuale: IVAAnnuale,
  ultimaPeriodica: IVAPeriodica  // December or Q4
): VerificationResult {
  const vl38 = annuale.VL38  // IVA a debito annuale
  const vp14_col1 = ultimaPeriodica.VP14_col1  // IVA a debito ultima periodica

  if (vl38 === null && vl39 === null) {
    // Neither debt nor credit - check if VP14 is zero
    if (vp14_col1 === 0 && ultimaPeriodica.VP14_col2 === 0) {
      return { status: 'OK', rule: 'VL38/39 vs VP14 (pareggio)' }
    }
  }

  if (vl38 !== null && vl38 !== vp14_col1) {
    return {
      status: 'ERROR',
      rule: 'VL38 = VP14 col1 ultimo periodo',
      message: `VL38 (${vl38}€) non coincide con VP14 col1 ultimo periodo (${vp14_col1}€)`,
      expected: vp14_col1,
      actual: vl38,
      difference: vl38 - vp14_col1
    }
  }

  return { status: 'OK', rule: 'VL38 = VP14 col1' }
}
```

**Scenario B: A credito (VL39 populated)**
```typescript
function verificaCreditoFinale(
  annuale: IVAAnnuale,
  ultimaPeriodica: IVAPeriodica,
  f24Payments: F24Payment[]
): VerificationResult {
  const vl39 = annuale.VL39  // IVA a credito annuale
  const vl33 = annuale.VL33  // Credito risultante (after compensazioni)
  const vp14_col2 = ultimaPeriodica.VP14_col2  // IVA a credito ultima periodica

  // If VL39 != VP14 col2, check if VL33 = VP14 col2 - utilizzi credito F24
  if (vl39 !== vp14_col2) {
    // Check alternative: utilizzi credito between ultimo periodo and dichiarazione
    const utilizziCredito = f24Payments.filter(p =>
      p.codiceTributo === '6099' &&
      p.data >= ultimaPeriodica.dataPresentazione &&
      p.data < annuale.dataPresentazione
    ).reduce((sum, p) => sum + p.importo, 0)

    const expectedVL33 = vp14_col2 - utilizziCredito

    if (vl33 === expectedVL33) {
      return {
        status: 'OK',
        rule: 'VL33 = VP14 col2 - utilizzi credito',
        detail: `VL39 (${vl39}€) ≠ VP14 col2 (${vp14_col2}€), ma VL33 (${vl33}€) coincide con VP14 col2 - utilizzi F24 (${utilizziCredito}€)`
      }
    }

    return {
      status: 'ERROR',
      rule: 'VL39 = VP14 col2 (o VL33 = VP14 col2 - utilizzi)',
      message: `VL39 (${vl39}€) ≠ VP14 col2 (${vp14_col2}€) e VL33 (${vl33}€) ≠ VP14 col2 - utilizzi F24 (${expectedVL33}€)`,
      expected: vp14_col2,
      actual: vl39,
      detail: `Utilizzi credito F24 tra ultima periodica e dichiarazione: ${utilizziCredito}€`
    }
  }

  return { status: 'OK', rule: 'VL39 = VP14 col2' }
}
```

**Reference:** verifiche.md lines 31-32

**Acceptance:**
- [ ] Function handles both a debito and a credito scenarios
- [ ] Function correctly identifies ultimo periodo (Dec or Q4)
- [ ] Function implements alternative validation with utilizzi credito
- [ ] Unit test: VL38 = VP14 col1 returns OK
- [ ] Unit test: VL39 = VP14 col2 returns OK
- [ ] Unit test: VL39 ≠ VP14 col2 but VL33 = VP14 col2 - utilizzi returns OK
- [ ] Unit test: Both mismatched returns ERROR

---

### Step 7: Create Verification Orchestrator

**What:** Main function that runs all verifiche and returns comprehensive report

**Logic:**
```typescript
interface IVAVerificationReport {
  documentId: string
  anno: number
  timestamp: Date
  verifiche: VerificationResult[]
  status: 'OK' | 'WARNING' | 'ERROR'
  summary: {
    total: number
    passed: number
    failed: number
  }
}

async function runIVAVerifiche(
  annuale: IVAAnnuale,
  previousYear: IVAAnnuale | null,
  periodiche: IVAPeriodica[],
  f24Payments: F24Payment[]
): Promise<IVAVerificationReport> {

  const results: VerificationResult[] = []

  // Verifica 1: Credito anno precedente (skip if no previous year)
  if (previousYear) {
    results.push(verificaCreditoAnnoPrecedente(annuale, previousYear))
  }

  // Verifica 2: Utilizzo credito F24
  results.push(verificaUtilizzoCredito(annuale, f24Payments))

  // Verifica 3: IVA periodica dovuta
  results.push(verificaIVAPeriodicaDovuta(annuale, periodiche))

  // Verifica 4: Versamenti F24
  results.push(verificaVersamentiF24(annuale, f24Payments))

  // Verifica 5: Credito/Debito finale
  const ultimaPeriodica = periodiche[periodiche.length - 1]  // Assumes sorted
  if (annuale.VL38 !== null) {
    results.push(verificaDebitoFinale(annuale, ultimaPeriodica))
  } else if (annuale.VL39 !== null) {
    results.push(verificaCreditoFinale(annuale, ultimaPeriodica, f24Payments))
  }

  // Aggregate status
  const failed = results.filter(r => r.status === 'ERROR').length
  const passed = results.filter(r => r.status === 'OK').length

  return {
    documentId: annuale.id,
    anno: annuale.anno,
    timestamp: new Date(),
    verifiche: results,
    status: failed > 0 ? 'ERROR' : 'OK',
    summary: {
      total: results.length,
      passed,
      failed
    }
  }
}
```

**Acceptance:**
- [ ] Function runs all 5 verifiche
- [ ] Function handles missing data gracefully (previous year, etc)
- [ ] Returns comprehensive report with all results
- [ ] Status correctly reflects ERROR if any verifica fails
- [ ] Unit test: all passing verifiche returns status OK
- [ ] Unit test: one failing verifica returns status ERROR
- [ ] Integration test with real document samples

---

### Step 8: UI Integration

**What:** Display verification results in document detail view

**Requirements:**
- [ ] Show verification report in IVA Annuale document page
- [ ] Use ✅ for OK, ❌ for ERROR, ⚠️ for WARNING
- [ ] Clicking on failed verifica shows detail (expected vs actual, delta)
- [ ] Add "Run Verifiche" button if not auto-run
- [ ] Store verification results in database for audit trail

**UI Mock:**
```
IVA Verifiche - Anno 2024

✅ VL8 = VL33 anno precedente
❌ VL9 = utilizzi credito F24 (6099)
   Expected: 12,450€ | Actual: 12,000€ | Delta: -450€
   Trovate 3 compensazioni F24 con codice 6099
✅ VL30 col2 = sum(VP4 col1)
✅ VL30 col3 = versamenti F24 IVA periodica
✅ VL39 = VP14 col2

Status: 1 error, 4 checks passed
```

---

### Step 9: Testing Strategy

**Unit Tests (per function):**
- [ ] Happy path (all values match)
- [ ] Error cases (mismatches with various deltas)
- [ ] Edge cases (null values, empty arrays, missing data)
- [ ] Boundary values (0, negative numbers if applicable)

**Integration Tests:**
- [ ] Real anonymized IVA Annuale + Periodiche + F24 dataset
- [ ] Known-good case (should pass all verifiche)
- [ ] Known-bad case with specific errors (should detect them)
- [ ] Cross-year scenario (2023 → 2024 → 2025)

**Test Data:**
Create fixtures in `tests/fixtures/iva-verifiche/`:
- `iva-annuale-2024-ok.json` (passes all verifiche)
- `iva-annuale-2024-vl9-error.json` (VL9 mismatch)
- `iva-periodiche-2024.json` (12 monthly declarations)
- `f24-payments-2023-2024.json` (sample F24 transactions)

---

### Step 10: Documentation

**What:** Document the verifiche for commercialisti users

**Create:**
- [ ] `/docs/iva-verifiche.md` - Technical explanation of each rule
- [ ] `/docs/iva-verifiche-examples.md` - Examples of common errors
- [ ] Help tooltip in UI for each verifica explaining what it checks
- [ ] Link to Agenzia delle Entrate official instructions

**Sales enablement:**
- [ ] Add "IVA Verifiche" to feature list in pitch deck
- [ ] Create Loom demo showing verification catching an error
- [ ] Update `leads.md` with talking points about verifiche

---

## Definition of Done

- [ ] All 5 verifiche functions implemented and tested
- [ ] Orchestrator function aggregates results
- [ ] UI displays verification report
- [ ] Integration tests pass with real data
- [ ] Documentation complete
- [ ] Feature demoed to Gianni for feedback
- [ ] Ready to pitch to commercialisti ("guardate, trova gli errori automaticamente")

---

## Estimated Effort

**Development:** 8-12 hours
- Step 1-2: 1.5h (data model + verifica 1)
- Step 3-4: 2h (verifiche 2-3)
- Step 5-6: 3h (verifiche 4-5, complex logic)
- Step 7: 1h (orchestrator)
- Step 8: 2h (UI integration)
- Step 9: 2h (testing)
- Step 10: 0.5h (docs)

**Blocking priority:** Complete this BEFORE commercialista outreach. Cannot pitch incomplete product.

---

## Reference Documents

- Agenzia delle Entrate IVA Annuale Instructions: https://www.agenziaentrate.gov.it/portale/documents/20143/9602686/IVA_ANNUALE_2026_istr.pdf
- Agenzia delle Entrate IVA Periodica Instructions: https://www.agenziaentrate.gov.it/portale/documents/20143/5986193/IVA+period_2024.pdf
- Internal verifiche spec: `/workspace/group/lapo-brain/10-projects/catone/verifiche.md`

---

## Notes

- This is based on your existing notes in `verifiche.md`
- The F24 trimestrale codes (6031-6034) are assumed - verify these are correct
- Consider adding more verifiche from Agenzia delle Entrate docs if needed
- After implementation, test with Gianni's studio data before showing to prospects
