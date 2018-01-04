# nlalt
This repository contains replication code for an empirical example involving trajectories of weight gain among infant girls. The example uses data from the Cebu Longitudinal Health and Nutrition Survey (CLHNS). Information about obtaining CLHNS data can be found at http://www.cpc.unc.edu/projects/cebu.

## Files
1. nlalt-data.do: Stata do file that prepares the CLHNS data for analysis.
2. nlalt-desc.do: Stata do file that prepares basic descriptive statistics.
3. nlalt-diag.do: Stata do file that reads and assesses diagnostic data from the NLALT models fit in Mplus.
4. nlalt-sim.do:  Stata do file that prepares data for simulation study and analyzes results of simulation.
5. nlalt-1-qlc.inp: Mplus input file for the modified quadratic latent curve model.
6. nlalt-1b-qlc.inp: Mplus input file for the respecified modified quadratic latent curve model.
7. nlalt-2-lb.inp: Mplus input file for the modified latent basis model.
8. nlalt-2b-lb.inp: Mplus input file for the respecified modified latent basis model.
9. nlalt-3-ar.inp: Mplus input file for the autoregressive model.
10. nlalt-4-lalt.inp: Mplus input file for the linear ALT model.
11. nlalt-4b-lalt.inp: Mplus input file for the respecified linear ALT model.
12. nlalt-5-qalt.inp: Mplus input file for the quadratic NLALT model.
13. nlalt-5-qalt-diag.inp: Mplus input file for the quadratic NLALT model with diagnostics.
14. nlalt-5b-qalt-diag.inp: Mplus input file for the respecified quadratic NLALT model.
15. nlalt-6-lbalt.inp: Mplus input file for the latent basis NLALT model.
16. nlalt-6-lbalt-diag.inp: Mplus input file for the latent basis NLALT model with diagnostics.
17. nlalt-6b-lbalt-diag.inp: Mplus input file for the respecified latent basis NLALT model.
18. nlalt-7-cqalt.inp: Mplus input file for the conditional respecified quadratic NLALT model.
19. nlalt-id.mw: Maple worksheet with algebraic solutions for identification of NLALT models.
20. nlalt-sim-alt-file.txt: terminal sh that creates Mplus input programs for alt model.
21. nlalt-sim-ar-file.txt: terminal sh that creates Mplus input programs for ar model.
22. nlalt-sim-qalt-file.txt: terminal sh that creates Mplus input programs for qalt model.
23. nlalt-sim-qgc-file.txt: terminal sh that creates Mplus input programs for qgc model.
24. nlalt-mplus-batch.bat: windows batch file for submitting Mplus programs for simulation.
