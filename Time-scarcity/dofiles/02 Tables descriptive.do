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

use "$organized\all_apps_wide.dta", clear

*---Tab 1 - Bias ------*
*----------------------*
mat M_bias1 = J(2,3,.)
mat M_bias2 = J(2,3,.)
mat M_bias3 = J(2,3,.)
mat M_bias_obs = J(1,3,.)

forval i=1(1)3{
	
	*All sample
	sum biased`i'
	local obs = r(N)
	mat M_bias_obs[1,1] = `obs'
	
	qui count if biased`i'==0
	mat M_bias`i'[1,1] = 100*r(N)/`obs'
	qui count if biased`i'==1
	mat M_bias`i'[2,1] = 100*r(N)/`obs'
	mat M_bias_obs[1,1] = `obs'

	*Treated
	sum biased`i' if treatment==1
	local obs = r(N)
	mat M_bias_obs[1,2] = `obs'
	
	qui count if biased`i'==0 & treatment==1
	mat M_bias`i'[1,2] = 100*r(N)/`obs'
	count if biased`i'==1 & treatment==1
	mat M_bias`i'[2,2] = 100*r(N)/`obs'
	
	*Control
	sum biased`i' if treatment==0
	local obs = r(N)
	mat M_bias_obs[1,3] = `obs'	
	
	qui count if biased`i'==0 & treatment==0
	mat M_bias`i'[1,3] = 100*r(N)/`obs'
	qui count if biased`i'==1 & treatment==0
	mat M_bias`i'[2,3] = 100*r(N)/`obs'
	
	
	estout matrix(M_bias`i', fmt(%9.2f)) using "$tables\descriptive\tab1_bias`i'.tex", ///
		style(tex) mlabels(none) label collabels(none) replace ///
		rename (r1 "bias = 0" r2 "bias = 1")
	
}

estout matrix(M_bias_obs, fmt(%9.0f)) using "$tables\descriptive\tab1_bias_obs.tex", ///
		style(tex) mlabels(none) label collabels(none) replace ///
		rename(r1 "Observations")
		
		
*---Tab 2 - Tasks------*
*----------------------*
mat M_tasks_all = J(2, 10, .)
mat M_tasks_treat = J(2, 10, .)
mat M_tasks_control = J(2, 10, .)

forval i=1(1)10{
	
	*All sample
	qui count if task`i'_correct!=.
	local obs = r(N)
	qui count if task`i'_correct==1
	local correct = r(N)
	
	mat M_tasks_all[1, `i'] = round(100*(`correct'/`obs'), 0.01)
	mat M_tasks_all[2, `i'] = `obs'	
	
	*Treated
	qui count if task`i'_correct!=. & treatment==1
	local obs = r(N)
	qui count if task`i'_correct==1 & treatment==1
	local correct = r(N)
	
	mat M_tasks_treat[1, `i'] = round(100*(`correct'/`obs'), 0.01)
	mat M_tasks_treat[2, `i'] = `obs'	
	
	*Control
	qui count if task`i'_correct!=. & treatment==0
	local obs = r(N)
	qui count if task`i'_correct==1 & treatment==0
	local correct = r(N)
	
	mat M_tasks_control[1, `i'] = round(100*(`correct'/`obs'), 0.01)
	mat M_tasks_control[2, `i'] = `obs'	

}

estout matrix(M_tasks_all) using "$tables\descriptive\tab2_tasks_all.tex", ///
	style(tex) mlabels(none) label collabels(none) replace ///
	rename(r1 "Correct \ (\%)" r2 "Observations")
estout matrix(M_tasks_treat) using "$tables\descriptive\tab2_tasks_treat.tex", ///
	style(tex) mlabels(none) label collabels(none) replace ///
	rename(r1 "Correct \ (\%)" r2 "Observations")
estout matrix(M_tasks_control) using "$tables\descriptive\tab2_tasks_control.tex", ///
	style(tex) mlabels(none) label collabels(none) replace ///
	rename(r1 "Correct \ (\%)" r2 "Observations")


*---Tab 3 - CRT-----*
*-------------------*
mat M_crt_all = J(2, 3, .)
mat M_crt_treat = J(2, 3, .)
mat M_crt_control = J(2, 3, .)

forval i=1(1)3{
	
	*All sample
	qui count if crt`i'_correct!=.
	local obs = r(N)
	qui count if crt`i'_correct==1
	local correct = r(N)
	qui count if crt`i'_correct==0
	local incorrect = r(N)
	
	mat M_crt_all[1, `i'] = round(100*(`correct'/`obs'), 0.01)
	mat M_crt_all[2, `i'] = round(100*(`incorrect'/`obs'), 0.01)
	
	*Treated
	qui count if crt`i'_correct!=. & treatment==1
	local obs = r(N)
	qui count if crt`i'_correct==1 & treatment==1
	local correct = r(N)
	qui count if crt`i'_correct==0 & treatment==1
	local incorrect = r(N)
	
	mat M_crt_treat[1, `i'] = round(100*(`correct'/`obs'), 0.01)
	mat M_crt_treat[2, `i'] = round(100*(`incorrect'/`obs'), 0.01)
	
	*Control
	qui count if crt`i'_correct!=. & treatment==0
	local obs = r(N)
	qui count if crt`i'_correct==1 & treatment==0
	local correct = r(N)
	qui count if crt`i'_correct==0 & treatment==0
	local incorrect = r(N)
	
	mat M_crt_control[1, `i'] = round(100*(`correct'/`obs'), 0.01)
	mat M_crt_control[2, `i'] = round(100*(`incorrect'/`obs'), 0.01)
	
}

estout matrix(M_crt_all, fmt(%9.2f)) using "$tables\descriptive\tab3_crt_all.tex", ///
	style(tex) mlabels(none) label collabels(none) replace ///
	rename(r1 "Correct" r2 "Incorrect") 
estout matrix(M_crt_treat, fmt(%9.2f)) using "$tables\descriptive\tab3_crt_treat.tex", ///
	style(tex) mlabels(none) label collabels(none) replace ///
	rename(r1 "Correct" r2 "Incorrect") 
estout matrix(M_crt_control, fmt(%9.2f)) using "$tables\descriptive\tab3_crt_control.tex", ///
	style(tex) mlabels(none) label collabels(none) replace ///
	rename(r1 "Correct" r2 "Incorrect") 


*---Tab 4 - flit-----*
*--------------------*
mat M_flit_all = J(2, 3, .)
mat M_flit_treat = J(2, 3, .)
mat M_flit_control = J(2, 3, .)


forval i=1(1)3{
	
	*All sample
	qui count if finlit`i'_correct!=.
	local obs = r(N)
	qui count if finlit`i'_correct==1
	local correct = r(N)
	qui count if finlit`i'_correct==0
	local incorrect = r(N)
	
	mat M_flit_all[1, `i'] = round(100*(`correct'/`obs'), 0.01)
	mat M_flit_all[2, `i'] = round(100*(`incorrect'/`obs'), 0.01)
	
	*Treated
	qui count if finlit`i'_correct!=. & treatment==1
	local obs = r(N)
	qui count if finlit`i'_correct==1 & treatment==1
	local correct = r(N)
	qui count if finlit`i'_correct==0 & treatment==1
	local incorrect = r(N)
	
	mat M_flit_treat[1, `i'] = round(100*(`correct'/`obs'), 0.01)
	mat M_flit_treat[2, `i'] = round(100*(`incorrect'/`obs'), 0.01)
	
	*Control
	qui count if finlit`i'_correct!=. & treatment==0
	local obs = r(N)
	qui count if finlit`i'_correct==1 & treatment==0
	local correct = r(N)
	qui count if finlit`i'_correct==0 & treatment==0
	local incorrect = r(N)
	
	mat M_flit_control[1, `i'] = round(100*(`correct'/`obs'), 0.01)
	mat M_flit_control[2, `i'] = round(100*(`incorrect'/`obs'), 0.01)
	
}

estout matrix(M_flit_all, fmt(%9.2f)) using "$tables\descriptive\tab4_flit_all.tex", ///
	style(tex) mlabels(none) label collabels(none) replace ///
	rename(r1 "Correct" r2 "Incorrect") 
estout matrix(M_flit_treat, fmt(%9.2f)) using "$tables\descriptive\tab4_flit_treat.tex", ///
	style(tex) mlabels(none) label collabels(none) replace ///
	rename(r1 "Correct" r2 "Incorrect") 
estout matrix(M_flit_control, fmt(%9.2f)) using "$tables\descriptive\tab4_flit_control.tex", ///
	style(tex) mlabels(none) label collabels(none) replace ///
	rename(r1 "Correct" r2 "Incorrect") 

	
********************************************************************************
********************************************************************************

*Merging with time spent at each page
use "$organized\all_apps_wide.dta", clear
merge 1:1 session_code participant_id_in_session participant_code using "$organized\times_sessions.dta" 
drop if _merge==2 //17 not matched (14 from session 1 lost; 3 from participants who were dropped)

*---Tab 5 - Avg time for tasks------*
*-----------------------------------*
mat t_tasks_all = J(2, 10, .)
mat t_tasks_treat = J(2, 10, .)
mat t_tasks_control = J(2, 10, .)

forval i=1(1)10{
	
	*All sample
	qui sum t_preg`i'
	local obs =r(N)
	local mean = round(r(mean), 0.01)
	
	mat t_tasks_all[1, `i'] = `mean'
	mat t_tasks_all[2, `i'] = `obs'
	
	*Treated 
	qui sum t_preg`i' if treatment==1
	local obs =r(N)
	local mean = round(r(mean), 0.01)
	
	mat t_tasks_treat[1, `i'] = `mean'
	mat t_tasks_treat[2, `i'] = `obs'
	
	*Control 
	qui sum t_preg`i' if treatment==0
	local obs =r(N)
	local mean = round(r(mean), 0.01)
	
	mat t_tasks_control[1, `i'] = `mean'
	mat t_tasks_control[2, `i'] = `obs'
	
}

estout matrix(t_tasks_all) using "$tables\descriptive\tab5_timetasks_all.tex", ///
	style(tex) mlabels(none) label collabels(none) replace ///
	rename(r1 "Seconds" r2 "Observations")
estout matrix(t_tasks_treat) using "$tables\descriptive\tab5_timetasks_treat.tex", ///
	style(tex) mlabels(none) label collabels(none) replace ///
	rename(r1 "Seconds" r2 "Observations")
estout matrix(t_tasks_control) using "$tables\descriptive\tab5_timetasks_control.tex", ///
	style(tex) mlabels(none) label collabels(none) replace ///
	rename(r1 "Seconds" r2 "Observations")


*---Tab 6 - Avg time for bond/stock------*
*----------------------------------------*
mat t_risk_all = J(2, 6, .)
mat t_risk_treat = J(2, 6, .)
mat t_risk_control = J(2, 6, .)

forval i=1(1)6{
	
	*All sample
	qui sum t_bono_vs_accion_`i'
	local obs = r(N)
	local mean = round(r(mean), 0.01)

	mat t_risk_all[1, `i'] = `mean'
	mat t_risk_all[2, `i'] = `obs'
	
	*Treated
	qui sum t_bono_vs_accion_`i' 
	local obs = r(N)
	local mean = round(r(mean), 0.01)

	mat t_risk_treat[1, `i'] = `mean'
	mat t_risk_treat[2, `i'] = `obs'	
	
	*Control
	qui sum t_bono_vs_accion_`i'
	local obs = r(N)
	local mean = round(r(mean), 0.01)

	mat t_risk_control[1, `i'] = `mean'
	mat t_risk_control[2, `i'] = `obs'	
	
}

estout matrix(t_risk_all) using "$tables\descriptive\tab6_timerisk_all.tex", ///
	style(tex) mlabels(none) label collabels(none) replace ///
	rename(r1 "Seconds" r2 "Observations")
estout matrix(t_risk_treat) using "$tables\descriptive\tab6_timerisk_treat.tex", ///
	style(tex) mlabels(none) label collabels(none) replace ///
	rename(r1 "Seconds" r2 "Observations")
estout matrix(t_risk_control) using "$tables\descriptive\tab6_timerisk_control.tex", ///
	style(tex) mlabels(none) label collabels(none) replace ///
	rename(r1 "Seconds" r2 "Observations")

	
*---Tab 7 - Avg time for CRT+FL------*
*------------------------------------*
mat t_crt_fl = J(2, 3, .)

*All sample
qui sum t_crt
local obs = r(N)
local mean = round(r(mean), 0.01)

mat t_crt_fl[1,1] = `mean' 
mat t_crt_fl[2,1] = `obs'

*Treated
qui sum t_crt if treatment==1
local obs = r(N)
local mean = round(r(mean), 0.01)

mat t_crt_fl[1,2] = `mean'
mat t_crt_fl[2,2] = `obs'

*Control
qui sum t_crt if treatment==0
local obs = r(N)
local mean = round(r(mean), 0.01)

mat t_crt_fl[1,3] = `mean'
mat t_crt_fl[2,3] = `obs'

estout matrix(t_crt_fl) using "$tables\descriptive\tab7_timecrtflit.tex", ///
	style(tex) mlabels(none) label collabels(none) replace ///
	rename(r1 "Seconds" r2 "Observations")













