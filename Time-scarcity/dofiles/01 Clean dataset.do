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


*---Import raw------*
*-------------------*
import delimited "$raw/Sesion 1 - all_apps_wide-2024-01-22 - 9am.csv", clear
g session=1
save "$raw/sesion 1", replace

import delimited "$raw/Sesion 2 - all_apps_wide_2024-01-22 10am", clear
g session=2
save "$raw/sesion 2", replace
 
import delimited "$raw/Sesion 3 - all_apps_wide-2024-01-22 - 4pm", clear
g session=3
save "$raw/sesion 3", replace

import delimited "$raw/Sesion 4 - all_apps_wide-2024-01-23 10am", clear
g session=4
save "$raw/sesion 4", replace

import delimited "$raw/Sesion 5 - all_apps_wide-2024-01-23", clear
g session=5
save "$raw/sesion 5", replace

import delimited "$raw/Sesion 6 - all_apps_wide-2024-01-24", clear
g session=6
save "$raw/sesion 6", replace

import delimited "$raw/Sesion 7 - all_apps_wide-2024-01-24", clear
g session=7
save "$raw/sesion 7", replace

import delimited "$raw/Sesion 8 - all_apps_wide-2024-01-24.csv", clear
g session=8
save "$raw/sesion 8", replace

import delimited "$raw/Sesion 9 - all_apps_wide-2024-01-25.csv", clear
g session=9
save "$raw/sesion 9", replace

import delimited "$raw/Sesion 10 - all_apps_wide-2024-01-26.csv", clear
g session=10
save "$raw/sesion 10", replace



use "$raw/sesion 1", clear
append using "$raw/sesion 2"
append using "$raw/sesion 3"
append using "$raw/sesion 4"
append using "$raw/sesion 5"
append using "$raw/sesion 6"
append using "$raw/sesion 7"
append using "$raw/sesion 8"
append using "$raw/sesion 9"
append using "$raw/sesion 10"

drop if participantlabel=="u6l4pyz" /* participant was removed at the start of the experiment */
drop if participantlabel=="cvtqch0"
drop if participantcode=="cetv1k88" /* in session 3, participant didn't complete any questions and wasn't assigned a participantlabel */

*--- (1) Defining variables------*
*--------------------------------*
g treatment=1 		if participant_current_app_name=="treat"
replace treatment=0 if participant_current_app_name=="control"

la de treatment 1 treated 0 control
la values treatment treatment

local i=1
while `i'<=6 {
	g		q`i' = control1playerbono_vs_accion_`i' if treatment==0
	replace	q`i' = treat1playerbono_vs_accion_`i' if treatment==1
	local i = `i' + 1
}

g		biased1=0
replace	biased1=1 if (q1==1 & q4==2) | (q2==2 & q6==1) | (q3==2 & q5==1)

g		biased2=0
replace	biased2=1 if (q1==1 & q4==2) & (q2==2 & q6==1)

g		biased3=0
replace	biased3=1 if (q1==1 & q4==2) & (q2==2 & q6==1) & (q3==2 & q5==1)

reg biased1 treatment i.session, r
reg biased2 treatment i.session, r
reg biased3 treatment i.session, r


* preguntas 1 a 10. correcto vs incorrecto

local i=1
while `i'<=10 {

	g		datatask`i'=control1playerpregunta`i' if treatment==0
	replace datatask`i'=treat1playerpregunta`i' if treatment==1
	
	local i = `i' + 1
}


g task1_correct=datatask1==123	 if datatask1!=.
g task2_correct=datatask2==2 	 if datatask2!=.
g task3_correct=datatask3==60 	 if datatask3!=.
g task4_correct=datatask4==2 	 if datatask4!=.
g task5_correct=datatask5==1200  if datatask5!=.
g task6_correct=datatask6==2 	 if datatask6!=.
g task7_correct=datatask7==1 	 if datatask7!=.
g task8_correct=datatask8==16109 if datatask8!=.
g task9_correct=datatask9==22 	 if datatask9!=.
g task10_correct=datatask10==4 	 if datatask10!=.

egen datatask_score = rsum(task*_correct)

* crt1 5
* crt2 47
* crt3 0.05

g		crt1 = control1playercrt1 if treatment==0
replace	crt1 = treat1playercrt1 if treatment==1

g		crt2 = control1playercrt2 if treatment==0
replace	crt2 = treat1playercrt2 if treatment==1

g		crt3 = control1playercrt3 if treatment==0
replace	crt3 = treat1playercrt3 if treatment==1

g		finanzas_prac = control1playercrt4 if treatment==0
replace	finanzas_prac = treat1playercrt4 if treatment==1

g crt1_correct = crt1==5
g crt2_correct = crt2==47
g crt3_correct = crt3>=.049 & crt3<=0.051


egen crt_score = rsum(crt1_correct crt2_correct crt3_correct)

reg crt_score treatment, r

* pract fin 1 si 2 no.

g		finlit1 = control1playerflit1 if treatment==0
replace	finlit1 = treat1playerflit1 if treatment==1

g		finlit2 = control1playerflit2 if treatment==0
replace	finlit2 = treat1playerflit2 if treatment==1

g		finlit3 = control1playerflit3 if treatment==0
replace	finlit3 = treat1playerflit3 if treatment==1

g finlit1_correct = finlit1==1
g finlit2_correct = finlit2==3
g finlit3_correct = finlit3==2

g finlit_score = finlit1_correct + finlit2_correct + finlit3_correct


reg biased1 treatment i.session if finlit_score>=2, r


* preguntas crt1-crt4 correcto vs incorrecto
* preguntas finlit1-3 correcto vs incorrecto
* preguntas bl1-bl3 ver qué son

g		bl1 = control1playerbl1 if treatment==0
replace bl1 = treat1playerbl1 if treatment==1

g		bl2 = control1playerbl2 if treatment==0
replace bl2 = treat1playerbl2 if treatment==1


g		bl3 = control1playerbl3 if treatment==0
replace bl3 = treat1playerbl3 if treatment==1


g bl1_biased = bl1==2
g bl2_biased = bl2==1
g bl3_biased = bl3==1

egen blbias=rsum(bl1_biased bl2_biased bl3_biased)

* Dummy=1 when blbias > median 
egen med_blbias = xtile(blbias), nq(2)
replace med_blbias=0 if med_blbias==1
replace med_blbias=1 if med_blbias==2

*Export
rename sessioncode session_code                                    //Match names for merges with times_sessions.dta
rename participantid_in_session participant_id_in_session
rename participantcode participant_code
save "$organized\all_apps_wide.dta", replace

*--- (2) Time elapsed------*
*--------------------------*
forval i = 2(1)10{
	import delimited "$raw\PageTimes\sesion`i'_pagetimes.csv", clear
	do "$dofiles\gen_times.txt"
	save "$temporal\times_session`i'.dta", replace
}

use "$temporal\times_session2.dta", replace
forval i = 3(1)10{
	append using "$temporal\times_session`i'.dta"
}
save "$organized\times_sessions.dta", replace


/*
t: original time measurment (in seconds)
min: time in minutes (truncated)
sec: seconds after "min" (values in [0,59])
mmss: minutes:seconds format 
*/

*---(3) Reshapes long------*
*--------------------------*

*a) Bond/Stock questions
use "$organized\all_apps_wide.dta", clear
gen id_obs = _n
*keep id_obs q*
reshape long q, i(id_obs) j(num_question)

replace q=0 if q==1 //bond
replace q=1 if q==2 //stock
label variable q "0 safe asset, 1 risky asset"

*LDB=1 if question j has a left digit change (quesitons 2,3,4)
gen ldb = 0
replace ldb = 1 if (num_question==2 | num_question==3 | num_question==4)

order id_obs treatment q* ldb
save "$organized\bondstock_long.dta", replace


*b) Datatask questions
use "$organized\all_apps_wide.dta", clear
gen id_obs=_n
order id_obs treatment datatask*

reshape long datatask, i(id_obs) j(num_question)
save "$organized\datatask_long.dta", replace


*c) CRT questions
use "$organized\all_apps_wide.dta", clear
gen id_obs=_n
reshape long crt, i(id_obs) j(num_question)

cap drop crt?_correct
g crt_correct = 0
replace crt_correct = 1 if (num_question==1 & crt==5)
replace crt_correct = 1 if (num_question==2 & crt==47)
replace crt_correct = 1 if (num_question==3 & crt>=.049 & crt<=0.051)

order id_obs treatment num_question crt*
save "$organized\crt_long.dta", replace





exit



