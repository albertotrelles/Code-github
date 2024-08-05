global dir "C:\Users\ALBERTO TRELLES\Documents\Alberto\RA\Code-github\NdM"
global data "$dir/Data"
global input "$data/Input"
global organized "$data/Organized"
global temporal "$data/Temporal"

cd "$dir"

/*
COSAS QUE HACER
- Variable cohort = 1 si pertenece al oldercohort, 0 si pertenece al youngercohort 
- Trabajar con personid (numeric)
- Formato de fecha (tener día, mes y año)
- Establecer placeid (trabajar con numeric, llamarla locationid)

OBSERVATIONS
- no placeid in ddbb for rounds 4 and 5 (do the merge with something else maybe)

*/





// -------------------------------------------------------------------------- //
// ROUND 1 - 2002															  //
// -------------------------------------------------------------------------- //

*--- Younger Cohort ---*
*----------------------*
use "$input/r1-yc_childlevel", clear

*Date of Interview
gen day = substr(string(dint, "%tdD_m_Y"), 1, 2)
gen month = substr(string(dint, "%tdD_m_Y"), 4, 3)
gen year = substr(string(dint, "%tdD_m_Y"), 8, .)
replace year = "02" if year==""

*Child ID
gen personid = real(substr(childid, 3, .))

*Place ID
gen locationid = real(substr(placeid, 3, 2) + substr(placeid, 6, 2))

*Generating some variables
gen period=1
gen cohort="younger"


*--- Older Cohort ---*
*--------------------*
use "$input/r1-oc_childlevel", clear

*Date of Interview
gen day = substr(string(dint, "%tdD_m_Y"), 1, 2)
gen month = substr(string(dint, "%tdD_m_Y"), 4, 3)
gen year = substr(string(dint, "%tdD_m_Y"), 8, .)
replace year = "02" if year==""

*Child ID
gen personid = real(substr(childid, 3, .))

*Place ID
gen locationid = real(substr(placeid, 3, 2) + substr(placeid, 6, 2))

*Generating some variables
gen period=1
gen cohort="older"




// -------------------------------------------------------------------------- //
// ROUND 2 - 2007															  //
// -------------------------------------------------------------------------- //
use "$input/r2-yc_childlevel", clear

*Date of Interview
gen day = substr(string(dtopi, "%tdD_m_Y"), 1, 2)
gen month = substr(string(dtopi, "%tdD_m_Y"), 4, 3)
gen year = substr(string(dtopi, "%tdD_m_Y"), 8, .)
replace year = "07" if year==""

*Child ID
gen personid = real(substr(childid, 3, .))

*Place ID
gen locationid = real(substr(placeid, 3, 2) + substr(placeid, 6, 2))






// -------------------------------------------------------------------------- //
// ROUND 3 - 2009															  //
// -------------------------------------------------------------------------- //
use "$input/r3-yc_childlevel", clear

*Date of Interview
gen day = substr(string(cdint, "%tdD_m_Y"), 1, 2)
gen month = substr(string(cdint, "%tdD_m_Y"), 4, 3)
gen year = substr(string(cdint, "%tdD_m_Y"), 8, .)
replace year = "09" if year==""

*Child ID
gen personid = real(substr(childid, 3, .))

*Place ID
merge 1:1 childid using "$input/r3-yc_placeid.dta"
drop if _merge!= 3 //only 109 didn't merge (all from using)
drop _merge
gen locationid = real(substr(placeid, 3, 2) + substr(placeid, 6, 2))



// -------------------------------------------------------------------------- //
// ROUND 4 - 2013															  //
// -------------------------------------------------------------------------- //
use "$input/r4-yc_childlevel", clear

*Date of Interview 
gen day = substr(DINT, 1, 2)
gen month = substr(DINT, 4, 2)
gen year = substr(DINT, 9, 2)

*Child ID
ren CHILDCODE personid
gen childid = "PE0" + string(personid, "%05.0f") if personid<101001
replace childid = "PE" + string(personid, "%05.0f") if personid>=101001

*Place ID
ren childid CHILDID
merge 1:1 CHILDID using "$input/r4-yc_placeid.dta"
drop if _merge!= 3 //all matched
drop _merge
gen locationid = real(substr(PLACEID, 3, 2) + substr(PLACEID, 6, 2))
ren (CHILDID PLACEID) (childid placeid)




// -------------------------------------------------------------------------- //
// ROUND 5 - 2016/17														  //
// -------------------------------------------------------------------------- //
use "$input/r5-yc_childlevel", clear

*Date of Interview
gen day = substr(DINT, 1, 2)
gen month = substr(DINT, 4, 2)
gen year = substr(DINT, 9, 2)

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

































/*
/*
gen a = string(dint, "%tdD_m_Y")
gen day = substr(a, 1, 2)
gen month = substr(a, 4, 3)
gen year = substr(a, 8, .)
*/














