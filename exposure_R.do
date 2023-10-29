*========================================================================*
* The effect of the English program on labor market outcomes
*========================================================================*
/* Working with the School Census (Stats 911) to create a database of 
school's characteristics and exposure to English instruction */
*========================================================================*
* Oscar Galvez-Soriano
*========================================================================*
clear
set more off
gl data= "https://raw.githubusercontent.com/galvez-soriano/Papers/main/EngInstruction/Stat911"
gl base2= "https://raw.githubusercontent.com/galvez-soriano/Papers/main/EngInstruction/Data"
gl base= "C:\Users\Oscar Galvez Soriano\Documents\Papers\ReturnsEng\Data"
*========================================================================*
clear
foreach x in 97 98 99 00 01 02 03 04 05 06 07 08 09 10 11 12 13{
append using "$data/stat911_`x'.dta"
}
order state id_mun id_loc cct shift year eng teach_eng hours_eng total_groups total_stud ///
indig_stud anglo_stud latino_stud other_stud disabil high_abil teach_elem  ///
teach_midle teach_high teach_colle teach_mast teach_phd school_supp_exp ///
uniform_exp tuition

sort cct shift year
label var year "Year"
label var eng "Had English program"
* Public schools
gen classif=substr(cct,3,3)
gen priv=substr(cct,3,1)
gen public=1
replace public=0 if priv=="P"
replace public=0 if classif=="SBC" | classif=="SBH" | classif=="SCT"
drop classif priv
gen had_eng=1 if eng==1 & year==2008
replace had_eng=0 if had_eng==.

/* Observed hours of English instruction */
gen h_group=hours_eng/total_groups
replace h_group=0 if h_group==.
label var h_group "Hours of English instruction (per class)"

/* Observed number of English teachers */
gen teach_g=teach_eng/total_groups
replace teach_g=0 if teach_g==.
label var teach_g "English teachers (per class)"

drop state
gen state=substr(cct,1,2)
tostring id_mun, replace format(%03.0f) force
tostring id_loc, replace format(%04.0f) force
rename rural rural2

merge m:m cct using "$base2/schools_06_13.dta"
drop _merge
replace rural=rural2 if rural==.
drop rural2
rename rural rural2
merge m:m state id_mun id_loc using "$base2/Rural2010.dta"
drop if _merge==2
replace rural2=rural if rural2==.
drop _merge rural
rename rural2 rural
merge m:m state id_mun id_loc using "$base2/Rural2.dta"
replace rural=rural2 if rural==.
drop _merge rural2
merge m:m cct using "$base2/schools_geo.dta"
drop if _merge==2
replace id_loc=id_loc2 if rural==.
drop _merge state2 id_mun2 id_loc2
merge m:m state id_mun id_loc using "$base2/Rural2.dta"
replace rural=rural2 if rural==.
drop _merge rural2
rename rural rural2
merge m:m state id_mun id_loc using "$base2/Rural2010.dta"
drop if _merge==2
replace rural2=rural if rural2==.
drop _merge rural
rename rural2 rural
merge m:m cct using "$base2/schools_cpv.dta"
drop if _merge==2
replace id_loc=cve_loc if rural==.
replace rural=1 if rururb=="R" & rural==.
replace rural=0 if rururb=="U" & rural==.
drop _merge cve_ent cve_mun cve_loc rururb

save "$base\d_schools.dta", replace
*========================================================================*
use "$base\d_schools.dta", clear

label var state "State"
drop if cct==""
drop if year==.
bysort cct: gen same_school=_N
keep if same_school>=15 & same_school<=17
drop same_school

merge m:m cct year using "$base2/fts0718.dta"
drop if _merge==2
drop _merge
replace fts=0 if fts==.

order state id_mun id_loc cct shift year
sort state id_mun id_loc cct shift year
save "$base\d_schools.dta", replace
*========================================================================*
/* Creating exposure variable at locality level

The Mexican school census has missing values for some observations at 
the locality level. In this section of the do file, I fill in those missings.
First, I add the missing years and then I interpolate the missing 
observations using the mean between two proximate years. */
*========================================================================*
use "$base\d_schools.dta", clear

gen str geo=(state + id_mun + id_loc)
collapse (mean) h_group [fw=total_stud], by(geo year)

rename h_group hrs_exp
replace hrs_exp=0 if hrs_exp==.
drop if year>2007

/* One missing year */
bysort geo: gen nobs=_n
bysort geo: gen nobs_tot=_N
count
expand 2 if nobs==10 & nobs_tot==10
gen obs=_n
replace year=. if obs>r(N)
replace hrs_exp=. if obs>r(N)
sort geo year
bysort geo: egen sum_year=sum(year)
replace year=1997 if year==. & sum_year==20025
replace year=1998 if year==. & sum_year==20024
replace year=1999 if year==. & sum_year==20023
replace year=2000 if year==. & sum_year==20022
replace year=2001 if year==. & sum_year==20021
replace year=2002 if year==. & sum_year==20020
replace year=2003 if year==. & sum_year==20019
replace year=2004 if year==. & sum_year==20018
replace year=2005 if year==. & sum_year==20017
replace year=2006 if year==. & sum_year==20016
replace year=2007 if year==. & sum_year==20015

sort geo year
drop nobs nobs_tot obs sum_year

/* Two missing years */
bysort geo: gen nobs=_n
bysort geo: gen nobs_tot=_N
count
expand 3 if nobs==9 & nobs_tot==9
gen obs=_n
replace year=. if obs>r(N)
replace hrs_exp=. if obs>r(N)

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
bysort geo: gen year1997=1 if diff_year==1997
bysort geo: egen y1997=sum(year1997)

replace diff_year=. if year>=1998 & y1997==1
replace year=1997 if count_obs==2006 & year==. & y1997==1
drop year1997 y1997

replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2006 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2007 & year==.

sort geo year
keep geo year hrs_exp

/* Three missing years */
bysort geo: gen nobs=_n
bysort geo: gen nobs_tot=_N
count
expand 4 if nobs==8 & nobs_tot==8
gen obs=_n
replace year=. if obs>r(N)
replace hrs_exp=. if obs>r(N)

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
bysort geo: gen year1997=1 if diff_year==1997
bysort geo: egen y1997=sum(year1997)
replace diff_year=. if year>=1998 & y1997==1
replace year=1997 if count_obs==2005 & year==. & y1997==1
drop year1997 y1997

replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2005 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2006 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2007 & year==.
sort geo year
drop count_obs diff_year replace_year
keep geo year hrs_exp

/* Four missing years */
bysort geo: gen nobs=_n
bysort geo: gen nobs_tot=_N
count
expand 5 if nobs==7 & nobs_tot==7
gen obs=_n
replace year=. if obs>r(N)
replace hrs_exp=. if obs>r(N)

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
bysort geo: gen year1997=1 if diff_year==1997
bysort geo: egen y1997=sum(year1997)
replace diff_year=. if year>=1998 & y1997==1
replace year=1997 if count_obs==2004 & year==. & y1997==1
drop year1997 y1997

replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2004 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2005 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2006 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2007 & year==.
sort geo year
drop count_obs diff_year replace_year
keep geo year hrs_exp

/* Five missing years */
bysort geo: gen nobs=_n
bysort geo: gen nobs_tot=_N
count
expand 6 if nobs==6 & nobs_tot==6
gen obs=_n
replace year=. if obs>r(N)
replace hrs_exp=. if obs>r(N)

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
bysort geo: gen year1997=1 if diff_year==1997
bysort geo: egen y1997=sum(year1997)
replace diff_year=. if year>=1998 & y1997==1
replace year=1997 if count_obs==2003 & year==. & y1997==1
drop year1997 y1997

replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2003 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2004 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2005 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2006 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2007 & year==.
sort geo year
drop count_obs diff_year replace_year
keep geo year hrs_exp

/* Six missing years */
bysort geo: gen nobs=_n
bysort geo: gen nobs_tot=_N
count
expand 7 if nobs==5 & nobs_tot==5
gen obs=_n
replace year=. if obs>r(N)
replace hrs_exp=. if obs>r(N)

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
bysort geo: gen year1997=1 if diff_year==1997
bysort geo: egen y1997=sum(year1997)
replace diff_year=. if year>=1998 & y1997==1
replace year=1997 if count_obs==2002 & year==. & y1997==1
drop year1997 y1997

replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2002 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2003 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2004 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2005 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2006 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2007 & year==.
sort geo year
drop count_obs diff_year replace_year
keep geo year hrs_exp

/* Seven missing years */
bysort geo: gen nobs=_n
bysort geo: gen nobs_tot=_N
count
expand 8 if nobs==4 & nobs_tot==4
gen obs=_n
replace year=. if obs>r(N)
replace hrs_exp=. if obs>r(N)

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
bysort geo: gen year1997=1 if diff_year==1997
bysort geo: egen y1997=sum(year1997)
replace diff_year=. if year>=1998 & y1997==1
replace year=1997 if count_obs==2001 & year==. & y1997==1
drop year1997 y1997

replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2001 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2002 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2003 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2004 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2005 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2006 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2007 & year==.
sort geo year
drop count_obs diff_year replace_year
keep geo year hrs_exp

/* Eight missing years */
bysort geo: gen nobs=_n
bysort geo: gen nobs_tot=_N
count
expand 9 if nobs==3 & nobs_tot==3
gen obs=_n
replace year=. if obs>r(N)
replace hrs_exp=. if obs>r(N)

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
bysort geo: gen year1997=1 if diff_year==1997
bysort geo: egen y1997=sum(year1997)
replace diff_year=. if year>=1998 & y1997==1
replace year=1997 if count_obs==2000 & year==. & y1997==1
drop year1997 y1997

replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2000 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2001 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2002 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2003 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2004 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2005 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2006 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2007 & year==.
sort geo year
drop count_obs diff_year replace_year
keep geo year hrs_exp

/* Nine missing years */
bysort geo: gen nobs=_n
bysort geo: gen nobs_tot=_N
count
expand 10 if nobs==2 & nobs_tot==2
gen obs=_n
replace year=. if obs>r(N)
replace hrs_exp=. if obs>r(N)

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
bysort geo: gen year1997=1 if diff_year==1997
bysort geo: egen y1997=sum(year1997)
replace diff_year=. if year>=1998 & y1997==1
replace year=1997 if count_obs==1999 & year==. & y1997==1
drop year1997 y1997

replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==1999 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2000 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2001 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2002 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2003 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2004 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2005 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2006 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2007 & year==.
sort geo year
drop count_obs diff_year replace_year
keep geo year hrs_exp

/* Ten missing years */
bysort geo: gen nobs=_n
bysort geo: gen nobs_tot=_N
count
expand 11 if nobs==1 & nobs_tot==1
gen obs=_n
replace year=. if obs>r(N)
replace hrs_exp=. if obs>r(N)

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
bysort geo: gen year1997=1 if diff_year==1997
bysort geo: egen y1997=sum(year1997)
replace diff_year=. if year>=1998 & y1997==1
replace year=1997 if count_obs==1998 & year==. & y1997==1
drop year1997 y1997

replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==1998 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==1999 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2000 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2001 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2002 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2003 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2004 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2005 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2006 & year==.
drop count_obs diff_year replace_year

sort geo year
bysort geo: gen count_obs=_n+1996
gen diff_year=count_obs if year!=count_obs
replace diff_year=0 if diff_year==.
replace diff_year=diff_year-year[_n-1] if diff_year!=0
replace diff_year=. if diff_year!=1
replace diff_year=count_obs if diff_year==1
bysort geo: egen replace_year=sum(diff_year)
replace year=replace_year if count_obs==2007 & year==.
sort geo year
drop count_obs diff_year replace_year
keep geo year hrs_exp

/* Older cohorts */
sort geo year
bysort geo: gen nobs=_n
count
expand 8 if nobs==1
gen obs=_n
replace year=. if obs>r(N)
replace hrs_exp=. if obs>r(N)

sort geo year
bysort geo: gen count_obs=_n+1978
replace year=count_obs if year==.
drop nobs obs count_obs

sort geo year
gen cohort=year-11
gen check=substr(geo,6,10)
drop if check==""
drop year check

forval nmiss = 3/10 {  // Loop through 3 to 10 missing years
    bysort geo: gen nobs = _n
    bysort geo: gen nobs_tot = _N
    count
    local to_expand = `nmiss' - (8 - r(N))

    if `to_expand' > 0 {
        expand `to_expand' if nobs == 8 & nobs_tot == 8
        gen obs = _n
        replace year = . if obs > r(N)
        replace hrs_exp = . if obs > r(N)

        sort geo year
        bysort geo: gen count_obs = _n + 1996
        gen diff_year = count_obs if year != count_obs
        bysort geo: egen year1997 = sum(diff_year)
        bysort geo: egen y1997 = sum(year1997)
        replace diff_year = . if year >= 1998 & y1997 == 1
        replace year = 1997 if count_obs == 2005 & year == . & y1997 == 1
        drop year1997 y1997

        replace diff_year = 0 if diff_year == .
        replace diff_year = diff_year - year[_n-1] if diff_year != 0
        replace diff_year = . if diff_year != 1
        replace diff_year = count_obs if diff_year == 1
        bysort geo: egen replace_year = sum(diff_year)
        replace year = replace_year if count_obs == 2005 & year == .
        drop count_obs diff_year replace_year

        // ... Repeat the steps for each missing year
    }
}

sort geo year
keep geo year hrs_exp

save "$base\exposure_loc.dta", replace
*========================================================================* 
use "$base\exposure_loc.dta", clear
sort geo cohort
gen state=substr(geo,1,2)
gen hrs_exp0=hrs_exp

* Calculate linear interpolation 'lin_eng' and growth rate 'gr_eng'
gen lin_eng = 0

bysort geo cohort (cohort): egen min_cohort = min(cohort)
bysort geo cohort (cohort): egen max_cohort = max(cohort)

forval year = `min_cohort' / (`max_cohort' - 1) {
    replace lin_eng = lin_eng[_n - 1] + gr_eng[_n] if cohort == `year' & cohort != `year' + 1 & cohort != `year' - 1
}

bysort geo cohort: replace hrs_exp = lin_eng if hrs_exp == . & lin_eng != .

* Identify and handle successive years with 0 hours of English
gen zero_exp = (hrs_exp == 0 & hrs_exp[_n - 1] == 0)

forval i = 1/2 {
    replace hrs_exp = 0 if zero_exp & hrs_exp[_n - `i'] == 0
}

drop zero_exp

/*
bysort geo: egen min_eng=min(hrs_exp)
bysort geo: egen max_eng=max(hrs_exp)
bysort geo: egen mean_eng=mean(hrs_exp) if hrs_exp!=0
bysort geo: egen tot_eng=total(hrs_exp)
bysort geo: gen nz_obs=tot_eng/mean_eng
bysort geo: gen gr_eng=max_eng/nz_obs

bysort geo: gen lin_eng=0 if hrs_exp==0
bysort geo: replace lin_eng=lin_eng[_n-1]+gr_eng[_n] if missing(lin_eng)

bysort geo: replace hrs_exp=lin_eng if hrs_exp[_n-1]>hrs_exp[_n] & hrs_exp[_n+1]>hrs_exp[_n] & (lin_eng[_n]>hrs_exp[_n] | missing(hrs_exp)) & lin_eng[_n]!=. & lin_eng[_n]!=0
bysort geo: replace hrs_exp=lin_eng+gr_eng if hrs_exp[_n]==lin_eng[_n] & gr_eng[_n]!=. & cohort==1996

bysort geo: replace gr_eng=gr_eng[_n-1] if gr_eng[_n-1]>0 & gr_eng[_n-1]!=. & missing(gr_eng)
replace hrs_exp=0 if hrs_exp==. & gr_eng==.

foreach x in 1986 1985 1984 1983 1982 1981 1980 1979{
bysort geo: replace hrs_exp=hrs_exp[_n+1]-gr_eng[_n]/4 if hrs_exp[_n]==. & cohort==`x'
}

replace hrs_exp=0 if hrs_exp<0 & hrs_exp!=.
*/


*replace hrs_exp=0 if hrs_exp==.

bysort state cohort: egen hrs_eng=mean(hrs_exp)
label var hrs_eng "Extrapolated"
bysort state cohort: egen hrs_eng0=mean(hrs_exp0)
label var hrs_eng0 "With missings"

twoway (line hrs_eng cohort if state=="01") (line hrs_eng0 cohort if state=="01")
graph export "$base\figAGS.png", replace
twoway (line hrs_eng cohort if state=="05") (line hrs_eng0 cohort if state=="05")
graph export "$base\figCOAH.png", replace
twoway (line hrs_eng cohort if state=="10") (line hrs_eng0 cohort if state=="10")
graph export "$base\figDGO.png", replace
twoway (line hrs_eng cohort if state=="19") (line hrs_eng0 cohort if state=="19")
graph export "$base\figNL.png", replace
twoway (line hrs_eng cohort if state=="25") (line hrs_eng0 cohort if state=="25")
graph export "$base\figSIN.png", replace
twoway (line hrs_eng cohort if state=="26") (line hrs_eng0 cohort if state=="26")
graph export "$base\figSON.png", replace
twoway (line hrs_eng cohort if state=="28") (line hrs_eng0 cohort if state=="28")
graph export "$base\figTAM.png", replace

twoway (line hrs_eng cohort if state=="02") (line hrs_eng0 cohort if state=="02")
graph export "$base\figBC.png", replace
twoway (line hrs_eng cohort if state=="03") (line hrs_eng0 cohort if state=="03")
graph export "$base\figBCS.png", replace
twoway (line hrs_eng cohort if state=="06") (line hrs_eng0 cohort if state=="06")
graph export "$base\figCOL.png", replace
twoway (line hrs_eng cohort if state=="08") (line hrs_eng0 cohort if state=="08")
graph export "$base\figCHIH.png", replace
twoway (line hrs_eng cohort if state=="11") (line hrs_eng0 cohort if state=="11")
graph export "$base\figGTO.png", replace
twoway (line hrs_eng cohort if state=="14") (line hrs_eng0 cohort if state=="14")
graph export "$base\figJAL.png", replace
twoway (line hrs_eng cohort if state=="18") (line hrs_eng0 cohort if state=="18")
graph export "$base\figNAY.png", replace
twoway (line hrs_eng cohort if state=="24") (line hrs_eng0 cohort if state=="24")
graph export "$base\figSLP.png", replace
twoway (line hrs_eng cohort if state=="32") (line hrs_eng0 cohort if state=="32")
graph export "$base\figZAC.png", replace

*keep geo cohort hrs_exp

save "$base\exposure_loc.dta", replace
