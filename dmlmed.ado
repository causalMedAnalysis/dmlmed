*!TITLE: DMLMED - causal mediation analysis using de-biased machine learning
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1 
*!


program define dmlmed, eclass

	version 15	

	syntax varname(numeric) [if][in], ///
		type(string) ///
		dvar(varname numeric) ///
		mvar(varname numeric) ///
		d(real) ///
		dstar(real) ///
		[cvars(varlist numeric)] ///
		[xfits(integer 5)] ///
		[ntrees(integer 200)] ///
		[lsize(integer 20)] ///
		[seed(integer 12345)] 

	qui {
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000
	}

	local mrtypes mr1 mr2
	local nmrtype : list posof "`type'" in mrtypes
	if !`nmrtype' {
		display as error "Error: type must be chosen from: `mrtypes'."
		error 198		
		}
	
	capture which rforest
	if _rc {
		display as error "{p 0 0 5 0} A required package is not installed."
		display as error "This module depends on rforest."
		display as error "Install using -ssc install rforest-"
		exit 198
		}
	
	if ("`type'"=="mr1") {
	
		foreach i in `dvar' `mvar' {
			confirm variable `i'
			qui sum `i'
			if r(min) != 0 | r(max) != 1 {
				display as error "{p 0 0 5 0} The variable `i' is not binary and coded 0/1"
				error 198
				}
			}

		dmlmed_type1 `varlist' if `touse', ///
			dvar(`dvar') mvar(`mvar') cvars(`cvars') ///
			d(`d') dstar(`dstar') xfits(`xfits') ntrees(`ntrees') lsize(`lsize') seed(`seed')
			
		}

	if ("`type'"=="mr2") {

		confirm variable `dvar'
		qui sum `dvar'
		if r(min) != 0 | r(max) != 1 {
			display as error "{p 0 0 5 0} The variable `dvar' is not binary and coded 0/1"
			error 198
			}
		
		dmlmed_type2 `varlist' if `touse', ///
			dvar(`dvar') mvar(`mvar') cvars(`cvars') ///
			d(`d') dstar(`dstar') xfits(`xfits') ntrees(`ntrees') lsize(`lsize') seed(`seed')
				
		}
	
	matrix results = ///
		(r(ate), r(se_ate), r(pval_ate), r(ll95_ate), r(ul95_ate) \ ///
		r(nde), r(se_nde), r(pval_nde), r(ll95_nde), r(ul95_nde) \ ///
		r(nie), r(se_nie), r(pval_nie), r(ll95_nie), r(ul95_nie))
			
	matrix rownames results = "ATE" "NDE" "NIE"
	matrix colnames results = "Est." "Std. Err." "P>|z|" "[95% Conf." "Interval]"

	matrix list results
		
end dmlmed
