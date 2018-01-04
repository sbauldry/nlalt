*** Purpose: simulation study for NLALT
*** Author: S Bauldry
*** Date: January 2, 2018

*** Setting working directory
cd "~/dropbox/research/statistics/nlalt/nlalt-work"

****** Data generation
forval m = 1/500 {
	clear
	
	* setting parameters
	local N     = 5000  // sample size
	local m_y1  = 0     // mean of y1
	local m_a   = 0     // mean of intercept
	local m_b   = 1     // mean of linear term
	local m_c   = 2     // mean of quadratic term
	local v_y1  = 0.1   // variance of y1
	local v_a   = 1.5   // variance of intercept
	local v_b   = 0.3   // variance of linear term
	local v_c   = 0.1   // variance of quadratic term
	local v_e2  = 0.15  // variance of error term 2
	local v_e3  = 2     // variance of error term 3
	local v_e4  = 3     // variance of error term 4
	local v_e5  = 4     // variance of error term 5
	local rho   = 0.2   // autoregressive term
	
	* generate exogenous variables (y1, alpha, beta, beta2)
	mat m = (`m_y1', `m_a', `m_b', `m_c')
	mat c = (`v_y1',     0,     0,     0 \ ///
	              0, `v_a',     0,     0 \ ///
	              0,     0, `v_b',     0 \ ///
				  0,     0,     0, `v_c')
	qui drawnorm y1 a b c, n(`N') cov(c) mean(m)
	
	* generate four additional waves
	gen y2 = a +   b +    c + `rho'*y1 + rnormal(0, sqrt(`v_e2'))
	gen y3 = a + 2*b +  4*c + `rho'*y2 + rnormal(0, sqrt(`v_e3'))
	gen y4 = a + 3*b +  9*c + `rho'*y3 + rnormal(0, sqrt(`v_e4'))
	gen y5 = a + 4*b + 16*c + `rho'*y4 + rnormal(0, sqrt(`v_e5'))

	* save data for Mplus
	keep y1 y2 y3 y4 y5
	outsheet using ~/desktop/nlalt-sim-data/d`m'.txt, replace comma noname
}


*** Figure to check functional form and variance of simulated data
preserve
collapse (mean) y1-y5
gen id = 9999
reshape long y, i(id) j(wave)
tempfile d1
save `d1', replace
restore

preserve
gen id = _n
gen r = runiform()
sort r
keep if _n <= 50
reshape long y, i(id) j(wave)
append using `d1'
forval i = 1/50 {
  local plotline "`plotline' plot`i'( lp(solid) lc(gs10) ) "
}
format y %5.0f
xtline y, t(wave) i(id) overlay legend(off) scheme(s1mono) `plotline' ///
  plot51( lp(solid) lc(black) lw(thick) ) 
restore


*** Checking distribution of observed variables
sum y1-y5
cor y1-y5, cov




****** Extracting information from Mplus output
capture program drop MpExt
program MpExt
	args mdl fn pf
	
	* Check for error
	qui insheet using "`fn'", clear
	qui gen flag = regexm(v1, "WARNING")
	qui tab flag
	local err = ( r(r) > 1 )
	
	* Extract model fit
	qui insheet using "`fn'", clear
	qui gen flag     = 0
	qui gen flag1    = regexm(v1, "Chi-Square Test of Model Fit") 
	qui replace flag = 1 if flag1[_n - 1] == 1
	qui replace flag = 1 if flag1[_n - 2] == 1
	qui replace flag = 1 if flag1[_n - 3] == 1
	qui replace flag = 1 if flag1[_n - 5] == 1
	qui replace flag = 1 if flag1[_n - 9] == 1
	qui replace flag = 1 if flag1[_n - 10] == 1
	qui keep if flag
	qui drop if _n > 6
	
	qui split v1, gen(x) parse("")
	qui replace x2 = x4 if x2 == "of"
	qui destring x2, replace

	forval i = 1/6 {
		local mf`i' = x2[`i']
	}
	
	* Extract autoregressive parameter
	if ("`mdl'" == "ar" | "`mdl'" == "alt" | "`mdl'" == "qalt") {
		qui insheet using "`fn'", clear
		qui gen flag = 0
		qui gen flag1    = regexm(v1, "Y2       ON") 
		qui replace flag = 1 if flag1[_n - 1] == 1
		qui keep if flag
		qui drop if _n > 1
		qui split v1, gen(x) parse("") destring
		local rho = x2[1]
		local rse = x3[1]
	}
	if ("`mdl'" == "qgc") {
		local rho = .
		local rse = .
	}
	
	* Extract growth parameters
	if ("`mdl'" == "qalt" | "`mdl'" == "qgc" | "`mdl'" == "alt") {
		qui insheet using "`fn'", clear

		qui gen flag = 0
		qui gen flag1    = regexm(v1, "Means")
		if ("`mdl'" == "qalt" | "`mdl'" == "qgc") {
			qui replace flag = 1 if flag1[_n - 2] == 1
			qui replace flag = 1 if flag1[_n - 3] == 1
			qui replace flag = 1 if flag1[_n - 4] == 1
		}
		if ("`mdl'" == "alt") {
			qui replace flag = 1 if flag1[_n - 2] == 1
			qui replace flag = 1 if flag1[_n - 3] == 1
		}
		
		qui gen flag2    = regexm(v1, "Variances")
		if ("`mdl'" == "qalt" | "`mdl'" == "qgc") {
			qui replace flag = 1 if flag2[_n - 2] == 1
			qui replace flag = 1 if flag2[_n - 3] == 1
			qui replace flag = 1 if flag2[_n - 4] == 1
		}
		if ("`mdl'" == "alt") {
			qui replace flag = 1 if flag2[_n - 2] == 1
			qui replace flag = 1 if flag2[_n - 3] == 1
		}
		qui keep if flag
		
		qui split v1, gen(x) parse("") destring
		if ("`mdl'" == "qalt" | "`mdl'" == "qgc") {
			forval i = 1/6 {
				local p`i' = x2[`i']
			}
		}
		if ("`mdl'" == "alt") {
			forval i = 1/4 {
				local p`i' = x2[`i']
			}
			local p5 = .
			local p6 = .
		}

	}
	if ("`mdl'" == "ar") {
		forval i = 1/6 {
			local p`i' = .
		}
	}

	* post estimates
	post `pf' ("`mdl'") (`err') (`mf1') (`mf2') (`mf3') (`mf4') (`mf5') ///
	  (`mf6') (`rho') (`rse') (`p1') (`p2') (`p3') (`p4') (`p5') (`p6')
end


postutil clear
postfile PF1 str4 model error chisq df pval rmsea cfi tli rho rse e1 e2 e3 e4 ///
  e5 e6 using "nlalt-sim-res", replace
forval i = 1/500 {
	MpExt qalt "nlalt-sim-data/nlalt-sim-qalt-`i'.out" PF1
	MpExt alt "nlalt-sim-data/nlalt-sim-alt-`i'.out" PF1
	MpExt qgc "nlalt-sim-data/nlalt-sim-qgc-`i'.out" PF1
	MpExt ar "nlalt-sim-data/nlalt-sim-ar-`i'.out" PF1
}
postclose PF1



****** Analyzing simulation results
use nlalt-sim-res, replace

* Warnings
table model, c(mean error)

* Model fit statistics
gen sigchi   = ( pval < 0.05 )
gen bic      = chisq - ln(5000)*df
gen bic0     = ( bic < 0 )
gen sigrmsea = ( rmsea < 0.05 )
table model, c(mean chisq mean sigchi mean bic mean bic0)
table model, c(mean rmsea mean sigrmsea mean cfi mean tli)

* Parameter estimates
table model, c(mean rho mean e1 mean e2)
preserve
collapse (mean) rho e1-e6 (sd) srho = rho se1 = e1 se2 = e2 se3 = e3 ///
  se4 = e4 se5 = e5 se6 = e6, by(model)

foreach x in rho e1 e2 e3 e4 e5 e6 {
  gen ub_`x' = `x' + 2*s`x'
  gen lb_`x' = `x' - 2*s`x'
}

tempfile g1
gen mdl1 = 1.5 if model == "qalt"
replace mdl1 = 2 if model == "alt"
replace mdl1 = 2.5 if model == "ar"

graph twoway (rspike ub_rho lb_rho mdl1, lc(black) )                    ///
  (scatter rho mdl1, mc(black) msize(small) m(O)),                      ///
  scheme(s1mono) ylab(0 0.2 0.5 1 1.5 , angle(h) grid gstyle(dot))      ///
  ytit("estimate") xlab(1 " " 1.5 "QALT" 2 "ALT" 2.5 "AR" 3 " ",        ///
    grid gstyle(dot)) xtit("{bf:Model}") yline(0.2, lc(black) lp(dash)) ///
  tit("Autoregressive Parameter") legend(off) saving(`g1') 
  
 
tempfile g2 g3
gen mdl2 = 1.5 if model == "qalt"
replace mdl2 = 2 if model == "alt"
replace mdl2 = 2.5 if model == "qgc"

graph twoway (rspike ub_e1 lb_e1 mdl2, lc(black) )                    ///
  (scatter e1 mdl2, mc(black) msize(small) m(O)),                     ///
  scheme(s1mono) ylab(, angle(h) grid gstyle(dot))                    ///
  ytit("estimate") xlab(1 " " 1.5 "QALT" 2 "ALT" 2.5 "QLC" 3 " ",     ///
    grid gstyle(dot)) xtit("{bf:Model}") yline(0, lc(black) lp(dash)) ///
  tit("Mean of Latent Intercept") legend(off) saving(`g2') 
  
graph twoway (rspike ub_e2 lb_e2 mdl2, lc(black) )                    ///
  (scatter e2 mdl2, mc(black) msize(small) m(O)),                     ///
  scheme(s1mono) ylab(, angle(h) grid gstyle(dot))                    ///
  ytit("estimate") xlab(1 " " 1.5 "QALT" 2 "ALT" 2.5 "QLC" 3 " ",     ///
    grid gstyle(dot)) xtit("{bf:Model}") yline(1, lc(black) lp(dash)) ///
  tit("Mean of Latent Linear Term") legend(off) saving(`g3') 

tempfile g4
keep if model == "qalt" | model == "qgc"
gen mdl3 = 1.5 if model == "qalt"
replace mdl3 = 2 if model == "qgc"

graph twoway (rspike ub_e3 lb_e3 mdl3, lc(black) )                    ///
  (scatter e3 mdl3, mc(black) msize(small) m(O)),                     ///
  scheme(s1mono) ylab(1.5(0.5)3, angle(h) grid gstyle(dot))           ///
  ytit("estimate") xlab(1 " " 1.5 "QALT" 2 "QLC" 2.5 " ",             ///
    grid gstyle(dot)) xtit("{bf:Model}") yline(2, lc(black) lp(dash)) ///
  tit("Mean of Latent Quadratic Term") legend(off) saving(`g4') 
  
graph combine "`g1'" "`g2'" "`g3'" "`g4'", scheme(s1mono)
graph export ~/desktop/nlalt-fig2.pdf, replace
restore


