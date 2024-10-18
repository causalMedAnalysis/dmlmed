# dmlmed: A Stata Module for Causal Mediation Analysis using De-biased Machine Learning (DML)

## Overview

`dmlmed` is a Stata module that performs causal mediation analysis using de-biased machine learning (DML). The command supports implementation of DML using either random forests or LASSO models and requires prior installation of the `rforest` and `lassopack` modules.

## Syntax

```stata
dmlmed depvar mvars [if] [in], type(string) model(string) dvar(varname) d(real) dstar(real) [options]
```

### Required Arguments

- `type(string)`: Specifies which multiply robust estimator to implement. Options are `mr1` and `mr2`.
  - For `mr1`: both the exposure and a univariate mediator must be binary (0/1).
  - For `mr2`: only the exposure must be binary (0/1), and multiple mediators are permitted.
- `model(string)`: Specifies which machine learning algorithm is used to predict the nuisance terms. Options are:
  - `rforest`: random forests are used to predict the nuisance terms.
  - `lasso`: LASSO models with all two-way interactions are used to predict the nuisance terms.
- `depvar`: Specifies the outcome variable.
- `mvars`: Specifies the mediator(s), which can be multivariate with `type(mr2)` estimation.
- `dvar(varname)`: Specifies the treatment (exposure) variable, which must be binary (0/1).
- `d(real)`: Specifies the reference level of treatment.
- `dstar(real)`: Specifies the alternative level of treatment. Together, (d - dstar) defines the treatment contrast of interest.

### Options

- `cvars(varlist)`: Specifies the list of baseline covariates to be included in the analysis. Categorical variables must be coded as dummy variables.
- `xfits(integer)`: Specifies the number of sample partitions to use for cross-fitting (default is 5).
- `seed(integer)`: Specifies the seed for cross-fitting and model training.
- `censor(numlist)`: Specifies that the inverse probability weights used in the robust estimating equations are censored at the percentiles provided in `numlist'.
- `rforest_options`: All `rforest` options are available when using `model(rforest)`.
- `lasso2_options`: All `lasso2` options are available when using `model(lasso)`.

## Description

`dmlmed` performs causal mediation analysis using de-biased machine learning (DML). Currently, the command supports implementation of DML with random forests and LASSO regression. It requires prior installation of the `rforest` and `lassopack` modules. Inferential statistics are computed using analytic standard errors and a normal approximation. 

For `type(mr1)` estimation, three models are trained: 
1. A model for the exposure conditional on baseline covariates.
2. A model for a single binary mediator conditional on the exposure and baseline covariates.
3. A model for the outcome conditional on the exposure, mediator, and baseline covariates.

These models are then used to construct weights and imputations for a set of multiply robust estimating equations that target the total, natural direct, and natural indirect effects through a single binary mediator.

For `type(mr2)` estimation, five models are trained:
1. A model for the exposure conditional on baseline covariates.
2. A model for the exposure conditional on the mediator(s) and baseline confounders.
3. A model for the outcome conditional on the exposure, mediator(s), and baseline covariates.
4. A model for the imputations from model (3) under the reference level of treatment.
5. A model for the imputations from model (3) under the alternative level of treatment.

These models are then used to construct weights and imputations for another set of multiply robust estimating equations that also target the natural effects decomposition. Because `type(mr2)` estimation does not require modeling the mediator(s), it can be used with several different types of mediators (binary, ordinal, or continuous) and also supports analyses of multiple mediators. When multiple mediators are specified, `type(mr2)` estimation targets multivariate natural direct and indirect effects.

When `model(rforest)` is specified, all the models outlined previously are fit using random forests. Alternatively, when `model(lasso)` is specified, these models are fit using the LASSO with all two-way interactions included.

## Examples

### Example 1: type(mr1) estimation with random forests and censored weights

```stata
. use nlsy79.dta
. dmlmed std_cesd_age40 ever_unemp_age3539, type(mr1) model(rforest) dvar(att22) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) censor(1 99)
```

### Example 2: type(mr1) estimation with random forests, censored weights, and custom hyperparameters

```stata
. dmlmed std_cesd_age40 ever_unemp_age3539, type(mr1) model(rforest) dvar(att22) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) censor(1 99) iter(200) numvars(5) lsize(5)
```

### Example 3: type(mr1) estimation with LASSO and censored weights

```stata
. dmlmed std_cesd_age40 ever_unemp_age3539, type(mr1) model(lasso) dvar(att22) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) censor(1 99)
```

### Example 4: type(mr2) estimation with random forests, censored weights, and custom hyperparameters

```stata
. dmlmed std_cesd_age40 ever_unemp_age3539, type(mr2) model(rforest) dvar(att22) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) censor(1 99) iter(200) numvars(5) lsize(5)
```

### Example 5: type(mr2) estimation with multiple mediators, random forests, and censored weights

```stata
. dmlmed std_cesd_age40 ever_unemp_age3539 log_faminc_adj_age3539, type(mr2) model(rforest) dvar(att22) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) censor(1 99)
```

### Example 6: type(mr2) estimation with multiple mediators, LASSO, and censored weights

```stata
. dmlmed std_cesd_age40 ever_unemp_age3539 log_faminc_adj_age3539, type(mr2) model(lasso) dvar(att22) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) censor(1 99)
```

## Saved Results

The following results are saved in `e()`:

- **Matrices:**
  - `e(results)`: Matrix containing total, direct, and indirect effect estimates.

## Author

**Geoffrey T. Wodtke**  
Department of Sociology  
University of Chicago  
Email: [wodtke@uchicago.edu](mailto:wodtke@uchicago.edu)

## References

- Wodtke GT and Zhou X. *Causal Mediation Analysis*. In preparation.

## See Also

- rforest, lasso2, lassologit
