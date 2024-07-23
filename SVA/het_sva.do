clear all

global dir "C:/Users/ALBERTO TRELLES/Documents/Alberto/RA/Code-github/SVA"
global data "C:/Users/ALBERTO TRELLES/Dropbox/COAR Superior/Data"
global temporal "$dir/temporal"
global output "$dir/output"
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

use "$data/va_data.dta", clear

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

*Terciles 
xtile nq3_math_2p = mate_2p_std, nq(3)
xtile nq3_cl_2p = cl_2p_std, nq(3)
xtile nq3_ise = ise, nq(3)


foreach y of global outcomes{
	display as red "`y' model general"
	reghdfe `y' $test_scores $ise $test_scores_primary $individual $father_education $mother_education $house $assets $siagie3, absorb(va_1_`y'=schoolid coar_fe year) vce(robust) resid
	
	display as red "`y' model 2015"
	reghdfe `y' $test_scores $ise $test_scores_primary $individual $father_education $mother_education $house $assets $siagie3 if year==2015, absorb(va_15_`y'=schoolid coar_fe year) vce(robust) resid

	display as red "`y' model 2016"
	reghdfe `y' $test_scores $ise $test_scores_primary $individual $father_education $mother_education $house $assets $siagie3 if year==2016, absorb(va_16_`y'=schoolid coar_fe year) vce(robust) resid
	
}

reghdfe matricula $test_scores $ise $test_scores_primary $individual $father_education $mother_education $house $assets $siagie3, absorb(va_1_matricula=schoolid coar_fe year) vce(robust) resid


*------------------------*
*--- Het by Gender ------*
*------------------------*

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

foreach y of global outcomes{
	display as red "`y' model general"
	reghdfe `y' $test_scores $ise $test_scores_primary $individual $father_education $mother_education $house $assets $siagie3 if nq3_cl_2p==1, absorb(cl2p1_va_1_`y'=schoolid coar_fe year) vce(robust) resid
	reghdfe `y' $test_scores $ise $test_scores_primary $individual $father_education $mother_education $house $assets $siagie3 if nq3_cl_2p==2, absorb(cl2p2_va_1_`y'=schoolid coar_fe year) vce(robust) resid
	reghdfe `y' $test_scores $ise $test_scores_primary $individual $father_education $mother_education $house $assets $siagie3 if nq3_cl_2p==3, absorb(cl2p3_va_1_`y'=schoolid coar_fe year) vce(robust) resid
}

cap drop students
gen students=1
save "$temporal/reading_value_added_students.dta", replace

use "$temporal/reading_added_students.dta", clear
keep schoolid m2p?_va_1_* students
collapse (sum) students (mean) m2p?_va_1_*, by(schoolid)

save "$temporal/reading_value_added_schools.dta", replace


*--------------------------------------*
*--- Het by Socio-economic index ------*
*--------------------------------------*

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



























