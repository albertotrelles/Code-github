clear all

global dir "C:/Users/ALBERTO TRELLES/Documents/Alberto/RA/Code-github/SVA"
global data "C:/Users/ALBERTO TRELLES/Dropbox/COAR Superior/Data"
global temporal "$dir/temporal"
global output "$dir/output"
global graphs "$dir/graphs"
cd "$dir"

#delimit ;
global enrollment "matricula matricula_priv matricula_pub 
                   matricula_top10 mat_priv_top10 mat_pub_top10";
#delimit cr	

#delimit ;
global application "post_priv post_pub postu_priv_top10 postu_pub_top10 postu_priv_ord 
                    postu_priv_extraord postu_priv_acad postu_pub_ord postu_pub_extraord 
					postu_pub_acad postu_priv_top10_ord postu_priv_top10_ext postu_priv_top10_acad
					postu_pub_top10_ord postu_pub_top10_ext postu_pub_top10_acad";
#delimit cr	

#delimit ;
global admission "admi_priv admi_pub admi_priv_top10 admi_pub_top10 adm_priv_ord
                  adm_priv_extraord adm_priv_acad adm_pub_ord adm_pub_extraord 
				  adm_pub_acad admi_priv_top10_ord admi_priv_top10_ext admi_priv_top10_acad 
				  admi_pub_top10_ord  admi_pub_top10_ext admi_pub_top10_acad";
#delimit cr

global outcomes "$enrollment $application $admission"

global wc=wordcount("$outcomes")
set maxvar 15000

global test_scores "mate_2s_std cl_2s_std mate_2s_std_sq cl_2s_std_sq mate_2s_std_cu cl_2s_std_cu missing_mate missing_liter"
global test_scores_primary "mate_2p_std cl_2p_std mate_2p_std_sq cl_2p_std_sq missing_mate_2p_std missing_cl_2p_std"
global ise "ise ise_sq ise_cu missing_ise"
global individual "hombre preschool missing_var11 var10_1 var10_2 var10_3 var10_4 missing_var10 repeated missing_var12"
global father_education "var1_1 var1_2 var1_3 var1_4 var1_5 var1_6 var1_7 var1_8 var1_9 var1_10 missing_var1"
global mother_education "var2_1 var2_2 var2_3 var2_4 var2_5 var2_6 var2_7 var2_8 var2_9 var2_10 missing_var2"
#d ;
global house "var3_1 var3_2 var3_3 var3_4 var3_5 var3_6 var3_7 var3_8 missing_var3 
			  var4_1 var4_2 var4_3 var4_4 var4_5 var4_6 var4_7 var4_8 missing_var4 
			  var5_1 var5_2 var5_3 var5_4 var5_5 var5_6 var5_7 missing_var5 
			  var6_1 var6_2 var6_3 var6_4 var6_5 var6_6 var6_7 missing_var6
			  var7_1 var7_2 var7_3 var7_4 var7_5 var7_6 var7_7 missing_var7
			  var8_1 var8_2 var8_3 var8_4 var8_5 missing_var8";

global assets "var9_1 missing_var9_1 var9_2 missing_var9_2 var9_3 missing_var9_3 
			   var9_4 missing_var9_4 var9_5 missing_var9_5 var9_6 missing_var9_6 
			   var9_7 missing_var9_7 var9_8 missing_var9_8 var9_9 missing_var9_9 
			   var9_10 missing_var9_10 var9_11 missing_var9_11 var9_12 missing_var9_12 
			   var9_13 missing_var9_13 var9_14 missing_var9_14 var9_15 missing_var9_15 
			   var9_16 missing_var9_16 var9_17 missing_var9_17 var9_18 missing_var9_18";			  			  
#d cr

global siagie3 "gpa_3yrlead miss_gpa_3yrlead math_num_3yrlead miss_math_num_3yrlead lang_num_3yrlead miss_lang_num_3yrlead"



/*
Heterogeneity by:
1. Gender (hombre)
2. ECE scores 2nd-grade primary (nq3_math_2p, nq3_cl_2p)
3. ECE socio-economic index (nq3_ise)

Resid:
h_va_1_`y'
m2p_va_1_`y'
cl2p_va_1_`y'
ise_va_1_`y'
*/

*------------------------*
*--- Het by Gender ------*
*------------------------*
use "$data/va_data.dta", clear
xtile nq3_math_2p = mate_2p_std, nq(3)
xtile nq3_cl_2p = cl_2p_std, nq(3)
xtile nq3_ise = ise, nq(3)

foreach y of global outcomes{
	display as red "`y' model general"
	reghdfe `y' $test_scores $ise $test_scores_primary $individual $father_education $mother_education $house $assets $siagie3 if hombre==1, absorb(h_va_1_`y'=schoolid coar_fe year) vce(robust) resid
	reghdfe `y' $test_scores $ise $test_scores_primary $individual $father_education $mother_education $house $assets $siagie3 if hombre==0, absorb(m_va_1_`y'=schoolid coar_fe year) vce(robust) resid
}

cap drop students
gen students=1
save "$temporal/gender_value_added_students.dta", replace

use "$temporal/gender_value_added_students.dta", clear
keep schoolid h_va_1_* m_va_1_* students
collapse (sum) students (mean) h_va_1_* m_va_1_*, by(schoolid)

save "$temporal/gender_value_added_schools.dta", replace


*-------------------------*
*--- Het by Math 2p ------*
*-------------------------*
use "$data/va_data.dta", clear
xtile nq3_math_2p = mate_2p_std, nq(3)
xtile nq3_cl_2p = cl_2p_std, nq(3)
xtile nq3_ise = ise, nq(3)

foreach y of global outcomes{
	display as red "`y' model general"
	reghdfe `y' $test_scores $ise $test_scores_primary $individual $father_education $mother_education $house $assets $siagie3 if nq3_math_2p==1, absorb(m2p1_va_1_`y'=schoolid coar_fe year) vce(robust) resid
	reghdfe `y' $test_scores $ise $test_scores_primary $individual $father_education $mother_education $house $assets $siagie3 if nq3_math_2p==2, absorb(m2p2_va_1_`y'=schoolid coar_fe year) vce(robust) resid
	reghdfe `y' $test_scores $ise $test_scores_primary $individual $father_education $mother_education $house $assets $siagie3 if nq3_math_2p==3, absorb(m2p3_va_1_`y'=schoolid coar_fe year) vce(robust) resid
}

cap drop students
gen students=1
save "$temporal/math_value_added_students.dta", replace

use "$temporal/math_value_added_students.dta", clear
keep schoolid m2p?_va_1_* students
collapse (sum) students (mean) m2p?_va_1_*, by(schoolid)

save "$temporal/math_value_added_schools.dta", replace


*----------------------------*
*--- Het by Reading 2p ------*
*----------------------------*
use "$data/va_data.dta", clear
xtile nq3_math_2p = mate_2p_std, nq(3)
xtile nq3_cl_2p = cl_2p_std, nq(3)
xtile nq3_ise = ise, nq(3)

foreach y of global outcomes{
	display as red "`y' model general"
	reghdfe `y' $test_scores $ise $test_scores_primary $individual $father_education $mother_education $house $assets $siagie3 if nq3_cl_2p==1, absorb(cl2p1_va_1_`y'=schoolid coar_fe year) vce(robust) resid
	reghdfe `y' $test_scores $ise $test_scores_primary $individual $father_education $mother_education $house $assets $siagie3 if nq3_cl_2p==2, absorb(cl2p2_va_1_`y'=schoolid coar_fe year) vce(robust) resid
	reghdfe `y' $test_scores $ise $test_scores_primary $individual $father_education $mother_education $house $assets $siagie3 if nq3_cl_2p==3, absorb(cl2p3_va_1_`y'=schoolid coar_fe year) vce(robust) resid
}

cap drop students
gen students=1
save "$temporal/reading_value_added_students.dta", replace

use "$temporal/reading_value_added_students.dta", clear
keep schoolid cl2p?_va_1_* students
collapse (sum) students (mean) cl2p?_va_1_*, by(schoolid)

save "$temporal/reading_value_added_schools.dta", replace


*--------------------------------------*
*--- Het by Socio-economic index ------*
*--------------------------------------*
use "$data/va_data.dta", clear
xtile nq3_math_2p = mate_2p_std, nq(3)
xtile nq3_cl_2p = cl_2p_std, nq(3)
xtile nq3_ise = ise, nq(3)

foreach y of global outcomes{
	display as red "`y' model general"
	reghdfe `y' $test_scores $ise $test_scores_primary $individual $father_education $mother_education $house $assets $siagie3 if nq3_ise==1, absorb(ise1_va_1_`y'=schoolid coar_fe year) vce(robust) resid
	reghdfe `y' $test_scores $ise $test_scores_primary $individual $father_education $mother_education $house $assets $siagie3 if nq3_ise==2, absorb(ise2_va_1_`y'=schoolid coar_fe year) vce(robust) resid
	reghdfe `y' $test_scores $ise $test_scores_primary $individual $father_education $mother_education $house $assets $siagie3 if nq3_ise==3, absorb(ise3_va_1_`y'=schoolid coar_fe year) vce(robust) resid
}

cap drop students
gen students=1
save "$temporal/ise_value_added_students.dta", replace

use "$temporal/ise_value_added_students.dta", clear
keep schoolid ise?_va_1_* students
collapse (sum) students (mean) ise?_va_1_*, by(schoolid)

save "$temporal/ise_value_added_schools.dta", replace

*-------------------*
*--- Analysis ------*
*-------------------*

*Merge
use "$temporal/gender_value_added_schools.dta", clear
merge 1:1 schoolid using "$temporal/math_value_added_schools.dta"
drop _merge
merge 1:1 schoolid using "$temporal/reading_value_added_schools.dta"
drop _merge
merge 1:1 schoolid using "$temporal/ise_value_added_schools.dta"
drop _merge
save "$output/het_value_added_schools.dta", replace


*--- (1) Gender heterogeneity ---*
*--------------------------------*
use "$output/het_value_added_schools", clear
est clear

foreach y of global outcomes{

reg h_va_1_`y' m_va_1_`y' [aw=students]
global coef = string(round(r(table)[1,1], .001))
global se = string(round(r(table)[2,1], .001))
global lb = string(round(r(table)[5,1], .001))
global ub = string(round(r(table)[6,1], .001))
lincom m_va_1_`y' - 1
global ptest = string(round(r(p), 0.001))	
	
#delimit ;
graph twoway 
	( 
		scatter h_va_1_`y' m_va_1_`y' [aw=students], 
		title("SVA `y'") msize(tiny) legend(off) 
		xtitle("Female SVA") ytitle("Male SVA") xlabel(-1(.25)1) ylabel(-1(.25)1)  
		text(1 -0.9 "${coef} (${se})", color(red)) 
		text(0.85 -0.9 "[${lb}, ${ub}]", color(blue))                       
		text(0.7 -0.9 "Ho: b=1 (${ptest})") 
	)
	(	lfit h_va_1_`y' m_va_1_`y' [aw=students], lcolor(red)		)
	(	lfit h_va_1_`y' h_va_1_`y', lcolor(black) lpattern(dash)	)
	;
#delimit cr

graph export "$graphs/gender/het_gender_`y'.png", replace width(1280) height(720)

}


*--- (2) Math and reading heterogeneity---*
*-----------------------------------------*
clear all
use "$output/het_value_added_schools", clear
est clear

*local y matricula

foreach y of global outcomes{
*I.
*MATH: 3rd vs. 1st           
reg m2p3_va_1_`y' m2p1_va_1_`y' 
global coef = string(round(r(table)[1,1], .001))
global se = string(round(r(table)[2,1], .001))
global lb = string(round(r(table)[5,1], .001))
global ub = string(round(r(table)[6,1], .001))
lincom m2p1_va_1_`y' - 1
global ptest = string(round(r(p), 0.001))

#delimit ;
graph twoway
	( 
		scatter m2p3_va_1_`y' m2p1_va_1_`y' [aw=students], 
		title("Top vs. bottom third") msize(tiny) legend(off) 
		xtitle("Math (2p) 1st tercile") ytitle("Math (2p) 3rd tercile") xlabel(-1(.25)1) ylabel(-1(.25)1)  
		text(1 -0.70 "${coef} (${se})", color(red)) 
		text(0.75 -0.70 "[${lb}, ${ub}]", color(blue))                       
		text(0.5 -0.70 "Ho: b=1 (${ptest})") 
	)
	(	lfit m2p3_va_1_`y' m2p1_va_1_`y' [aw=students], lcolor(red)		)
	(	lfit m2p3_va_1_`y' m2p3_va_1_`y', lcolor(black) lpattern(dash) name(m2p3v1_`y'))
	;
#delimit cr

*READING: 3rd vs. 1st           
reg cl2p3_va_1_`y' cl2p1_va_1_`y' [aw=students]
global coef = string(round(r(table)[1,1], .001))
global se = string(round(r(table)[2,1], .001))
global lb = string(round(r(table)[5,1], .001))
global ub = string(round(r(table)[6,1], .001))
lincom cl2p1_va_1_`y' - 1
global ptest = string(round(r(p), 0.001))

#delimit ;
graph twoway
	( 
		scatter cl2p3_va_1_`y' cl2p1_va_1_`y' [aw=students], 
		title("Top vs. bottom third") msize(tiny) legend(off) 
		xtitle("Reading (2p) 1st tercile") ytitle("Reading (2p) 3rd tercile") xlabel(-1(.25)1) ylabel(-1(.25)1)  
		text(1 -0.70 "${coef} (${se})", color(red)) 
		text(0.75 -0.70 "[${lb}, ${ub}]", color(blue))                       
		text(0.5 -0.70 "Ho: b=1 (${ptest})") 
	)
	(	lfit cl2p3_va_1_`y' cl2p1_va_1_`y' [aw=students], lcolor(red)		)
	(	lfit cl2p3_va_1_`y' cl2p3_va_1_`y', lcolor(black) lpattern(dash) name(cl2p3v1_`y'))
	;
#delimit cr

*II.
*MATH: 3rd vs. 2nd           
reg m2p3_va_1_`y' m2p2_va_1_`y' 
global coef = string(round(r(table)[1,1], .001))
global se = string(round(r(table)[2,1], .001))
global lb = string(round(r(table)[5,1], .001))
global ub = string(round(r(table)[6,1], .001))
lincom m2p2_va_1_`y' - 1
global ptest = string(round(r(p), 0.001))

#delimit ;
graph twoway
	( 
		scatter m2p3_va_1_`y' m2p2_va_1_`y' [aw=students], 
		title("Top vs. middle third") msize(tiny) legend(off) 
		xtitle("Math (2p) 2nd tercile") ytitle("Math (2p) 3rd tercile") xlabel(-1(.25)1) ylabel(-1(.25)1)  
		text(1 -0.70 "${coef} (${se})", color(red)) 
		text(0.75 -0.70 "[${lb}, ${ub}]", color(blue))                       
		text(0.5 -0.70 "Ho: b=1 (${ptest})")  
	)
	(	lfit m2p3_va_1_`y' m2p2_va_1_`y' [aw=students], lcolor(red)		)
	(	lfit m2p3_va_1_`y' m2p3_va_1_`y', lcolor(black) lpattern(dash) name(m2p3v2_`y'))
	;
#delimit cr

*READING: 3rd vs. 2nd           
reg cl2p3_va_1_`y' cl2p2_va_1_`y' [aw=students]
global coef = string(round(r(table)[1,1], .001))
global se = string(round(r(table)[2,1], .001))
global lb = string(round(r(table)[5,1], .001))
global ub = string(round(r(table)[6,1], .001))
lincom cl2p2_va_1_`y' - 1
global ptest = string(round(r(p), 0.001))

#delimit ;
graph twoway
	( 
		scatter cl2p3_va_1_`y' cl2p2_va_1_`y' [aw=students], 
		title("Top vs. middle third") msize(tiny) legend(off) 
		xtitle("Reading (2p) 2nd tercile") ytitle("Reading (2p) 3rd tercile") xlabel(-1(.25)1) ylabel(-1(.25)1)  
		text(1 -0.70 "${coef} (${se})", color(red)) 
		text(0.75 -0.70 "[${lb}, ${ub}]", color(blue))                       
		text(0.5 -0.70 "Ho: b=1 (${ptest})") 
	)
	(	lfit cl2p3_va_1_`y' cl2p2_va_1_`y' [aw=students], lcolor(red)		)
	(	lfit cl2p3_va_1_`y' cl2p3_va_1_`y', lcolor(black) lpattern(dash) name(cl2p3v2_`y'))
	;
#delimit cr

*III.
*MATH: 2nd vs. 1st           
reg m2p2_va_1_`y' m2p1_va_1_`y' 
global coef = string(round(r(table)[1,1], .001))
global se = string(round(r(table)[2,1], .001))
global lb = string(round(r(table)[5,1], .001))
global ub = string(round(r(table)[6,1], .001))
lincom m2p1_va_1_`y' - 1
global ptest = string(round(r(p), 0.001))

#delimit ;
graph twoway
	( 
		scatter m2p2_va_1_`y' m2p1_va_1_`y' [aw=students], 
		title("Middle vs. bottom third") msize(tiny) legend(off) 
		xtitle("Math (2p) 1st tercile") ytitle("Math (2p) 2nd tercile") xlabel(-1(.25)1) ylabel(-1(.25)1)  
		text(1 -0.70 "${coef} (${se})", color(red)) 
		text(0.75 -0.70 "[${lb}, ${ub}]", color(blue))                       
		text(0.5 -0.70 "Ho: b=1 (${ptest})") 
	)
	(	lfit m2p2_va_1_`y' m2p1_va_1_`y' [aw=students], lcolor(red)		)
	(	lfit m2p2_va_1_`y' m2p2_va_1_`y', lcolor(black) lpattern(dash) name(m2p2v1_`y'))
	;
#delimit cr

*READING: 2nd vs. 1st           
reg cl2p2_va_1_`y' cl2p1_va_1_`y' [aw=students]
global coef = string(round(r(table)[1,1], .001))
global se = string(round(r(table)[2,1], .001))
global lb = string(round(r(table)[5,1], .001))
global ub = string(round(r(table)[6,1], .001))
lincom cl2p1_va_1_`y' - 1
global ptest = string(round(r(p), 0.001))

#delimit ;
graph twoway
	( 
		scatter cl2p2_va_1_`y' cl2p1_va_1_`y' [aw=students], 
		title("Middle vs. bottom third") msize(tiny) legend(off) 
		xtitle("Reading (2p) 1st tercile") ytitle("Reading (2p) 2nd tercile") xlabel(-1(.25)1) ylabel(-1(.25)1)  
		text(1 -0.70 "${coef} (${se})", color(red)) 
		text(0.75 -0.70 "[${lb}, ${ub}]", color(blue))                       
		text(0.5 -0.70 "Ho: b=1 (${ptest})") 
	)
	(	lfit cl2p2_va_1_`y' cl2p1_va_1_`y' [aw=students], lcolor(red)		)
	(	lfit cl2p2_va_1_`y' cl2p2_va_1_`y', lcolor(black) lpattern(dash) name(cl2p2v1_`y'))
	;
#delimit cr

graph combine m2p3v1_`y' m2p3v2_`y' m2p2v1_`y' cl2p3v1_`y' cl2p3v2_`y'  cl2p2v1_`y', rows(2) cols(3) title("SVA `y'")
graph export "$graphs/scores/het_scores_`y'.png", replace width(2000) height(1400)

}







graph combine ise3v1_`y' ise3v2_`y' ise2v1_`y', rows(1) cols(3) title("SVA `y'") 















*--- (3) ISE heterogeneity ---*
*-----------------------------*
use "$output/het_value_added_schools", clear
est clear

foreach y of global outcomes{

*3rd vs. 1st
reg ise3_va_1_`y' ise1_va_1_`y' [aw=students]
global coef = string(round(r(table)[1,1], .001))
global se = string(round(r(table)[2,1], .001))
global lb = string(round(r(table)[5,1], .001))
global ub = string(round(r(table)[6,1], .001))
lincom ise1_va_1_`y' - 1
global ptest = string(round(r(p), 0.001))

#delimit ;
graph twoway
	( 
		scatter ise3_va_1_`y' ise1_va_1_`y' [aw=students], 
		title("Top vs. bottom third") msize(tiny) legend(off) 
		xtitle("ISE 1st tercile") ytitle("ISE 3rd tercile") xlabel(-1(.25)1) ylabel(-1(.25)1)  
		text(1 -0.8 "${coef} (${se})", color(red)) 
		text(0.85 -0.8 "[${lb}, ${ub}]", color(blue))                       
		text(0.7 -0.8 "Ho: b=1 (${ptest})") 
	)
	(	lfit ise3_va_1_`y' ise1_va_1_`y' [aw=students], lcolor(red)		)
	(	lfit ise3_va_1_`y' ise3_va_1_`y', lcolor(black) lpattern(dash) name(ise3v1_`y'))
	;
#delimit cr

*3rd vs. 2nd 
reg ise3_va_1_`y' ise2_va_1_`y' [aw=students]
global coef = string(round(r(table)[1,1], .001))
global se = string(round(r(table)[2,1], .001))
global lb = string(round(r(table)[5,1], .001))
global ub = string(round(r(table)[6,1], .001))
lincom ise2_va_1_`y' - 1
global ptest = string(round(r(p), 0.001))

#delimit ;
graph twoway
	( 
		scatter ise3_va_1_`y' ise2_va_1_`y' [aw=students], 
		title("Top vs. middle third") msize(tiny) legend(off) 
		xtitle("ISE 2nd tercile") ytitle("ISE 3rd tercile") xlabel(-1(.25)1) ylabel(-1(.25)1)   
		text(1 -0.8 "${coef} (${se})", color(red)) 
		text(0.85 -0.8 "[${lb}, ${ub}]", color(blue))                       
		text(0.7 -0.8 "Ho: b=1 (${ptest})")
	)
	(	lfit ise3_va_1_`y' ise2_va_1_`y' [aw=students], lcolor(red)		)
	(	lfit ise3_va_1_`y' ise3_va_1_`y', lcolor(black) lpattern(dash) name(ise3v2_`y'))
	;
#delimit cr

*2nd vs. 1st 
reg ise2_va_1_`y' ise1_va_1_`y' [aw=students]
global coef = string(round(r(table)[1,1], .001))
global se = string(round(r(table)[2,1], .001))
global lb = string(round(r(table)[5,1], .001))
global ub = string(round(r(table)[6,1], .001))
lincom ise1_va_1_`y' - 1
global ptest = string(round(r(p), 0.001))

#delimit ;
graph twoway
	( 
		scatter ise2_va_1_`y' ise1_va_1_`y' [aw=students], 
		title("Middle vs. bottom third") msize(tiny) legend(off) 
		xtitle("ISE 1st tercile") ytitle("ISE 2nd tercile") xlabel(-1(.25)1) ylabel(-1(.25)1)  
		text(1 -0.8 "${coef} (${se})", color(red)) 
		text(0.85 -0.8 "[${lb}, ${ub}]", color(blue))                       
		text(0.7 -0.8 "Ho: b=1 (${ptest})") 
	)
	(	lfit ise2_va_1_`y' ise1_va_1_`y' [aw=students], lcolor(red)		)
	(	lfit ise2_va_1_`y' ise2_va_1_`y', lcolor(black) lpattern(dash) name(ise2v1_`y'))
	;
#delimit cr

graph combine ise3v1_`y' ise3v2_`y' ise2v1_`y', rows(1) cols(3) title("SVA `y'") 
graph export "$graphs/ise/ise_het_`y'.png", replace width(2400) height(800)
	
}



*cambiar titulos por top/middle/bottom vs. etc. 















graph drop test1 test2 test3

*3rd vs. 1st
local y matricula
reg ise3_va_1_`y' ise1_va_1_`y' [aw=students]
global coef = string(round(r(table)[1,1], .001))
global se = string(round(r(table)[2,1], .001))
global lb = string(round(r(table)[5,1], .001))
global ub = string(round(r(table)[6,1], .001))
lincom ise1_va_1_`y' - 1
global ptest = string(round(r(p), 0.001))

#delimit ;
graph twoway
	( 
		scatter ise3_va_1_`y' ise1_va_1_`y' [aw=students], 
		title("SVA `y'") msize(tiny) legend(off) 
		xtitle("Female SVA") ytitle("Male SVA") xlabel(-1(.25)1) ylabel(-1(.25)1)  
		text(1 -0.70 "${coef} (${se})", color(red)) 
		text(0.75 -0.70 "[${lb}, ${ub}]", color(blue))                       
		text(0.50 -0.70 "Ho: b=1 (${ptest})") 
	)
	(	lfit ise3_va_1_`y' ise1_va_1_`y' [aw=students], lcolor(red)		)
	(	lfit ise3_va_1_`y' ise3_va_1_`y', lcolor(black) lpattern(dash) name(test1))
	;
#delimit cr

*3rd vs. 2nd 
local y matricula
reg ise3_va_1_`y' ise2_va_1_`y' [aw=students]
global coef = string(round(r(table)[1,1], .001))
global se = string(round(r(table)[2,1], .001))
global lb = string(round(r(table)[5,1], .001))
global ub = string(round(r(table)[6,1], .001))
lincom ise2_va_1_`y' - 1
global ptest = string(round(r(p), 0.001))

#delimit ;
graph twoway
	( 
		scatter ise3_va_1_`y' ise2_va_1_`y' [aw=students], 
		title("SVA `y'") msize(tiny) legend(off) 
		xtitle("Female SVA") ytitle("Male SVA") xlabel(-1(.25)1) ylabel(-1(.25)1)  
		text(1 -0.70 "${coef} (${se})", color(red)) 
		text(0.75 -0.70 "[${lb}, ${ub}]", color(blue))                       
		text(0.50 -0.70 "Ho: b=1 (${ptest})") 
	)
	(	lfit ise3_va_1_`y' ise2_va_1_`y' [aw=students], lcolor(red)		)
	(	lfit ise3_va_1_`y' ise3_va_1_`y', lcolor(black) lpattern(dash) name(test2))
	;
#delimit cr

*2nd vs. 1st 
local y matricula
reg ise2_va_1_`y' ise1_va_1_`y' [aw=students]
global coef = string(round(r(table)[1,1], .001))
global se = string(round(r(table)[2,1], .001))
global lb = string(round(r(table)[5,1], .001))
global ub = string(round(r(table)[6,1], .001))
lincom ise1_va_1_`y' - 1
global ptest = string(round(r(p), 0.001))

#delimit ;
graph twoway
	( 
		scatter ise2_va_1_`y' ise1_va_1_`y' [aw=students], 
		title("SVA `y'") msize(tiny) legend(off) 
		xtitle("Female SVA") ytitle("Male SVA") xlabel(-1(.25)1) ylabel(-1(.25)1)  
		text(1 -0.70 "${coef} (${se})", color(red)) 
		text(0.75 -0.70 "[${lb}, ${ub}]", color(blue))                       
		text(0.50 -0.70 "Ho: b=1 (${ptest})") 
	)
	(	lfit ise2_va_1_`y' ise1_va_1_`y' [aw=students], lcolor(red)		)
	(	lfit ise2_va_1_`y' ise2_va_1_`y', lcolor(black) lpattern(dash) name(test3))
	;
#delimit cr


graph combine test1 test2 test3, title("Main title") 
graph export "$graphs/test.png", replace width(2560) height(2000)


*combinar 6 es reading + math  // tener a un costado math y al otro reading 








foreach y of global outcomes{

*3rd vs. 1st
reg ise3_va_1_`y' ise1_va_1_`y' [aw=students]
global coef = string(round(r(table)[1,1], .001))
global se = string(round(r(table)[2,1], .001))
global lb = string(round(r(table)[5,1], .001))
global ub = string(round(r(table)[6,1], .001))
lincom ise1_va_1_`y' - 1
global ptest = string(round(r(p), 0.001))

#delimit ;
graph twoway
	( 
		scatter ise3_va_1_`y' ise1_va_1_`y' [aw=students], 
		title("3rd vs. 1st") msize(tiny) legend(off) 
		xtitle("ISE 1rd tercile") ytitle("ISE 3rd tercile") xlabel(-1(.25)1) ylabel(-1(.25)1)  
		text(1 -0.70 "${coef} (${se})", color(red)) 
		text(0.75 -0.70 "[${lb}, ${ub}]", color(blue))                       
		text(0.50 -0.70 "Ho: b=1 (${ptest})") 
	)
	(	lfit ise3_va_1_`y' ise1_va_1_`y' [aw=students], lcolor(red)		)
	(	lfit ise3_va_1_`y' ise3_va_1_`y', lcolor(black) lpattern(dash) name(ise3v1_`y'))
	;
#delimit cr

*3rd vs. 2nd 
reg ise3_va_1_`y' ise2_va_1_`y' [aw=students]
global coef = string(round(r(table)[1,1], .001))
global se = string(round(r(table)[2,1], .001))
global lb = string(round(r(table)[5,1], .001))
global ub = string(round(r(table)[6,1], .001))
lincom ise2_va_1_`y' - 1
global ptest = string(round(r(p), 0.001))

#delimit ;
graph twoway
	( 
		scatter ise3_va_1_`y' ise2_va_1_`y' [aw=students], 
		title("3rd vs. 2st") msize(tiny) legend(off) 
		xtitle("ISE 2rd tercile") ytitle("ISE 3rd tercile") xlabel(-1(.25)1) ylabel(-1(.25)1)   
		text(1 -0.70 "${coef} (${se})", color(red)) 
		text(0.75 -0.70 "[${lb}, ${ub}]", color(blue))                       
		text(0.50 -0.70 "Ho: b=1 (${ptest})") 
	)
	(	lfit ise3_va_1_`y' ise2_va_1_`y' [aw=students], lcolor(red)		)
	(	lfit ise3_va_1_`y' ise3_va_1_`y', lcolor(black) lpattern(dash) name(ise3v2_`y'))
	;
#delimit cr

*2nd vs. 1st 
reg ise2_va_1_`y' ise1_va_1_`y' [aw=students]
global coef = string(round(r(table)[1,1], .001))
global se = string(round(r(table)[2,1], .001))
global lb = string(round(r(table)[5,1], .001))
global ub = string(round(r(table)[6,1], .001))
lincom ise1_va_1_`y' - 1
global ptest = string(round(r(p), 0.001))

#delimit ;
graph twoway
	( 
		scatter ise2_va_1_`y' ise1_va_1_`y' [aw=students], 
		title("2rd vs. 1st") msize(tiny) legend(off) 
		xtitle("ISE 2rd tercile") ytitle("ISE 1rd tercile") xlabel(-1(.25)1) ylabel(-1(.25)1)  
		text(1 -0.70 "${coef} (${se})", color(red)) 
		text(0.75 -0.70 "[${lb}, ${ub}]", color(blue))                       
		text(0.50 -0.70 "Ho: b=1 (${ptest})") 
	)
	(	lfit ise2_va_1_`y' ise1_va_1_`y' [aw=students], lcolor(red)		)
	(	lfit ise2_va_1_`y' ise2_va_1_`y', lcolor(black) lpattern(dash) name(ise2v1_`y'))
	;
#delimit cr

graph combine ise3v1_`y' ise3v2_`y' ise2v1_`y', rows(1) cols(3) title("SVA `y'") 
graph export "$graphs/ise/ise_het_`y'.png", replace width(3840) height(1000)
	
}


/*
mat M_gen = 


reg h_va_1_matricula m_va_1_matricula [aw=students]
eststo g1 
estadd scalar obs=e(N)
estadd scalar ulim=r(table)[6,1]
estadd scalar llim=r(table)[5,1]
lincom m_va_1_matricula - 1
estadd scalar pval_test=r(p)
ttest h_va_1_matricula == m_va_1_matricula
return list
estadd scalar mean_diff=r(p)


reg h_va_1_matricula m_va_1_matricula [aw=students]
global coef = string(round(r(table)[1,1], .001))
global se = string(round(r(table)[2,1], .001))
global lb = string(round(r(table)[5,1], .001))
global ub = string(round(r(table)[6,1], .001))
lincom m_va_1_matricula - 1
global ptest = string(round(r(p), 0.001))


reg h_va_1_matricula m_va_1_matricula [aw=students]
eststo g1 
estadd scalar obs=e(N)
estadd scalar ulim=r(table)[6,1]
estadd scalar llim=r(table)[5,1]
lincom m_va_1_matricula - 1
estadd scalar pval_test=r(p)
ttest h_va_1_matricula == m_va_1_matricula
return list
estadd scalar mean_diff=r(p)


























