global dir "C:\Users\ALBERTO TRELLES\Documents\Alberto\RA\Code-github\NdM"
global data "$dir/Data"
global input "$data/Input"
global organized "$data/Organized"
global temporal "$data/Temporal"

cd "$dir"

/*
COSAS QUE HACER:

1. Índice con las siguientes variables principales
ctryhdr3 - if i try hard i can improve my situation in life
cpldecr3 - other people in my family make all the decisions about how i spend my time
cftrwrr3 - i like to make plans for my future studies and work
cbrjobr3 - if i study hard at school i will be rewarded by a better job in the future
(we can include ag5 as well - i have no choice about the work i do. See varname for rounds >2 --> CNOCHCR4)

effort, decisions, plans, reward, nochoice 
*Round2 only has yes, no, more or less

2. Variables de violencia
ren (bfamlyr3 bbyfrnr3 bstrngr3 bfrndr3) (bfamily bpartner bstranger bfriend)

*/


// -------------------------------------------------------------------------- //
// ROUND 3 - 2009															  //
// -------------------------------------------------------------------------- //

*---Younger Cohort---*
*--------------------*
use "$input/r3-yc_childlevel", clear
gen period=3
gen cohort="younger"

*Date of Interview
gen day = substr(string(cdint, "%tdD_m_Y"), 1, 2)
gen month = substr(string(cdint, "%tdD_m_Y"), 4, 3)
gen year = substr(string(cdint, "%tdD_m_Y"), 8, .)
replace year = "09" if year==""
global dates day month year

*Child ID
gen personid = real(substr(childid, 3, .))

*Place ID
merge 1:1 childid using "$input/r3-yc_placeid.dta"
drop if _merge!= 3 //only 109 didn't merge (all from using)
drop _merge
gen locationid = real(substr(placeid, 3, 2) + substr(placeid, 6, 2))

*Agency variables
ren (ctryhdr3 cpldecr3 cftrwrr3 cbrjobr3 cnochcr3) (effort decisions plans reward nochoice)
global agency effort decisions plans reward nochoice

keep personid locationid period cohort $agency $dates 
order personid locationid period cohort $agency
sort personid locationid

save "$temporal/r3-yc_feels.dta", replace

*---Older Cohort---*
*------------------*
use "$input/r3-oc_childlevel", clear
gen period=3
gen cohort="older"

*Date of Interview
gen day = substr(string(cdint, "%tdD_m_Y"), 1, 2)
gen month = substr(string(cdint, "%tdD_m_Y"), 4, 3)
gen year = substr(string(cdint, "%tdD_m_Y"), 8, .)
replace year = "09" if year==""
global dates day month year

*Child ID
gen personid = real(substr(childid, 3, .))

*Place ID
merge 1:1 childid using "$input/r3-oc_placeid.dta"
drop if _merge!= 3 //only 36 didn't merge (all from using)
drop _merge
gen locationid = real(substr(placeid, 3, 2) + substr(placeid, 6, 2))

*Agency variables
ren (ctryhdr3 cpldecr3 cftrwrr3 cbrjobr3 cnochcr3) (effort decisions plans reward nochoice)
global agency effort decisions plans reward nochoice

*Violence variables
ren (bfamlyr3 bbyfrnr3 bstrngr3 bfrndr3) (bfamily bpartner bstranger bfriend)
global violence bfamily bpartner bstranger bfriend

keep personid locationid period cohort $agency $violence $dates 
order personid locationid period cohort $agency $violence
sort personid locationid

save "$temporal/r3-oc_feels.dta", replace


// -------------------------------------------------------------------------- //
// ROUND 4 - 2013															  //
// -------------------------------------------------------------------------- //

*---Younger Cohort---*
*--------------------*
use "$input/r4-yc_childlevel", clear
gen period=4
gen cohort="younger"

*Date of Interview
gen day = substr(DINT, 1, 2)
gen month = substr(DINT, 4, 2)
gen year = substr(DINT, 9, 2)
global dates day month year

*Child ID
ren CHILDCODE personid
gen childid = "PE0" + string(personid, "%05.0f") if personid<101001
replace childid = "PE" + string(personid, "%05.0f") if personid>=101001

*Place ID
ren childid CHILDID
merge 1:1 CHILDID using "$input/r4-yc_placeid.dta"
drop if _merge!= 3 //all matched
drop _merge
gen locationid = real(PLACEID)
ren (CHILDID PLACEID) (childid placeid)

*Agency variables
ren (CTRYHDR4 CPLDECR4 CFTRWRR4 CBRJOBR4 CNOCHCR4) (effort decisions plans reward nochoice)
ren (STRYHDR4 SPLDECR4 SFTRWRR4 SBRJOBR4 SNOCHCR4) (seffort sdecisions splans sreward snochoice)
global agency effort decisions plans reward nochoice
global sagency seffort sdecisions splans sreward snochoice

keep personid locationid period cohort $agency $sagency $dates 
order personid locationid period cohort $agency $sagency
sort personid locationid

save "$temporal/r4-yc_feels.dta", replace


*---Older Cohort---*
*------------------*
use "$input/r4-oc_childlevel", clear
gen period=4
gen cohort="older"

*Date of Interview
gen day = substr(DINT, 1, 2)
gen month = substr(DINT, 4, 2)
gen year = substr(DINT, 9, 2)
global dates day month year

*Child ID
ren CHILDCODE personid
gen childid = "PE0" + string(personid, "%05.0f") if personid<101001
replace childid = "PE" + string(personid, "%05.0f") if personid>=101001

*Place ID
ren childid CHILDID
merge 1:1 CHILDID using "$input/r4-oc_placeid.dta"
drop if _merge!= 3 //all matched
drop _merge
gen locationid = real(PLACEID)
ren (CHILDID PLACEID) (childid placeid)

*Agency variables
ren (CTRYHDR4 CPLDECR4 CFTRWRR4 CBRJOBR4 CNOCHCR4) (effort decisions plans reward nochoice)
global agency effort decisions plans reward nochoice

*Violence variables
ren personid CHILDCODE
merge 1:1 CHILDCODE using "$input/r4-oc_saq.dta"
drop if _merge!= 3 //all matched
drop _merge
ren CHILDCODE personid

ren (BFAMLYR4 BBYFRNR4 BSTRNGR4 BFRNDR4 BTEACHR4 BSPOUSR4 BEMPLYR4) (bfamily bpartner bstranger bfriend bteacher bspouse bemployer)
global violence bfamily bpartner bstranger bfriend bteacher bspouse bemployer

keep personid locationid period cohort $agency $violence $dates 
order personid locationid period cohort $agency $violence
sort personid locationid

save "$temporal/r4-oc_feels.dta", replace



// -------------------------------------------------------------------------- //
// ROUND 5 - 2016/17														  //
// -------------------------------------------------------------------------- //

*---Younger Cohort---*
*--------------------*
use "$input/r5-yc_childlevel", clear
gen period=5
gen cohort="younger"

*Date of Interview
gen day = substr(DINT, 1, 2)
gen month = substr(DINT, 4, 2)
gen year = substr(DINT, 9, 2)
global dates day month year

*Child ID
ren CHILDCODE personid
gen childid = "PE0" + string(personid, "%05.0f") if personid<101001
replace childid = "PE" + string(personid, "%05.0f") if personid>=101001

*Place ID
ren personid CHILDCODE
merge 1:1 CHILDCODE using "$input/r5-yc_placeid.dta"
drop if _merge != 3 //all matched
drop _merge
gen locationid = real(substr(PLACEID5, 3, 2) + substr(PLACEID5, 6, 2))
ren (CHILDCODE PLACEID5) (personid placeid)

*Agency variables - merge with siblings ddbb
ren personid CHILDCODE
merge 1:1 CHILDCODE using "$input/r5-sb_childlevel.dta"
drop _merge //only 776 matched. Others don't have sibling (1 not matched from using --> check this)
ren CHILDCODE personid

ren (CTRYHDR5 CPLDECR5 CFTRWRR5 CBRJOBR5 CNOCHCR5) (effort decisions plans reward nochoice)
ren (STRYHDR5 SPLDECR5 SFTRWRR5 SBRJOBR5 SNOCHCR5) (seffort sdecisions splans sreward snochoice)
global agency effort decisions plans reward nochoice
global sagency seffort sdecisions splans sreward snochoice

*Violence
ren personid CHILDCODE
merge 1:1 CHILDCODE using "$input/r5-yc_saq.dta"
drop _merge //just 1 from master not matched
ren CHILDCODE personid 

ren (BFAMLYR5 BBYFRNR5 BSTRNGR5 BFRNDR5 BTEACHR5 BSPOUSR5 BEMPLYR5) (bfamily bpartner bstranger bfriend bteacher bspouse bemployer)
global violence bfamily bpartner bstranger bfriend bteacher bspouse bemployer

keep personid locationid period cohort $agency $sagency $violence $dates 
order personid locationid period cohort $agency $sagency $violence
sort personid locationid

save "$temporal/r5-yc_feels.dta", replace

*---Older Cohort---*
*------------------*
use "$input/r5-oc_childlevel", clear
gen period=5
gen cohort="older"

*Date of Interview
gen day = substr(DINT, 1, 2)
gen month = substr(DINT, 4, 2)
gen year = substr(DINT, 9, 2)
global dates day month year

*Child ID
ren CHILDCODE personid
gen childid = "PE0" + string(personid, "%05.0f") if personid<101001
replace childid = "PE" + string(personid, "%05.0f") if personid>=101001

*Place ID
ren personid CHILDCODE
merge 1:1 CHILDCODE using "$input/r5-oc_placeid.dta"
drop if _merge != 3 //all matched
drop _merge
gen locationid = real(substr(PLACEID5, 3, 2) + substr(PLACEID5, 6, 2))
ren (CHILDCODE PLACEID5) (personid placeid)

*Agency variables
ren (CTRYHDR5 CPLDECR5 CFTRWRR5 CBRJOBR5 CNOCHCR5) (effort decisions plans reward nochoice)
global agency effort decisions plans reward nochoice

*Violence variables
ren personid CHILDCODE
merge 1:1 CHILDCODE using "$input/r5-oc_saq.dta"
drop _merge //all matched
ren CHILDCODE personid

ren (BFAMLYR5 BBYFRNR5 BSTRNGR5 BFRNDR5 BTEACHR5 BSPOUSR5 BEMPLYR5) (bfamily bpartner bstranger bfriend bteacher bspouse bemployer)
global violence bfamily bpartner bstranger bfriend bteacher bspouse bemployer

keep personid locationid period cohort $agency $violence $dates 
order personid locationid period cohort $agency $violence
sort personid locationid

save "$temporal/r5-oc_feels.dta", replace


// -------------------------------------------------------------------------- //
// APPENDING FILES 															  //
// -------------------------------------------------------------------------- //

use "$temporal/r3-yc_feels.dta", clear
append using "$temporal/r3-oc_feels.dta"

forval i=4/5{
	append using "$temporal/r`i'-yc_feels.dta"
	append using "$temporal/r`i'-oc_feels.dta"	
}

duplicates tag personid, gen(times_person)
replace times_person = times_person + 1 //2408 children appear in all 4 rounds (r2-5)
sort personid period locationid 

save "$organized/pool_feels.dta", replace
stop 








