*** Purpose: descriptive statistics
*** Author: S Bauldry
*** Date: August 1, 2017

use nlalt-data, replace

*** creating figure illustrating trajectories
preserve
collapse (mean) bw2 w1-w12
rename bw2 w0
gen id = 9999
reshape long w, i(id) j(wave)
tempfile d1
save `d1', replace
restore

preserve
keep bw2 w1-w12
keep if !mi(bw2, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12)
rename bw2 w0
gen id = _n
set seed 32006947
gen r = runiform()
sort r
keep if _n <= 50
reshape long w, i(id) j(wave)
append using `d1'
gen age = wave
recode age (1 = 0.17) (2 = 0.33) (3 = 0.5) (4 = 0.67) (5 = 0.83) (6 = 1) ///
  (7 = 1.17) (8 = 1.33) (9 = 1.5) (10 = 1.67) (11 = 1.83) (12 = 2)
forval i = 1/50 {
  local plotline "`plotline' plot`i'( lp(solid) lc(gs10) ) "
}
format w %5.0f
xtline w, t(age) i(id) overlay legend(off) scheme(s1mono) `plotline' ///
  plot51( lp(solid) lc(black) lw(thick) ) ytit("weight (kg)")        ///
  ylab(0(3)15, angle(h) grid gstyle(dot)) xlab(0(.4)2, grid gstyle(dot))
graph export ~/desktop/nlalt-fig3.pdf, replace
restore



*** plotting results from model (Figure 4)
preserve
mat l1 = (0.17, 0.33, 0.50, 0.67, 0.83, 1, 1.17, 1.33, 1.50, 1.67, 1.83, 2)
mat l2 = (0.03, 0.11, 0.25, 0.44, 0.69, 1, 1.36, 1.78, 2.25, 2.78, 3.36, 4)
mat g1 = (0.576, 0.587, 0.404, 0.185, 0.121, 0.262, 0.111, 0.284, 0.149, ///
  0.265, 0.123, 0.101)

rename bw2 w0
forval i = 1/12 {
	local j = `i' - 1
	gen p`i' = 2.878 - l1[1,`i']*0.080 + l2[1,`i']*0.272 + ///
	           g1[1,`i']*d`i' + 0.619*w`j'
}

collapse (mean) w0 p1-p12
rename (p1-p12) (w1 w2 w3 w4 w5 w6 w7 w8 w9 w10 w11 w12)
gen id = 10000
reshape long w, i(id) j(wave)
tempfile d1
save `d1', replace
restore

preserve
keep bw2 w1-w12
keep if !mi(bw2, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12)
rename bw2 w0
gen id = _n
set seed 35514197
gen r = runiform()
sort r
keep if _n <= 50
reshape long w, i(id) j(wave)
append using `d1'
gen age = wave
recode age (1 = 0.17) (2 = 0.33) (3 = 0.5) (4 = 0.67) (5 = 0.83) (6 = 1) ///
  (7 = 1.17) (8 = 1.33) (9 = 1.5) (10 = 1.67) (11 = 1.83) (12 = 2)
forval i = 1/50 {
  local plotline "`plotline' plot`i'( lp(solid) lc(gs10) ) "
}
format w %5.0f
xtline w, t(age) i(id) overlay legend(off) scheme(s1mono) `plotline' ///
  plot51( lp(dash) lc(black) lw(thick) ) ytit("weight (kg)")        ///
  ylab(0(3)15, angle(h) grid gstyle(dot)) xlab(0(.4)2, grid gstyle(dot))
graph export ~/desktop/nlalt-fig4.pdf, replace
restore
