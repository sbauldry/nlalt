*** Purpose: to examine outlier and influential case diagnostics
*** Author: S Bauldry
*** Date: August 18, 2017


*** reading Mplus output data
infile w1-w12 w0 d1-d12 id qm qmp using nlalt-4-qalt-diag1.txt, clear
order id qm qmp w0 w1-w12
keep id-w12
tempfile d1
save `d1', replace

infile w1-w12 w0 d1-d12 id qc using nlalt-4-qalt-diag2.txt, clear
keep id qc
tempfile d2
save `d2', replace

infile w1-w12 w0 d1-d12 id qi using nlalt-4-qalt-diag3.txt, clear
keep id qi
tempfile d3
save `d3', replace

infile v1-v25 id lm lmp using nlalt-5-lbalt-diag1.txt, clear
keep id lm lmp
tempfile d4
save `d4', replace

infile v1-v25 id li lc using nlalt-5-lbalt-diag2.txt, clear
keep id li lc
tempfile d5
save `d5', replace

use `d1', replace
forval i = 2/5 {
	merge 1:1 id using `d`i''
	drop _merge
}

*** flagging cases with MD p-value < 0.001
*** flagging cases with Cook's D and influence in top percentile
gen qmchk = (qmp < 0.001)

qui sum qc, detail
gen qcchk = (qc > r(p99))

qui sum qi, detail
gen qichk = (qi > r(p99))

gen qflg = (qmchk == 1 | qcchk == 1 | qichk == 1)

gen lmchk = (lmp < 0.001)

qui sum lc, detail
gen lcchk = (lc > r(p99))

qui sum li, detail
gen lichk = (li > r(p99))

gen lflg = (lmchk == 1 | lcchk == 1 | lichk == 1)

*** checking cases
tab qmchk qcchk
tab qmchk qichk
tab qcchk qichk

tab lmchk lcchk
tab lmchk lichk
tab lcchk lichk

*** checking patterns of missing data for flagged cases
misstable patterns w1-w12 if qflg
misstable patterns w1-w12 if lflg

*** program to plot trajectories for diagnostics
capture program drop PlotD
program PlotD
  args dv tit gn
  preserve
  keep if `dv'
  local N = _N
  reshape long w, i(id) j(wave)
  forval i = 1/`N' {
    local plotline "`plotline' plot`i'( lp(solid) lc(gs10) ) "
  }
  xtline w, t(wave) i(id) overlay legend(off) scheme(s1mono) `plotline'    ///
    ylab(0(3)15, angle(h)) xlab(0(2)12) title("`tit'") ytit("weight (kg)") ///
	saving(`gn', replace)
end

PlotD qmchk "Quad NLALT - MD" g1
PlotD qcchk "Quad NLALT - Cook's D" g2
PlotD qichk "Quad NLALT - Influence" g3
PlotD qflg  "Quad NLALT - any" g4
graph combine g1.gph g2.gph g3.gph g4.gph, scheme(s1mono)

PlotD lmchk "LB NLALT - MD" g1
PlotD lcchk "LB NLALT - Cook's D" g2
PlotD lichk "LB NLALT - Influence" g3
PlotD lflg  "LB NLALT - any" g4
graph combine g1.gph g2.gph g3.gph g4.gph, scheme(s1mono)


