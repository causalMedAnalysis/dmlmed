*!TITLE: DMLMED - causal mediation analysis using de-biased machine learning
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1 
*!


program define mr2lasso, rclass
	
	version 15	

	syntax varlist(min=2 numeric) [if][in], ///
		dvar(varname numeric) ///
		d(real) ///
		dstar(real) ///
		[ cvars(varlist numeric) ///
		xfits(integer 5) ///
		seed(integer 12345) ///
		censor(numlist min=2 max=2) * ] 
	
	qui {
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000
		local N = r(N)
	}
			
	gettoken yvar mvars : varlist
	
	tempvar dvar_orig 
	qui gen `dvar_orig' = `dvar'
	
	qui set seed `seed'
	tempvar u kpart
	qui gen `u' = uniform() if `touse'
	qui sort `u'
	qui count if !(`touse')
	local numNotToUse = r(N)
	qui gen `kpart' = ceil(_n/((_N-`numNotToUse')/`xfits')) if `touse'
	
	local tvars ///
		pi`d'_C pi`dstar'_C ///
		pi`d'_CM pi`dstar'_CM ///
		mu`dstar'_CM mu`d'_CM ///
		nu`d'Ofmu`d'_C nu`dstar'Ofmu`d'_C nu`dstar'Ofmu`dstar'_C
				
	tempvar `tvars'
	
	foreach v in `tvars' {
		qui gen ``v'' = . if `touse'
	}

	local inter 
	foreach m in `mvars' {
		tempvar i_`m'
		qui gen `i_`m'' = `dvar' * `m' if `touse'
		local inter `inter' `i_`m''
	}

	local cxd_vars 
	foreach c in `cvars' {
		tempvar `dvar'X`c'
		qui gen ``dvar'X`c'' = `dvar' * `c' if `touse'
		local cxd_vars `cxd_vars' ``dvar'X`c''
	}

	local i = 1
	local cxm_vars 
	foreach c in `cvars' {
		foreach m in `mvars' {
			tempvar mXc`i'
			qui gen `mXc`i'' = `m' * `c' if `touse'
			local cxm_vars `cxm_vars' `mXc`i''
			local ++i
		}
	}
	
	forval k=1/`xfits' {
		
		di "xfit = `k' ..."
		di "   Training LASSO logit model for `dvar' given C"
		qui lassologit `dvar' `cvars' if `kpart'!=`k' & `touse', lic(aic) postres 
		
		tempvar	phat_D1_C
		qui predict `phat_D1_C' if `kpart'==`k' & `touse', pr
		qui replace `pi`d'_C' = `phat_D1_C'*`d' + (1-`phat_D1_C')*(1-`d') if `kpart'==`k' & `touse'
		qui replace `pi`dstar'_C' = `phat_D1_C'*`dstar' + (1-`phat_D1_C')*(1-`dstar') if `kpart'==`k' & `touse'
		
		di "   Training LASSO logit model for `dvar' given {C,M}"
		qui lassologit `dvar' `mvars' `cvars' `cxm_vars' if `kpart'!=`k' & `touse', lic(aic) postres 
		
		tempvar	phat_D1_CM
		qui predict `phat_D1_CM' if `kpart'==`k' & `touse', pr
		qui replace `pi`d'_CM' = `phat_D1_CM'*`d' + (1-`phat_D1_CM')*(1-`d') if `kpart'==`k' & `touse'
		qui replace `pi`dstar'_CM' = `phat_D1_CM'*`dstar' + (1-`phat_D1_CM')*(1-`dstar') if `kpart'==`k' & `touse'
		
		di "   Training LASSO regression model for `yvar' given {C,D,M}"
		qui lasso2 `yvar' `dvar' `mvars' `inter' `cvars' `cxd_vars' `cxm_vars' if `kpart'!=`k' & `touse', lic(aic) postres `options'

		qui replace `dvar' = `dstar' if `touse'
	
		foreach m in `mvars' {
			qui replace `i_`m'' = `dvar' * `m' if `touse'
		}
			
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
		}
		
		tempvar xxmu`dstar'_CM
		qui predict `xxmu`dstar'_CM' if `touse'
		qui replace `mu`dstar'_CM' = `xxmu`dstar'_CM' if `kpart'==`k' & `touse'

		qui replace `dvar' = `d' if `touse'
		
		foreach m in `mvars' {
			qui replace `i_`m'' = `dvar' * `m' if `touse'
		}
			
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
		}
		
		tempvar xxmu`d'_CM
		qui predict `xxmu`d'_CM' if `touse'
		qui replace `mu`d'_CM' = `xxmu`d'_CM' if `kpart'==`k' & `touse'
	
		qui replace `dvar' = `dvar_orig' if `touse'
		
		foreach m in `mvars' {
			qui replace `i_`m'' = `dvar' * `m' if `touse'
		}
			
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
		}
		
		di "   Training LASSO regression model for mu`d'(C,M) given {C,D}"
		qui lasso2 `xxmu`d'_CM' `dvar' `cvars' `cxd_vars' if `kpart'!=`k' & `touse', lic(aic) postres `options'
			
		qui replace `dvar' = `d' if `touse'

		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
		}
		
		tempvar xxnu`d'Ofmu`d'_C
		qui predict `xxnu`d'Ofmu`d'_C' if `touse'
		qui replace `nu`d'Ofmu`d'_C' = `xxnu`d'Ofmu`d'_C' if `kpart'==`k' & `touse'
	
		qui replace `dvar' = `dstar' if `touse'
		
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
		}
		
		tempvar xxnu`dstar'Ofmu`d'_C
		qui predict `xxnu`dstar'Ofmu`d'_C' if `touse'
		qui replace `nu`dstar'Ofmu`d'_C' = `xxnu`dstar'Ofmu`d'_C' if `kpart'==`k' & `touse'
		
		qui replace `dvar' = `dvar_orig' if `touse'

		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
		}

		di "   Training LASSO regression model for mu`dstar'(C,M) given {C,D}"
		qui lasso2 `xxmu`dstar'_CM' `dvar' `cvars' `cxd_vars' if `kpart'!=`k' & `touse', lic(aic) postres `options'
	
		qui replace `dvar' = `dstar' if `touse'
		
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
		}
		
		tempvar xxnu`dstar'Ofmu`dstar'_C
		qui predict `xxnu`dstar'Ofmu`dstar'_C' if `touse'
		qui replace `nu`dstar'Ofmu`dstar'_C' = `xxnu`dstar'Ofmu`dstar'_C' if `kpart'==`k' & `touse'

		qui replace `dvar' = `dvar_orig' if `touse'
		
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
		}
		
		capture drop ///
			`phat_D0_C' `phat_D1_C' ///
			`phat_D0_CM' `phat_D1_CM' ///
			`xxmu`dstar'_CM' `xxmu`d'_CM' ///
			`xxnu`d'Ofmu`d'_C' `xxnu`dstar'Ofmu`d'_C' `xxnu`dstar'Ofmu`dstar'_C'

	}

	tempvar ipw`dstar'C ipw`d'C ipw`dstar'`d'CM
	
	qui gen `ipw`d'C' = 0 if `touse'
	qui replace `ipw`d'C' = 1/`pi`d'_C' if `dvar'==`d' & `touse'
	
	qui gen `ipw`dstar'C' = 0 if `touse'
	qui replace `ipw`dstar'C' = 1/`pi`dstar'_C' if `dvar'==`dstar' & `touse'
	
	qui gen `ipw`dstar'`d'CM' = 0 if `touse'
	qui replace `ipw`dstar'`d'CM' = (1/`pi`dstar'_C')*(`pi`dstar'_CM'/`pi`d'_CM') if `dvar'==`d' & `touse'
	
	if ("`censor'"!="") {
		qui centile `ipw`d'C' if `ipw`d'C'!=. & `dvar'==`d' & `touse', c(`censor') 
		qui replace `ipw`d'C'=r(c_1) if `ipw`d'C'<r(c_1) & `ipw`d'C'!=. & `dvar'==`d' & `touse'
		qui replace `ipw`d'C'=r(c_2) if `ipw`d'C'>r(c_2) & `ipw`d'C'!=. & `dvar'==`d' & `touse'
	
		qui centile `ipw`dstar'C' if `ipw`dstar'C'!=. & `dvar'==`dstar' & `touse', c(`censor') 
		qui replace `ipw`dstar'C'=r(c_1) if `ipw`dstar'C'<r(c_1) & `ipw`dstar'C'!=. & `dvar'==`dstar' & `touse'
		qui replace `ipw`dstar'C'=r(c_2) if `ipw`dstar'C'>r(c_2) & `ipw`dstar'C'!=. & `dvar'==`dstar' & `touse'

		qui centile `ipw`dstar'`d'CM' if `ipw`dstar'`d'CM'!=. & `dvar'==`d' & `touse', c(`censor') 
		qui replace `ipw`dstar'`d'CM'=r(c_1) if `ipw`dstar'`d'CM'<r(c_1) & `ipw`dstar'`d'CM'!=. & `dvar'==`d' & `touse'
		qui replace `ipw`dstar'`d'CM'=r(c_2) if `ipw`dstar'`d'CM'>r(c_2) & `ipw`dstar'`d'CM'!=. & `dvar'==`d' & `touse'
	}

	tempvar dr`d'`d'_summand
	qui gen `dr`d'`d'_summand' = `ipw`d'C'*(`yvar' - `mu`d'_CM') ///
		+ `ipw`d'C'*(`mu`d'_CM' - `nu`d'Ofmu`d'_C') ///
		+ `nu`d'Ofmu`d'_C'
		
	tempvar dr`dstar'`dstar'_summand
	qui gen `dr`dstar'`dstar'_summand' = `ipw`dstar'C'*(`yvar' - `mu`dstar'_CM') ///
		+ `ipw`dstar'C'*(`mu`dstar'_CM' - `nu`dstar'Ofmu`dstar'_C') ///
		+ `nu`dstar'Ofmu`dstar'_C'

	tempvar dr`dstar'`d'_summand
	qui gen `dr`dstar'`d'_summand' = `ipw`dstar'`d'CM'*(`yvar' - `mu`d'_CM') ///
		+ `ipw`dstar'C'*(`mu`d'_CM' - `nu`dstar'Ofmu`d'_C') ///
		+ `nu`dstar'Ofmu`d'_C'
			
	tempvar eifATE eifNDE eifNIE
	qui gen `eifATE' = `dr`d'`d'_summand' - `dr`dstar'`dstar'_summand'
	qui gen `eifNDE' = `dr`dstar'`d'_summand' - `dr`dstar'`dstar'_summand'
	qui gen `eifNIE' = `dr`d'`d'_summand' - `dr`dstar'`d'_summand'
	
	qui mean `eifATE' `eifNDE' `eifNIE'
	return scalar ate = _b[`eifATE']
	return scalar nde = _b[`eifNDE']
	return scalar nie = _b[`eifNIE']
	
	return scalar se_ate = _se[`eifATE']
	return scalar se_nde = _se[`eifNDE']
	return scalar se_nie = _se[`eifNIE']
	
	return scalar ll95_ate = _b[`eifATE']-1.96*_se[`eifATE']
	return scalar ll95_nde = _b[`eifNDE']-1.96*_se[`eifNDE']
	return scalar ll95_nie = _b[`eifNIE']-1.96*_se[`eifNIE']

	return scalar ul95_ate = _b[`eifATE']+1.96*_se[`eifATE']
	return scalar ul95_nde = _b[`eifNDE']+1.96*_se[`eifNDE']
	return scalar ul95_nie = _b[`eifNIE']+1.96*_se[`eifNIE']

	return scalar pval_ate = (1-normal(abs(_b[`eifATE']/_se[`eifATE'])))*2
	return scalar pval_nde = (1-normal(abs(_b[`eifNDE']/_se[`eifNDE'])))*2
	return scalar pval_nie = (1-normal(abs(_b[`eifNIE']/_se[`eifNIE'])))*2

end mr2lasso
