*** Purpose: prepare CLHNS data for nlalt examples
*** Author: S Bauldry
*** Date: August 1, 2017

*** Extracting data from files provided by Linda Adair
global fe "~/dropbox/research/data/clhns/predbw3.dta"
global wt "~/dropbox/research/data/clhns/anthrenamed.dta"

use uncchdid sex bw2 smoked agecat1 agecat2 agecat3 using $fe, replace
rename (sex smoked agecat1 agecat2 agecat3) (male smk age1 age2 age3)
replace bw2 = bw2/1000

merge 1:1 uncchdid using $wt, keepusing(weight1-weight12 agey1-agey12)
drop if _merge != 3
drop _merge

rename (weight1-weight12) (w1 w2 w3 w4 w5 w6 w7 w8 w9 w10 w11 w12)

forval i = 1/12 {
	gen d`i' = ( agey`i' - (`i'*2/12) )*12
}

*** Selecting analysis variables and analysis sample
keep if !male & !mi(bw2)
order uncchdid smk age1 age2 age3 bw2 w1-w12 d1-d12
keep uncchdid-d12

*** Saving data for analysis
save nlalt-data, replace
recode _all (. = -9)
desc
outsheet using nlalt-mplus-data.txt, replace comma nolabel noname

