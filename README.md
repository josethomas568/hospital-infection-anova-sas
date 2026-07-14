# Hospital-Acquired Infection Risk — ANOVA & Variance-Stabilizing Transformations (SAS)

A complete applied-statistics workflow in **SAS**: hypothesis testing, post-hoc multiple comparisons, model-assumption diagnostics, and a variance-stabilizing transformation to correct a violated assumption — applied to a real hospital-infection dataset.

**Tools:** SAS (PROC GLM, PROC TRANSREG, PROC MEANS, ODS Graphics) · Applied Statistics · Experimental Design & ANOVA

---

## Overview
Using the **SENIC** study data (Study on the Efficacy of Nosocomial Infection Control) — a random sample of **113 U.S. hospitals** with 12 variables — I analyzed how hospital-acquired ("nosocomial") infection risk and patient length of stay vary across geographic regions and patient age groups.

The goal was not just to run tests, but to verify the assumptions behind them, detect when they fail, correct the problem, and confirm the conclusion still holds.

## Key findings
- **Infection risk differs by region** — one-way ANOVA significant, F(3,109) = 2.71, p = 0.048; Northeast highest (4.86%), South lowest (3.93%).
- **Only one region pair truly differs** — after multiple-comparison adjustment, only **Northeast vs. South** was significant (Tukey p = 0.027; Bonferroni p = 0.032); all other pairs were not — a clean illustration of controlling family-wise error instead of over-reading the omnibus test.
- **Age group had no effect** on infection risk (F = 0.56, p = 0.64).
- **Length of stay differs strongly by region** — F(3,109) = 12.31, p < 0.0001; mean stay falls from 11.1 days (NE) to 8.1 days (W).
- **Caught and fixed an assumption violation** — the Brown-Forsythe test flagged unequal variances for length of stay (F = 4.33, p = 0.006). Box-Cox pointed to a reciprocal transformation (λ ≈ −1); after applying Y′ = 1/stay, variances were stabilized (Brown-Forsythe F = 0.97, p = 0.41) and the regional effect remained highly significant (F = 14.79, p < 0.0001).

## Methods
- One-way ANOVA (`PROC GLM`) for infection risk by region and by age group
- Post-hoc **Tukey-Kramer** and **Bonferroni** pairwise comparisons at 90% family confidence, with LS-means grouping plots
- Assumption diagnostics: residual analysis and the **Brown-Forsythe** homogeneity-of-variance test
- **Box-Cox** power-transformation analysis (`PROC TRANSREG`), then refit and re-validate on the transformed response
- Group summaries via `PROC MEANS`

## Repository structure
```
hospital-infection-anova-sas/
├── README.md                     # this file
├── src/
│   └── infection_risk_anova.sas  # commented SAS script reproducing the full analysis
├── docs/
│   └── coursework-methods.md      # broader applied-statistics methods (STAT 6338)
└── results/
    └── README.md                  # where to place the SAS output (PDF/HTML)
```

## How to run
1. Load the SENIC dataset (`hospital stay age infprob culratio xratio nbeds medschl region census nurses service`) into a SAS library, or point the `INFILE` path in the `DATA` step of `src/infection_risk_anova.sas` at your `senic.csv`.
2. Run `src/infection_risk_anova.sas` in **SAS Studio / SAS OnDemand for Academics** (or any SAS 9.4+ environment).
3. Output tables and ODS graphics reproduce the results summarized above.

## Skills demonstrated
Experimental design and ANOVA · multiple-comparison procedures and family-wise error control · statistical assumption testing (homogeneity of variance, residual diagnostics) · variance-stabilizing (Box-Cox) transformations · translating statistical output into correct conclusions · SAS programming.

---

*Data reference: Special Issue, "The SENIC Project," American Journal of Epidemiology 111 (1980), 465–653. The `src/` script uses the original DATA step; the analysis procedures reproduce the submitted analysis and are verified against the original SAS output in `results/`.*
