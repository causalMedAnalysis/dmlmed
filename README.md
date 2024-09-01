# dmlmed: Causal Mediation Analysis Using De-biased Machine Learning

`dmlmed` is a Stata module designed to perform causal mediation analysis using de-biased machine learning (DML), specifically leveraging random forests to enhance robustness and reduce bias in estimates.

## Syntax

```stata
dmlmed varname, type(string) dvar(varname) mvar(varname) d(real) dstar(real) [options]
```

### Required Arguments

- `varname`: Specifies the outcome variable.
- `type(string)`: Type of multiply robust estimator, options are `mr1` and `mr2`.
  - `mr1`: Both the exposure and mediator must be binary and coded 0/1.
  - `mr2`: Exposure must be binary and coded 0/1; the mediator can be binary, ordinal, or continuous.
- `dvar(varname)`: Specifies the treatment variable, must be binary.
- `mvar(varname)`: Specifies the mediator variable.
- `d(real)`: Reference level of treatment.
- `dstar(real)`: Alternative level of treatment, defining the treatment contrast.

### Options

- `cvars(varlist)`: List of baseline covariates to be included.
- `xfits(integer)`: Number of cross-fitting sample partitions, default is 5.
- `ntrees(integer)`: Number of trees in each random forest, default is 200.
- `lsize(integer)`: Minimum leaf size in each tree, default is 20.
- `seed(integer)`: Seed for cross-fitting and random forests training.

## Description

`dmlmed` implements two types of de-biased machine learning estimations:
- **Type mr1**: Involves training three random forests for the exposure, mediator, and outcome based on the specified covariates.
- **Type mr2**: Involves training five forests, including additional regression forests for outcome imputations under different treatment levels.

These models are used to generate robust estimates of the natural direct effect, natural indirect effect, and the total effect.

## Examples

```stata
// Load data
use nlsy79.dta

// mr1 estimation with default settings
dmlmed std_cesd_age40, type(mr1) dvar(att22) mvar(ever_unemp_age3539) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0)

// mr2 estimation with default settings
dmlmed std_cesd_age40, type(mr2) dvar(att22) mvar(ever_unemp_age3539) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0)

// mr2 estimation with custom settings for cross-fits, trees, and leaf size
dmlmed std_cesd_age40, type(mr2) dvar(att22) mvar(ever_unemp_age3539) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) xfits(10) ntrees(500) lsize(5)
```

## Saved Results

`dmlmed` saves the following results in `e()`:

- **Matrices**:
  - `e(b)`: Matrix containing direct, indirect, and total effect estimates.

## Author

Geoffrey T. Wodtke  
Department of Sociology  
University of Chicago

Email: [wodtke@uchicago.edu](mailto:wodtke@uchicago.edu)

## References

- Wodtke GT and Zhou X. Causal Mediation Analysis. In preparation.

## Also See

- [rforest R](#)
