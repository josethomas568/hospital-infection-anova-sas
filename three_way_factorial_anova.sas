/* Load the marketing research data */
data marketing;
    input Quality FeeSchedule WorkScope SupervisoryControl Replication;
    datalines;
124.3 1 1 1 1
120.6 1 1 1 2
120.7 1 1 1 3
122.6 1 1 1 4
112.7 1 1 2 1
110.2 1 1 2 2
113.5 1 1 2 3
108.6 1 1 2 4
115.1 1 2 1 1
119.9 1 2 1 2
115.4 1 2 1 3
117.3 1 2 1 4
88.2 1 2 2 1
96.0 1 2 2 2
96.4 1 2 2 3
90.1 1 2 2 4
119.3 2 1 1 1
118.9 2 1 1 2
125.3 2 1 1 3
121.4 2 1 1 4
113.6 2 1 2 1
109.1 2 1 2 2
108.9 2 1 2 3
112.3 2 1 2 4
117.2 2 2 1 1
114.4 2 2 1 2
113.4 2 2 1 3
120.0 2 2 1 4
92.7 2 2 2 1
91.1 2 2 2 2
90.7 2 2 2 3
87.9 2 2 2 4
90.9 3 1 1 1
95.3 3 1 1 2
88.8 3 1 1 3
92.0 3 1 1 4
78.6 3 1 2 1
80.6 3 1 2 2
83.5 3 1 2 3
77.1 3 1 2 4
89.9 3 2 1 1
83.0 3 2 1 2
86.5 3 2 1 3
82.7 3 2 1 4
58.6 3 2 2 1
63.5 3 2 2 2
59.8 3 2 2 3
62.3 3 2 2 4
;

/* ---------------------------------------------------------------
   PART 1: Interaction Plots
   --------------------------------------------------------------- */

/* Compute marginal two-way means for averaged interaction plots */
proc means data=marketing noprint;
    class FeeSchedule WorkScope SupervisoryControl;
    var Quality;
    output out=cellmeans mean=ymean;
run;

/* Fee x Scope averaged over SupervisoryControl */
data cellmeans_ab;
    set cellmeans;
    where FeeSchedule ne . and WorkScope ne . and SupervisoryControl eq .
          and _TYPE_ = 6;
run;

/* Fee x Supv averaged over WorkScope */
data cellmeans_ac;
    set cellmeans;
    where FeeSchedule ne . and WorkScope eq . and SupervisoryControl ne .
          and _TYPE_ = 5;
run;

/* Scope x Supv averaged over FeeSchedule */
data cellmeans_bc;
    set cellmeans;
    where FeeSchedule eq . and WorkScope ne . and SupervisoryControl ne .
          and _TYPE_ = 3;
run;

/* Three-way cell means for conditional plots */
data cellmeans3;
    set cellmeans;
    where FeeSchedule ne . and WorkScope ne . and SupervisoryControl ne .
          and _TYPE_ = 7;
run;

/* Averaged interaction plot: Fee x Scope */
proc sgplot data=cellmeans_ab;
    title 'Averaged Interaction Plot: Fee Schedule x Work Scope (averaged over Supv)';
    series x=FeeSchedule y=ymean / group=WorkScope markers lineattrs=(thickness=2);
    xaxis label='Fee Schedule' values=(1 2 3)
          valuesdisplay=('Fixed' 'Contingency' 'Variable');
    yaxis label='Mean Quality' min=60 max=130;
    keylegend / title='Work Scope' location=inside position=topright;
run;

/* Averaged interaction plot: Fee x Supv */
proc sgplot data=cellmeans_ac;
    title 'Averaged Interaction Plot: Fee Schedule x Supervisory Control (averaged over Scope)';
    series x=FeeSchedule y=ymean / group=SupervisoryControl markers lineattrs=(thickness=2);
    xaxis label='Fee Schedule' values=(1 2 3)
          valuesdisplay=('Fixed' 'Contingency' 'Variable');
    yaxis label='Mean Quality' min=60 max=130;
    keylegend / title='Supv Control' location=inside position=topright;
run;

/* Averaged interaction plot: Scope x Supv */
proc sgplot data=cellmeans_bc;
    title 'Averaged Interaction Plot: Work Scope x Supervisory Control (averaged over Fee)';
    series x=WorkScope y=ymean / group=SupervisoryControl markers lineattrs=(thickness=2);
    xaxis label='Work Scope' values=(1 2)
          valuesdisplay=('Standard' 'Complex');
    yaxis label='Mean Quality' min=60 max=130;
    keylegend / title='Supv Control' location=inside position=topright;
run;

/* Conditional interaction plot: Fee x Scope at each Supv level */
proc sgpanel data=cellmeans3;
    title 'Conditional Interaction Plot: Fee x Scope at each Supervisory Control Level';
    panelby SupervisoryControl / columns=2 novarname;
    series x=FeeSchedule y=ymean / group=WorkScope markers lineattrs=(thickness=2);
    rowaxis label='Mean Quality' min=55 max=130;
    colaxis label='Fee Schedule' values=(1 2 3)
            valuesdisplay=('Fixed' 'Contingency' 'Variable');
    keylegend / title='Scope';
run;
title;

/* ---------------------------------------------------------------
   Full Three-Way ANOVA and Diagnostics
   --------------------------------------------------------------- */
proc glm data=marketing;
    class FeeSchedule WorkScope SupervisoryControl;
    model Quality = FeeSchedule|WorkScope|SupervisoryControl / ss3;
run;

/* Pairwise Differences for Fee Schedule (Tukey) 
   and Work Scope across Supervisory Control (Bonferroni) */
proc glm data=marketing plots=(diagnostics residuals);
    class FeeSchedule WorkScope SupervisoryControl;
    /* Use the reduced model determined in Part 2 here */
    model Quality = FeeSchedule WorkScope SupervisoryControl 
                    WorkScope*SupervisoryControl / ss3 solution;

    /* Save residuals from the reduced model for Part 3 diagnostics */
    output out=diagnostics r=residuals p=predicted;

    /* Tukey pairwise comparison for Fee Schedule */
    lsmeans FeeSchedule / pdiff=all adjust=tukey alpha=0.05;
    
    /* Bonferroni comparison for Work Scope within Supervisory Control */
    lsmeans WorkScope*SupervisoryControl / slice=SupervisoryControl pdiff=all adjust=bon alpha=0.05;
run;
quit;

/* ---------------------------------------------------------------
   PART 3: Residual plots vs each factor index
   --------------------------------------------------------------- */
proc sgplot data=diagnostics;
    title 'Residuals vs Fee Schedule';
    scatter x=FeeSchedule y=residuals / jitter;
    refline 0 / axis=y lineattrs=(pattern=dash);
    xaxis label='Fee Schedule (i)' values=(1 2 3)
          valuesdisplay=('Fixed' 'Contingency' 'Variable');
    yaxis label='Raw Residual e_ijkm';
run;

proc sgplot data=diagnostics;
    title 'Residuals vs Work Scope';
    scatter x=WorkScope y=residuals / jitter;
    refline 0 / axis=y lineattrs=(pattern=dash);
    xaxis label='Work Scope (j)' values=(1 2)
          valuesdisplay=('Standard' 'Complex');
    yaxis label='Raw Residual e_ijkm';
run;

proc sgplot data=diagnostics;
    title 'Residuals vs Supervisory Control';
    scatter x=SupervisoryControl y=residuals / jitter;
    refline 0 / axis=y lineattrs=(pattern=dash);
    xaxis label='Supervisory Control (k)' values=(1 2)
          valuesdisplay=('Close' 'Minimal');
    yaxis label='Raw Residual e_ijkm';
run;
title;
