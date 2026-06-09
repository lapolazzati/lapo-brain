# Teaching Notes — Lapo

## Preferences
- **ADHD pacing**: short, high-density lessons with immediate application. Story-first, not theory-first.
- **"Don't look like a dork" anxiety**: priority = conversational competence in technical meetings. I need exit strategies for questions I can't answer ("let me confirm that with Chris and get back to you").
- **Spatial > text memory**: draw molecules, circle the bond that breaks, sketch contaminant plumes.
- **Two formats in parallel**: when one medium loses focus, switch to another (HTML lesson → film → Anki card → real site application).
- **Apply same day**: whatever gets taught in a lesson, apply to a real CEG project or Milano site within 24 hours.

## CEG Technology Stack (for lesson design)
- **Advanced Oxidation (ISCO)**: persulfate-based chemical oxidation. Breaks C-Cl bonds on chlorinated solvents, ring-opens aromatic hydrocarbons.
- **BioBlend (Enhanced Bioremediation)**: biostimulation — adds nutrients to wake up native bacteria that degrade hydrocarbons. Not bioaugmentation (adding microbes) unless site-specific conditions require it.
- **Phytoremediation**: plant-based contaminant extraction/stabilization. Slower, used for polishing or low-concentration sites.

## Key Contaminants (per Milano tender context)
- Chlorinated solvents: TCE, PCE (metal degreasing, dry cleaning)
- Petroleum hydrocarbons: BTEX (benzene, toluene, ethylbenzene, xylene), PAHs
- Heavy metals: lead, chromium (especially Cr-VI), cadmium
- Possible PFAS (if Milano sites were industrial/firefighting adjacent)

## Italian Regulatory Language
- **CSC** = Concentrazione Soglia di Contaminazione (generic screening thresholds)
- **CSR** = Concentrazione Soglia di Rischio (site-specific risk-based thresholds)
- **ARPA Lombardia** = regional environmental agency reviewing everything
- **D.Lgs. 152/2006, Titolo V, Parte IV** = the law
- **Piano di Caratterizzazione → Analisi di Rischio → Piano di Bonifica** = the three-phase project sequence

## Zone of Proximal Development (current assessment)
Lapo has:
- Strong regulatory/strategic understanding (ISPRA, CSC/CSR, ARPA workflow)
- Good grasp of CEG's business model and technology positioning
- The Lego-brick metaphor conceptually but not operationally

Lapo needs:
- Molecular intuition: what bonds look like, why some break easier than others
- Contaminant → technology matching: which CEG tech for which contaminant class
- Conversational depth: the 2-3 sentence technical explanation that makes ARPA nod

## Landing Page
- **Live:** https://present-trellis-fjyy.here.now/
- Dark-themed course catalog. Currently one course: Chemistry for Bioremediation.
- Each lesson is a self-contained HTML file served from here.now.
- When creating new lessons or courses, update the landing page at `~/.hermes/publish/chemistry-learnings/index.html` and re-publish with `--slug present-trellis-fjyy`.
- Future /teach courses (e.g., "Hydrogeology for Site Assessment") get added as new course cards to this same landing page.
