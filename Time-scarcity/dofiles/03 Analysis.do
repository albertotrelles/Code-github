clear all
global version = "alberto"

if "$version" == "alberto"{
	global dir "C:\Users\ALBERTO TRELLES\Documents\Alberto\RA\Code-github\Time-scarcity"
	global data "$dir\data"
	global raw "$data\raw"
	global organized "$data\organized"
	global temporal "$data\temporal"
	global tables "$dir\Tables"
	global dofiles "$dir\dofiles"
	cd "$dir"
}

*----------------------------*
*---H1: Left-digit bias------*
*----------------------------*
use "$organized\all_apps_wide.dta", clear

*Treatment effect on bias
local j=1
foreach y in biased1 biased2 biased3{
	sum `y' if treatment==0
	local mean=r(mean)
	display "`mean'"
	
	reg `y' treatment, r
	eststo a`j'
	estadd scalar obs=e(N)
	estadd scalar pval=r(table)[4,1]
	estadd scalar meanc=`mean'
	
	reg `y' treatment i.session, r	
	eststo b`j'
	estadd scalar obs=e(N)
	estadd scalar pval=r(table)[4,1]
	estadd scalar meanc=`mean'
	
	reg `y' treatment i.session i.blbias i.finlit_score, r
	eststo c`j'
	estadd scalar obs=e(N)
	estadd scalar pval=r(table)[4,1]
	estadd scalar meanc=`mean'
	
	local j=`j'+1

} 

estout a1 b1 c1 using "$tables/reg_biased1.tex",  ///
	style(tex) cells(b(star fmt(%9.3f)) se(par)) mlabels(none) label collabels(none) ///
	stats(meanc pval obs, fmt(%9.3fc %9.3fc %9.0fc) labels("Control group: mean" "p-value" "Observations")) prefoot("\\") ///
	keep(treatment) starlevels(* 0.10 ** 0.05 *** 0.01) replace 
	
estout a2 b2 c2 using "$tables/reg_biased2.tex",  ///
	style(tex) cells(b(star fmt(%9.3f)) se(par)) mlabels(none) label collabels(none) ///
	stats(meanc pval obs, fmt(%9.3fc %9.3fc %9.0fc) labels("Control group: mean" "p-value" "Observations")) prefoot("\\") ///
	keep(treatment) starlevels(* 0.10 ** 0.05 *** 0.01) replace 

estout a3 b3 c3 using "$tables/reg_biased3.tex",  ///
	style(tex) cells(b(star fmt(%9.3f)) se(par)) mlabels(none) label collabels(none) ///
	stats(meanc pval obs, fmt(%9.3fc %9.3fc %9.0fc) labels("Control group: mean" "p-value" "Observations")) prefoot("\\") ///
	keep(treatment) starlevels(* 0.10 ** 0.05 *** 0.01) replace 


*Treatment effect on risk preferences 
use "$organized/bondstock_long.dta", clear
gen ldb_treat = ldb*treatment

sum q if treatment==0 			//q=1 risky asset, q=0 safe asset
local mean=r(mean)

reg q treatment i.num_question, cluster(id_obs)
eststo e1 
estadd scalar obs=e(N)
estadd scalar pval=r(table)[4,1]
estadd scalar meanc=`mean'

reg q treatment ldb_treat i.num_question, cluster(id_obs)
eststo e2
estadd scalar obs=e(N)
estadd scalar pval=r(table)[4,1]
estadd scalar pval_int=r(table)[4,2]
estadd scalar meanc=`mean'

estout e1 e2 using "$tables\reg_ldb.tex", ///
	style(tex) cells(b(star fmt(%9.3f)) se(par)) mlabels(none) label collabels(none) ///
	stats(meanc pval pval_int obs, fmt(%9.3fc %9.3fc %9.3fc %9.0fc) labels("Control group: mean" "p-value" "p-value (interaction)" "Observations")) prefoot("\\") ///
	drop(?.num_question _cons) rename(ldb_treat "treatment \times \text{ LDB}") starlevels(* 0.10 ** 0.05 *** 0.01) replace 

	
*------------------------------*
*---H2: Use of heuristics------*
*------------------------------*
use "$organized/crt_long.dta", clear

*Treatment effect on CRT test 
sum crt_correct if treatment==0
local mean=r(mean)

reg crt_correct treatment i.num_question, r cluster(id_obs) 
eststo e1 
estadd scalar obs=e(N)
estadd scalar pval=r(table)[4,1]
estadd scalar meanc = `mean'

estout e1 using "$tables\reg_crt.tex", ///
	style(tex) cells(b(star fmt(%9.3f)) se(par)) mlabels(none) label collabels(none) ///
	stats(meanc pval obs, fmt(%9.3fc %9.3fc %9.0fc) labels("Control group: mean" "p-value" "Observations")) prefoot("\\") ///
	keep(treatment) starlevels(* 0.10 ** 0.05 *** 0.01) replace 

	
*----------------------------*
*---H3: Task Efficiency------*
*----------------------------*
use "$organized\datatask_long.dta", clear

*--(a) Correct anwsers total
*---------------------------
sum datatask_score if treatment==0
local mean=r(mean)

reg datatask_score treatment i.num_question, r cluster(id_obs)
eststo e1
estadd scalar obs=e(N)
estadd scalar pval=r(table)[4,1]
estadd scalar meanc=`mean'

estout e1 using "$tables\reg_tasks1.tex", ///
	style(tex) cells(b(star fmt(%9.3f)) se(par)) mlabels(none) label collabels(none) ///
	stats(meanc pval obs, fmt(%9.3fc %9.3fc %9.0fc) labels("Control group: mean" "p-value" "Observations")) prefoot("\\") ///
	keep(treatment) starlevels(* 0.10 ** 0.05 *** 0.01) replace 

*--(b) Correct answers per minute
*--------------------------------
merge m:1 session_code participant_id_in_session participant_code using "$organized\times_sessions.dta" //142 not matched
drop _merge

/*
140 not matched from master (no times database for session1)
participant with code "4m1vosjq" was removed at the start of the experiment (_merge==2); someone else was also not matched (see later)
*/

egen t_alltasks = rsum(t_preg1-t_preg10)
gen tasks_per_min = 60*(datatask_score/t_alltasks) //multiply by 60 the number of correct tasks per second

sum tasks_per_min if treatment==0
local mean=r(mean)

reg tasks_per_min treatment i.num_question, r cluster(id_obs)
eststo e1 
estadd scalar obs=e(N)
estadd scalar pval=r(table)[4,1]
estadd scalar meanc=`mean'

estout e1 using "$tables\reg_tasks2.tex", ///
	style(tex) cells(b(star fmt(%9.3f)) se(par)) mlabels(none) label collabels(none) ///
	stats(meanc pval obs, fmt(%9.3fc %9.3fc %9.0fc) labels("Control group: mean" "p-value" "Observations")) prefoot("\\") ///
	keep(treatment) starlevels(* 0.10 ** 0.05 *** 0.01) replace 


*---------------------------------------*
*---H4: Sharpe ratio & risk choice------*
*---------------------------------------*
use "$organized\bondstock_long.dta", clear

*--Sharpe Ratios
*---------------
#d ;
global sr_q1 = 
	( (5.2*0.5 + 5.9*0.5) - 5.5 )  /  
	sqrt( (5.2^2*0.5 + 5.9^2*0.5) - (5.2*0.5 + 5.9*0.5)^2 ) ;
#d cr

#d ;
global sr_q2 = 
	( (5.0*0.3 + 4.2*0.7) - 4.4 )  /  
	sqrt( (5.0^2*0.3 + 4.2^2*0.7) - (5.0*0.3 + 4.2*0.7)^2 ) ;
#d cr

#d ;
global sr_q3 = 
	( (4.2*0.4 + 5.0*0.6) - 4.7 )  /  
	sqrt( (4.2^2*0.4 + 5.0^2*0.6) - (4.2*0.4 + 5.0*0.6)^2 ) ;
#d cr

#d ;
global sr_q4 = 
	( (5.3*0.5 + 6.0*0.5) - 5.6 )  /  
	sqrt( (5.3^2*0.5 + 6.0^2*0.5) - (5.3*0.5 + 6.0*0.5)^2 ) ;
#d cr

#d ;
global sr_q5 = 
	( (4.1*0.4 + 4.9*0.6) - 4.6 )  /  
	sqrt( (4.1^2*0.4 + 4.9^2*0.6) - (4.1*0.4 + 4.9*0.6)^2 ) ;
#d cr

#d ;
global sr_q6 = 
	( (4.9*0.3 + 4.1*0.7) - 4.3 )  /  
	sqrt( (4.9^2*0.3 + 4.1^2*0.7) - (4.9*0.3 + 4.1*0.7)^2 ) ;
#d cr

gen sharpe=0
forval i = 1(1)6{
	replace sharpe=${sr_q`i'} if num_question==`i'
}

*-- H4 (a)
*---------
gen sharpe_ldb = sharpe*ldb
label variable sharpe_ldb "sharpe \times \text{ LDB}"

sum q if treatment==0
local mean=r(mean)

reg q sharpe ldb sharpe_ldb, r cluster(id_obs) allbaselevels                      //b3 positive (contrary to hypothesis) without questions FE 
eststo e1 
estadd scalar obs=e(N)
estadd scalar pval=r(table)[4,1]
estadd scalar meanc=`mean'

reg q sharpe ldb sharpe_ldb i.num_question, r cluster(id_obs) allbaselevels       //I guess controlling for question FE takes away the effect from sharpe since every pair of questions share the same sharpe ratio 
eststo e2 
estadd scalar obs=e(N)
estadd scalar pval=r(table)[4,1]
estadd scalar meanc=`mean'

estout e1 using "$tables\reg_sharpe1.tex", ///
	style(tex) cells(b(star fmt(%9.3f)) se(par)) mlabels(none) label collabels(none) /// 
	stats(meanc pval obs, fmt(%9.3fc %9.3fc %9.0fc) labels("Control group: mean" "p-value" "Observations")) prefoot("\\") ///
	keep(sharpe ldb sharpe_ldb) starlevels(* 0.10 ** 0.05 *** 0.01) replace

*-- H4 (b)
*---------
gen sharpe_treatment = sharpe*treatment
gen sharpe_ldb_t = sharpe*ldb*treatment
label variable sharpe_treatment "sharpe \times \text{ treatment}"
label variable sharpe_ldb_t "sharpe \times \text{ treatment} \times \text{ ldb}"

sum q if treatment==0
local mean=r(mean)

reg q sharpe ldb sharpe_ldb treatment sharpe_treatment sharpe_ldb_t, cluster(id_obs) allbaselevels //b6 negative (same as hypothesis) remains the same independent of questions FE
eststo e1 
estadd scalar obs=e(N)
estadd scalar pval=r(table)[4,1]
estadd scalar meanc=`mean'

reg q sharpe ldb sharpe_ldb treatment sharpe_treatment sharpe_ldb_t i.num_question, cluster(id_obs) allbaselevels
eststo e2
estadd scalar obs=e(N)
estadd scalar pval=r(table)[4,1]
estadd scalar meanc=`mean'

estout e1 using "$tables\reg_sharpe2.tex", ///
	style(tex) cells(b(star fmt(%9.3f)) se(par)) mlabels(none) label collabels(none) ///
	stats(meanc pval obs, fmt(%9.3fc %9.3fc %9.0fc) labels("Control group: mean" "p-value" "Observations")) prefoot("\\") ///
	keep(sharpe ldb sharpe_ldb treatment sharpe_treatment sharpe_ldb_t) starlevels(* 0.10 ** 0.05 *** 0.01) replace 



stop 





/*
reg biased1 treatment if session<=7, r

reg biased1 treatment if session<=10, r
reg biased1 treatment i.blbias i.finlit_score if session<=10, r
reg biased1 treatment i.blbias i.finlit_score i.session if session<=10, r

reghdfe biased1 treatment i.blbias i.finlit_score if session<=10, absorb(session blbias finlist_score) vce(robust)
reghdfe biased1 treatment if session<=10, absorb(session blbias finlit_score) vce(robust)


reg biased1 treatment i.session, r	
reg biased1 treatment i.session i.blbias finlit_score, r

	
reg `y' treatment##blbias i.session finlit_score, r



ritest treatment _b[treatment], cluster(classid) strata(schoolid): regress testscore treatment age


ritest treatment _b[treatment], reps(1000) seed(123): reg biased1 treatment i.blbias i.finlit_score if session<=10, vce(robust)
matrix pvalue = r(p)
global ri_pvalue = pvalue[1,1]
display "$ri_pvalue"

ritest treatment _b[treatment], reps(1000) seed(123): reghdfe biased1 treatment if session<=10, absorb(session blbias finlit_score) vce(robust)
matrix pvalue = r(p)
global ri_pvalue = pvalue[1,1]
display "$ri_pvalue"

egen fe_test = group(session blbias finlit_score)

ritest treatment _b[treatment], reps(10000) strata(fe_test) seed(123): reg biased1 treatment if session<=10, vce(robust)
matrix pvalue = r(p)
global ri_pvalue = pvalue[1,1]
display "$ri_pvalue"

*-------------*
*---- ITT ----*
*-------------*
local i = 1
foreach y of global var {
*Mean: Control group
sum `y' if above_tot == 0 
local meanc = r(mean)

*RI p-value
ritest above_tot _b[above_tot], reps(1000) strata(fe_tot) seed(125): ///
reghdfe `y' above_tot, absorb(fe_tot) vce(robust)
matrix pvalue = r(p)
local ri_pvalue = pvalue[1,1]

reghdfe `y' above_tot, absorb(fe_tot) vce(robust)
ereturn display
matrix table = r(table)
local n =e(N)

estadd scalar meanc = `meanc'
estadd scalar obs = `n'
estadd scalar ri = `ri_pvalue'

estimates store ea`i'

local i = `i' + 1
}
*/














