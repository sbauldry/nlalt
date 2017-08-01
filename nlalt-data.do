*** Purpose: Prepare data for NL-ALT models
*** Author: S Bauldry
*** Date: July 22, 2014


*** setting working directory
cd "~/Dropbox/_Research/Statistics/nonlinear ALT/Work/Analysis"


****** Extracting fetal environment data ******
use "Raw Data/predbw3", replace

*** preparing variables
rename sex male 
replace bw2 = bw2/1000

keep uncchdid male bw2 smoked agecat1 agecat2 agecat3


****** Merging with growth data ******
merge 1:1 uncchdid using "Raw Data/anthrenamed"
drop if _merge != 3
drop _merge

*** preparing variables
recode weight15 (-6 = .)
rename (weight1-weight15) (w1 w2 w3 w4 w5 w6 w7 w8 w9 w10 w11 w12 w13 w14 w15)

forval i = 1/12 {
	gen da`i' = ( agey`i' - (`i'*2/12) )*12
}
gen da13 = agey13 - 8
gen da14 = agey14 - 11
gen da15 = agey15 - 15 if male == 0
replace da15 = agey15 - 16 if male == 1

keep uncchdid male bw2 smoked agecat1 agecat2 agecat3 w1-w15 da1-da15
	 
	 	 
****** Merging with blood pressure data ******
merge 1:1 uncchdid using "Raw data/bpic980205"
drop _merge

*** preparing variables
foreach x in sbp dbp {
	egen `x'17 = rowmean(`x'2005a `x'2005b `x'2005c)
}

rename pregnant2005 preg17      
foreach x of varlist sbp17 dbp17 {
	replace `x' = . if preg17 == 1
}      

****** Saving data for analysis ******
keep if !male & !mi(bw2)
keep uncchdid bw2 smoked agecat* w1-w15 da1-da15 sbp17 dbp17 preg17
save "CLHNS Example Data v1", replace

recode _all (. = -999)
desc
outsheet using "CLHNS Example Data v1.txt", replace comma nolabel noname

