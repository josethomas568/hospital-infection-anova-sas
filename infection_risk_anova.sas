/**********************************************************************
* Project : Hospital-Acquired Infection Risk - ANOVA & Transformations
* Data     : SENIC (Study on the Efficacy of Nosocomial Infection
*            Control) - 113 U.S. hospitals, 12 variables
* Author   : Jose Thomas
* Course   : STAT 6338 - Applied Statistics (SAS)
*
* Summary  : One-way ANOVA, Tukey & Bonferroni multiple comparisons,
*            residual & Brown-Forsythe assumption diagnostics, and a
*            Box-Cox variance-stabilizing transformation.
*
* Note     : Clean, commented reproduction of the original analysis.
*            Point the DATA step below at the SENIC data file.
**********************************************************************/

/*--- 0. Load data (original DATA step) ------------------------------
   Variables (one row per hospital):
   hospital stay age infprob culratio xratio nbeds medschl region census nurses service
   'infprob' = infection risk (%), 'region' 1=NE 2=NC 3=S 4=W          */
data senic;
    infile "/home/u64333706/STAT6338/Project 1/senic.csv" dlm=',' firstobs=2;   /* <-- update path to your senic.csv */
    input hospital stay age infprob culratio xratio nbeds medschl
          region census nurses service;
run;


/*====================================================================
* Q1. Does mean INFECTION RISK differ across the four REGIONS?
*     One-way ANOVA (alpha = .05)
*===================================================================*/
proc glm data=senic;
    class region;
    model infprob = region;
    title "1(a) ANOVA: Infection Risk by Geographic Region";
run;
quit;

/*--- 1(b) Tukey-Kramer pairwise comparisons, 90% family confidence --*/
proc glm data=senic;
    class region;
    model infprob = region;
    lsmeans region / adjust=tukey cl alpha=0.10 lines;
    title "1(b) Tukey Pairwise Comparisons (90% Confidence)";
run;
quit;

/*--- 1(c) Bonferroni pairwise comparisons, 90% family confidence ----*/
proc glm data=senic;
    class region;
    model infprob = region;
    lsmeans region / adjust=bon cl alpha=0.10 lines;
    title "1(c) Bonferroni Pairwise Comparisons (90% Confidence)";
run;
quit;


/*====================================================================
* Q2. Does mean INFECTION RISK differ across AGE GROUPS?
*     Classify average patient age into 4 categories, then ANOVA
*     (alpha = .10)
*===================================================================*/
data senic2;
    set senic;
    if      age <  50   then AgeGroup = 1;   /* under 50    */
    else if age <  55   then AgeGroup = 2;   /* 50 - 54.9   */
    else if age <  60   then AgeGroup = 3;   /* 55 - 59.9   */
    else                     AgeGroup = 4;   /* 60 and over */
run;

proc glm data=senic2;
    class AgeGroup;
    model infprob = AgeGroup;
    title "Q2: ANOVA of Infection Risk by Age Group";
run;
quit;


/*====================================================================
* Q3. Does mean LENGTH OF STAY differ across REGIONS?
*     ANOVA + assumption checks + variance-stabilizing transformation
*===================================================================*/

/*--- Omnibus ANOVA and residual diagnostics -------------------------*/
proc glm data=senic plots=diagnostics;
    class region;
    model stay = region;
    output out=stay_resid r=resid p=pred;   /* save residuals */
    title "Q3: ANOVA - Length of Stay by Region";
run;
quit;

/*--- 3(a) Aligned residual dot plots by region ----------------------*/
proc sgplot data=stay_resid;
    scatter x=region y=resid;
    refline 0 / axis=y;
    title "3(a) Aligned Residual Dot Plots by Region";
run;

/*--- 3(b) Brown-Forsythe test for homogeneity of variance -----------*/
proc glm data=senic;
    class region;
    model stay = region;
    means region / hovtest=bf;              /* Brown-Forsythe */
    title "3(b) Brown-Forsythe Test (Original Length of Stay)";
run;
quit;

/*--- 3(c) Group means & std devs (informs the transformation) -------*/
proc means data=senic mean std n;
    class region;
    var stay;
    title "3(c) Mean and Std Dev of Length of Stay by Region";
run;

/*--- 3(d) Box-Cox power transformation ------------------------------*/
proc transreg data=senic;
    model boxcox(stay) = class(region);
    title "3(d) Box-Cox Transformation Analysis";
run;

/*--- 3(e) Apply reciprocal transformation Y' = 1/stay, refit ANOVA --*/
data senic_t;
    set senic;
    inv_Stay = 1 / stay;
run;

proc glm data=senic_t;
    class region;
    model inv_Stay = region;
    title "3(e) ANOVA on Transformed Data (Y' = 1 / stay)";
run;
quit;

/*--- 3(f) Re-test homogeneity of variance on transformed response ---*/
proc glm data=senic_t;
    class region;
    model inv_Stay = region;
    means region / hovtest=bf;
    title "3(f) Brown-Forsythe Test on Transformed Data";
run;
quit;

/* End of program */
