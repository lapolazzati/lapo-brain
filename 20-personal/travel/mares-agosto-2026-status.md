# Status: Extração de Dados de Marés - Agosto 2026

## Situação Atual

Tentei extrair automaticamente os dados de marés para agosto de 2026 das seguintes praias em Ceará:
1. Cumbuco
2. Paracuru
3. Preá
4. Flecheiras (usando Trairi como proxy)

## Desafio Técnico

Os sites de tábua de marés (tabuademares.com e tides4fishing.com) utilizam conteúdo carregado dinamicamente via JavaScript, o que dificulta a extração automatizada. A navegação entre meses requer interação com elementos dinâmicos que não são facilmente acessíveis programaticamente.

## Fonte de Dados Identificada

O melhor site encontrado foi: **https://tides4fishing.com/br/ceara/praia-de-cumbuco**

Este site tem uma interface clara mostrando:
- 1ª MARÉ, 2ª MARÉ, 3ª MARÉ, 4ª MARÉ
- Setas para cima (▲) = maré alta (preia-mar)
- Setas para baixo (▼) = maré baixa (baixa-mar)
- Horários e alturas para cada maré

## Próximos Passos Recomendados

### Opção 1: Coleta Manual (Mais Rápida)
1. Acesse https://tides4fishing.com/br/ceara/praia-de-cumbuco
2. Clique em "Tide table" no menu lateral
3. Navegue até agosto 2026 usando as setas ◄ ►
4. Anote os horários de maré baixa e maré alta para cada dia
5. Repita para as outras praias

### Opção 2: Fontes Alternativas
- **Marinha do Brasil**: https://pam.dhn.mar.mil.br/tabuamares/tabuamares_en.html (fonte oficial)
- **Tide-forecast.com**: Pode ter interface mais acessível
- **Surfline**: https://www.surfline.com/tide-charts/praia-de-cumbuco/640a35d545190554d89a266b

## Template para Dados

Quando coletar os dados, use este formato:

```markdown
## Semana 1 (1-7 de agosto de 2026)

### Cumbuco
| Data | Maré Baixa | Maré Alta |
|------|------------|-----------|
| 1/8  | 06:30, 18:45 | 00:15, 12:40 |
| 2/8  | 07:15, 19:30 | 01:00, 13:25 |
...
```

## Recursos Úteis

- [Tides4Fishing - Cumbuco](https://tides4fishing.com/br/ceara/praia-de-cumbuco)
- [Tides4Fishing - Paracuru](https://tides4fishing.com/br/ceara/paracuru)
- [Tides4Fishing - Preá](https://tides4fishing.com/br/ceara/prea)
- [Tides4Fishing - Trairi](https://tides4fishing.com/br/ceara/trairi)
- [Marinha do Brasil - Tábua de Marés](https://pam.dhn.mar.mil.br/tabuamares/tabuamares_en.html)

---

Se preferir, posso tentar outras abordagens técnicas ou você pode me fornecer acesso a ferramentas adicionais para automação.
