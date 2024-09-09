{smcl}
{* *! version 0.1, 1 July 2024}{...}
{cmd:help for dmlmed}{right:Geoffrey T. Wodtke}
{hline}

{title:Title}

{p2colset 5 18 18 2}{...}
{p2col : {cmd:dmlmed} {hline 2}}causal mediation analysis using de-biased machine learning (DML) {p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 18 2}
{cmd:dmlmed} {depvar} {help indepvars:mvars} {ifin}{cmd:,} 
{opt type(string)}
{opt model(string)}
{opt dvar(varname)} 
{opt d(real)} 
{opt dstar(real)} 
[{opt cvars(varlist)} 
{opt xfits(integer)} 
{opt seed(integer)}
{opt censor}]
[{it:{help rforest##options:rforest_options}}]
[{it:{help lasso2##options:lasso2_options}}]

{phang}{opt type(string)} - this specifies which multiply robust estimator to implement. Options are mr1 and mr2. 
For type(mr1), both the exposure and a univariate mediator must be binary (0/1). 
For type(mr2), only the exposure must be binary (0/1), and multiple mediators are permitted.

{phang}{opt model(string)} - this specifies which ML model to implement. Options are rforest and lasso. 
For model(rforest), random forests are used to predict the nuisance terms. 
For model(lasso), LASSO models with all two-way interactions are used to predict the nuisance terms.

{phang}{opt depvar} - this specifies the outcome variable.

{phang}{opt mvars} - this specifies the mediator(s), which can be multivariate with type(mr2) estimation.

{phang}{opt dvar(varname)} - this specifies the treatment (exposure) variable. This variable must be binary (0/1).

{phang}{opt d(real)} - this specifies the reference level of treatment.

{phang}{opt dstar(real)} - this specifies the alternative level of treatment. Together, (d - dstar) defines
the treatment contrast of interest.

{title:Options}

{phang}{opt cvars(varlist)} - this option specifies the list of baseline covariates to be included in the analysis. Categorical 
variables need to be coded as a series of dummy variables before being entered as covariates.

{phang}{opt xfits(integer)} - this option specifies the number of sample partitions to use for cross-fitting (the default is 5).

{phang}{opt seed(integer)} - this option specifies the seed for cross-fitting and model training.

{phang}{opt censor} - this option specifies that the inverse probability weights used in the robust estimating equations are censored at their 1st and 99th percentiles.

{phang}{it:{help rforest##options:rforest_options}} - all {help rforest} options are available when using model(rforest). 

{phang}{it:{help lasso2##options:lasso2_options}} - all {help lasso2} options are available when using model(lasso). {p_end}

{title:Description}

{pstd}{cmd:dmlmed} performs causal mediation analysis using de-biased machine learning (DML). Currently, the command supports 
implementation of DML only with random forests and LASSO regression. It requires prior installation of the {cmd:rforest} and 
{cmd:lassopack} modules. {p_end}

{pstd}For type(mr1) estimation, three models are trained: (1) a model for the exposure conditional on baseline covariates, (2) a model for a single 
binary mediator conditional on the exposure and baseline covariates, and (3) a model for the outcome conditional on the exposure, mediator, and 
baseline covariates. These models are then used to construct weights and imputations for a set of multiply robust estimating equations that target 
the total, natural direct, and natural indirect effects through a single binary mediator. {p_end}

{pstd}For type(mr2) estimation, five models are trained: (1) a model for the exposure conditional on baseline covariates, (2) a model for the exposure 
conditional on the mediator(s) and baseline confounders, (3) a model for the outcome conditional on the exposure, mediator(s), and baseline covariates, 
(4) a model for the imputations from model (3) under the reference level of treatment, and (5) a model for the imputations from model (3) under the 
alternative level of treatment. These models are then used to construct weights and imputations for another set of multiply robust estimating equations 
that also target the natural effects decomposition. Because type(mr2) estimation does not require modeling the mediator(s), it can be used with several 
different types of mediators (binary, ordinal, or continuous) and also supports analyses of multiple mediators. When multiple mediators are specified, 
type(mr2) estimation targets multivariate natural direct and indirect effects.  {p_end}

{pstd}When model(rforest) is specified, all the models outlined previously are fit using random forests. Alternatively, when model(lasso) is specified,
all these models are fit using the LASSO. {p_end}

{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. use nlsy79.dta} {p_end}

{pstd} type(mr1) estimation with random forests and censored weights: {p_end}
 
{phang2}{cmd:. dmlmed std_cesd_age40 ever_unemp_age3539, type(mr1) model(rforest) dvar(att22) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) censor} {p_end}

{pstd} type(mr1) estimation with random forests and censored weights, using custom hyperparameters: {p_end}
 
{phang2}{cmd:. dmlmed std_cesd_age40 ever_unemp_age3539, type(mr1) model(rforest) dvar(att22) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) censor iter(200) numvars(5) lsize(5)} {p_end}

{pstd} type(mr1) estimation with the LASSO and censored weights: {p_end}
 
{phang2}{cmd:. dmlmed std_cesd_age40 ever_unemp_age3539, type(mr1) model(lasso) dvar(att22) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) censor} {p_end}

{pstd} type(mr2) estimation with random forests and censored weights, using custom hyperparameters: {p_end}
 
{phang2}{cmd:. dmlmed std_cesd_age40 ever_unemp_age3539, type(mr2) model(rforest) dvar(att22) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) censor iter(200) numvars(5) lsize(5)} {p_end}

{pstd} type(mr2) estimation with multiple mediators, random forests, and censored weights: {p_end}
 
{phang2}{cmd:. dmlmed std_cesd_age40 ever_unemp_age3539 log_faminc_adj_age3539, type(mr2) model(rforest) dvar(att22) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) censor} {p_end}

{pstd} type(mr2) estimation with multiple mediators, the LASSO, and censored weights: {p_end}
 
{phang2}{cmd:. dmlmed std_cesd_age40 ever_unemp_age3539 log_faminc_adj_age3539, type(mr2) model(lasso) dvar(att22) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) censor} {p_end}

{title:Saved results}

{pstd}{cmd:dmlmed} saves the following results in {cmd:e()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:e(results)}}matrix containing direct, indirect and total effect estimates{p_end}


{title:Author}

{pstd}Geoffrey T. Wodtke {break}
Department of Sociology{break}
University of Chicago{p_end}

{phang}Email: wodtke@uchicago.edu


{title:References}

{pstd}Wodtke GT and Zhou X. Causal Mediation Analysis. In preparation. {p_end}

{title:Also see}

{psee}
Help: {manhelp rforest R} {manhelp lasso2 R} {manhelp lassologit R}
{p_end}
