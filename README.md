# Three-Way Factorial ANOVA & Interaction Analysis (SAS)

A full **three-factor factorial ANOVA** in SAS: testing all main effects and interactions, visualizing interactions, reducing to a parsimonious model, and following up with multiple comparisons and residual diagnostics.

**Tools:** SAS (`PROC GLM`, `PROC SGPLOT`, `PROC SGPANEL`, `PROC MEANS`) · Experimental Design · Factorial ANOVA

---

## Overview
A marketing-research study measuring **service quality** under three factors — **Fee Schedule** (3 levels), **Work Scope** (2 levels), and **Supervisory Control** (2 levels) — with replication (48 observations). The goal was to identify which factors and interactions drive quality, then build the simplest model that explains the data well.

## Key findings
- **All three main effects are highly significant** — Fee Schedule (F = 679), Work Scope (F = 248), and Supervisory Control (F = 518), all p < 0.0001.
- **Only one interaction matters** — Work Scope × Supervisory Control was significant (F = 77.8, p < 0.0001); every other two-way and the three-way interaction were not (all p > 0.76), so the model reduces cleanly.
- **Parsimonious model fits strongly** — the reduced model (three main effects + the one meaningful interaction) explains ~98% of the variance in quality (R² ≈ 0.98).
- **Follow-up:** Tukey pairwise comparisons across Fee Schedule levels, Bonferroni-adjusted comparisons of Work Scope sliced within Supervisory Control, and residual-vs-factor diagnostics confirming model assumptions.

## Methods
- Full factorial ANOVA with `PROC GLM` (`model Quality = FeeSchedule|WorkScope|SupervisoryControl`)
- **Interaction visualization** — averaged interaction plots (`PROC SGPLOT`) and conditional interaction panels (`PROC SGPANEL`)
- **Model reduction** — dropping non-significant interactions and refitting
- **Multiple comparisons** — Tukey (Fee Schedule) and Bonferroni sliced comparisons (Work Scope within Supervisory Control)
- **Residual diagnostics** — residuals vs. each factor index

## Repository structure
```
factorial-anova-interaction-sas/
├── README.md
├── src/
│   └── three_way_factorial_anova.sas   # original SAS program (data + full analysis)
└── results/
    └── output.pdf                      # full SAS output (tables + plots)
```

## How to run
Run `src/three_way_factorial_anova.sas` in SAS 9.4+ / SAS OnDemand for Academics — the dataset is embedded in the program's `DATALINES`, so it runs as-is.

## Skills demonstrated
Multi-factor factorial ANOVA · interaction detection, interpretation, and visualization · model reduction toward parsimony · multiple-comparison procedures (Tukey, Bonferroni, sliced effects) · residual diagnostics · SAS `PROC GLM`, `SGPLOT`, and `SGPANEL`.

## Why it matters
Real experiments have many factors; the skill is separating the effects that matter from the noise and communicating them clearly. This project shows the full loop — test everything, keep what's real, visualize it, and validate the model.
