*** Purpose: prepare CLHNS data for nlalt examples
*** Author: S Bauldry
*** Date: August 1, 2017

*** Extracting data from files provided by Linda Adair
global fe "~/dropbox/research/data/clhns/predbw3.dta"
global wt "~/dropbox/research/data/clhns/anthrenamed.dta"
global bp "~/dropbox/research/data/clhns/bpic980205.dta"

use uncchdid sex bw2 smoked agecat1 agecat2 agecat3 using $fe, replace
rename (sex smoked agecat1 agecat2 agecat3) (male smk ma1 ma2 ma3)
replace bw2 = bw2/1000

merge 1:1 uncchdid using $wt, keepusing(weight1-weight15 agey1-agey15)
drop if _merge != 3
drop _merge

recode weight15 (-6 = .)
rename (weight1-weight15) (w1 w2 w3 w4 w5 w6 w7 w8 w9 w10 w11 w12 w13 w14 w15)

forval i = 1/12 {
	gen d`i' = ( agey`i' - (`i'*2/12) )*12
}
gen d13 = agey13 - 8
gen d14 = agey14 - 11
gen d15 = agey15 - 15 if male == 0
replace d15 = agey15 - 16 if male == 1

merge 1:1 uncchdid using $bp

foreach x in sbp dbp {
	egen `x'17 = rowmean(`x'2005a `x'2005b `x'2005c)
	replace `x'17 = . if pregnant2005 == 1
}

*** Selecting analysis variables and analysis sample
keep if !male & !mi(bw2)
order uncchdid smk ma1 ma2 ma3 bw2 w1-w15 d1-d15 sbp17 dbp17
keep uncchdid-dbp17

*** Saving data for analysis
save nlalt-data, replace
recode _all (. = -9)
desc
outsheet using nlalt-mplus-data.txt, replace comma nolabel noname
