*** Purpose: descriptive statistics
*** Author: S Bauldry
*** Date: August 1, 2017

load nlalt-data, replace

*** creating figure illustrating trajectories
preserve
collapse (mean) bw2 w1-w15
rename bw2 w0
gen id = 9999
reshape long w, i(id) j(wave)
tempfile d1
save `d1', replace
restore

preserve
keep bw2 w1-w15
keep if !mi(bw2, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14)
keep if !mi(w15)
rename bw2 w0
gen id = _n
set seed 32006947
gen r = runiform()
sort r
keep if _n <= 50
reshape long w, i(id) j(wave)
append using `d1'
gen age = wave
recode age (1 = 0.17) (2 = 0.33) (3 = 0.5) (4 = 0.67) (5 = 0.83) (6 = 1)    ///
  (7 = 1.17) (8 = 1.33) (9 = 1.5) (10 = 1.67) (11 = 1.83) (12 = 2) (13 = 8) ///
  (14 = 11) (15 = 15)
forval i = 1/50 {
  local plotline "`plotline' plot`i'( lp(solid) lc(gs10) ) "
}
format w %5.0f
xtline w, t(age) i(id) overlay legend(off) scheme(s1mono) `plotline' ///
  plot51( lp(solid) lc(black) lw(thick) ) ytit("weight (kg)")        ///
  ylab(0(20)60, angle(h)) xlab(0(3)15)
graph export ~/desktop/nlalt-fig2.pdf, replace
restore
