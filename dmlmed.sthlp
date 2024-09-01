{smcl}
{* *! version 0.1, 1 July 2024}{...}
{cmd:help for dmlmed}{right:Geoffrey T. Wodtke}
{hline}

{title:Title}

{p2colset 5 18 18 2}{...}
{p2col : {cmd:dmlmed} {hline 2}}causal mediation analysis using de-biased machine learning{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 18 2}
{cmd:dmlmed} {varname} {ifin}{cmd:,} type(string) dvar({varname}) mvar({varname}) d({it:real}) dstar({it:real}) 
[cvars({varlist})) xfits(integer) ntrees(integer) lsize(integer) seed(integer)]

{phang}{opt varname} - this specifies the outcome variable.

{phang}{opt type(string)} - this specifies which multiply robust estimator to implement. Options are mr1 and mr2. 
For type mr1, both the exposure and mediator must be binary (0/1). For type mr2, only the exposure must be binary (0/1).

{phang}{opt dvar(varname)} - this specifies the treatment (exposure) variable. This variable must be binary (0/1).

{phang}{opt mvar(varname)} - this specifies the mediator variable. This variable must be binary (0/1) for type mr1 robust estimation.
For type mr2, it may be binary, ordinal, or continuous.

{phang}{opt d(real)} - this specifies the reference level of treatment.

{phang}{opt dstar(real)} - this specifies the alternative level of treatment. Together, (d - dstar) defines
the treatment contrast of interest.

{title:Options}

{phang}{opt cvars(varlist)} - this option specifies the list of baseline covariates to be included in the analysis. Categorical 
variables need to be coded as a series of dummy variables before being entered as covariates.

{phang}{opt xfits(integer)} - this option specifies the number of sample partitions to use for cross-fitting (the default is 5).

{phang}{opt ntrees(integer)} - this option specifies the number of trees to include in the random forest (the default is 200).

{phang}{opt lsize(integer)} - this option specifies the minimum leaf size for each tree in the random forest (the default is 20).

{phang}{opt seed(integer)} - this option specifies the seed for cross-fitting and the random forests. {p_end}

{title:Description}

{pstd}{cmd:dmlmed} performs causal mediation analysis using de-biased machine learning (DML). Currently, the command supports 
implementation of DML only with random forests. It requires prior installation of the {cmd:rforest} module {p_end}

{pstd}For type mr1 estimation, three random forests are trained: (1) a classification for the exposure conditional on baseline covariates 
(if specified), (2) a classification forest for the mediator conditional on the exposure and baseline covariates, and (3) a regression forest 
for the outcome conditional on the exposure, mediator, and baseline covariates (if specified). These models are then used to construct weights 
and imputations for a set of multiply robust estimating equations that target the total, natural direct, and natural indirect effects. {p_end}

{pstd}For type mr2 estimation, five forests are estimated: (1) a classification for the exposure conditional on baseline covariates (if specified), 
(2) another classification forest for the exposure conditional on the mediator and baseline confounders, (3) a regression forest for the outcome 
conditional on the exposure, mediator, and baseline covariates, (4) regression forest for the imputations from model (3) under the reference level of 
treatment, and (5) a regression forest for the imputations from model (3) under the alternative level of treatment. These models are then used to 
construct weights and imputations for another set of multiply robust estimating equations that also target the total, natural direct, and natural 
indirect effects. Because type mr2 estimation does not require a model for the mediator, it can be used several different types of mediators 
(binary, ordinal, or continuous). {p_end}

{pstd}{cmd:dmlmed} provides estimates of the the natural direct effect, the natural indirect effect, and the total effect. {p_end}

{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. use nlsy79.dta} {p_end}

{pstd} type mr1 estimation with default settings: {p_end}
 
{phang2}{cmd:. dmlmed std_cesd_age40, type(mr1) dvar(att22) mvar(ever_unemp_age3539) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0)} {p_end}

{pstd} type mr2 estimation with default settings: {p_end}
 
{phang2}{cmd:. dmlmed std_cesd_age40, type(mr2) dvar(att22) mvar(ever_unemp_age3539) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0)} {p_end}

{pstd} type mr2 estimation with 10 sample partitions for cross-fitting, 500 trees in each forest, a minimum leaf size of 5: {p_end}
 
{phang2}{cmd:. dmlmed std_cesd_age40, type(mr2) dvar(att22) mvar(ever_unemp_age3539) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) xfits(10) ntrees(500) lsize(5)} {p_end}

{title:Saved results}

{pstd}{cmd:dmlmed} saves the following results in {cmd:e()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}matrix containing direct, indirect and total effect estimates{p_end}


{title:Author}

{pstd}Geoffrey T. Wodtke {break}
Department of Sociology{break}
University of Chicago{p_end}

{phang}Email: wodtke@uchicago.edu


{title:References}

{pstd}Wodtke GT and Zhou X. Causal Mediation Analysis. In preparation. {p_end}

{title:Also see}

{psee}
Help: {manhelp rforest R}
{p_end}
