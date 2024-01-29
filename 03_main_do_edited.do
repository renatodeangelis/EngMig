*========================================================================*
/* English skills and labor market outcomes in Mexico */
*========================================================================*
clear
set more off
gl data= "https://raw.githubusercontent.com/galvez-soriano/Papers/main/ReturnsEng/Data"
gl base= "C:\Users\rdeangelis\OneDrive - The University of Chicago"
gl doc= "C:\Users\rdeangelis\OneDrive - The University of Chicago"
*========================================================================*
/* Interpolation */
*========================================================================*
/* */
use "$base\exposure_loc.dta", clear
sort geo year
gen state=substr(geo,1,2)
gen hrs_exp0=hrs_exp

forval i = 1/17 {
    gen next_year_hrs_exp = hrs_exp[_n+1]
    replace hrs_exp = 0 if next_year_hrs_exp == 0 & !missing(next_year_hrs_exp) & year < year[_n+1]
    drop next_year_hrs_exp
}

gen interpolated_hrs_exp = (hrs_exp[_n-1] + hrs_exp[_n+1])/2

replace hrs_exp = interpolated_hrs_exp if missing(hrs_exp) & !missing(hrs_exp[_n-1]) & !missing(hrs_exp[_n+1]) & year > year[_n-1] & year < year[_n+1]

drop interpolated_hrs_exp

bysort state cohort: egen hrs_eng=mean(hrs_exp)
label var hrs_eng "Extrapolated"
bysort state cohort: egen hrs_eng0=mean(hrs_exp0)
label var hrs_eng0 "With missings"

save "$base\exposure_loc.dta", replace
*========================================================================*
/* TABLE 4. Effect of English programs (staggered DiD) */
*========================================================================*
/* This code uses staggered difference-in-difference to estimate the effect of
the enactment of an English instruction policy in Mexico during the early 1990s 
on four principal outcomes: weekly hours of English instruction, probability of 
speaking English, log wages, and probability of employment. The program was
implemented only in certain Mexican states, those states began implementation
in different years, and within those states, certain localities either implemented
the policy some time after the state began implementation, or failed to implement it
altogether. 

This code presents three ways of approaching these heterogeneities. The first only
differentiates between adopter states and non-adopter states. The second exploits
locality by cohort variations by including only those locality-years where the program
was implemented in the treatment cohort and including the rest in the non-treatment cohort.
The third refines this nuance and excludes the localities that didn't immediately implement 
the program from the analysis altogether. 
*/

use "$data/eng_abil.dta", clear
keep if biare==1
keep if state=="01" | state=="05" | state=="10" ///
| state=="19" | state=="25" | state=="26" | state=="28" ///
| state=="02" | state=="03" | state=="08" | state=="18" ///
| state=="14" | state=="24" | state=="32" | state=="06" | state=="11"

gen engl=hrs_exp>=0.1
gen had_policy=0 
replace had_policy=1 if state=="01" & (cohort>=1990 & cohort<=1995)
replace had_policy=1 if state=="05" & (cohort>=1988 & cohort<=1996)
replace had_policy=1 if state=="10" & (cohort>=1991 & cohort<=1996)
replace had_policy=1 if state=="19" & (cohort>=1987 & cohort<=1996)
replace had_policy=1 if state=="25" & (cohort>=1993 & cohort<=1996)
replace had_policy=1 if state=="26" & (cohort>=1993 & cohort<=1996)
replace had_policy=1 if state=="28" & (cohort>=1990 & cohort<=1996)
keep if cohort>=1975 & cohort<=1996

/* Full sample (staggered DiD) */ 
eststo clear
eststo: areg hrs_exp had_policy i.cohort i.edu female indigenous married ///
[aw=weight] if paidw==1, absorb(geo) vce(cluster geo)
boottest had_policy, seed(6) noci
eststo: areg eng had_policy i.cohort i.edu cohort female indigenous married ///
[aw=weight] if paidw==1, absorb(geo) vce(cluster geo)
boottest had_policy, seed(6) noci
eststo: areg lwage had_policy i.cohort i.edu female indigenous married ///
[aw=weight] if paidw==1, absorb(geo) vce(cluster geo)
boottest had_policy, seed(6) noci
eststo: areg paidw had_policy i.cohort i.edu female indigenous married ///
[aw=weight], absorb(geo) vce(cluster geo)
boottest had_policy, seed(6) noci
esttab using "$doc\tab_StaggDD.tex", cells(b(star fmt(%9.3f)) se(par)) ///
star(* 0.10 ** 0.05 *** 0.01) title(English abilities) keep(had_policy) ///
stats(N ar2, fmt(%9.0fc %9.3f)) replace

/*
Locality by cohort variation
*/
use "$data/eng_abil.dta", clear
keep if biare==1
keep if state=="01" | state=="05" | state=="10" ///
| state=="19" | state=="25" | state=="26" | state=="28" ///
| state=="02" | state=="03" | state=="08" | state=="18" ///
| state=="14" | state=="24" | state=="32" | state=="06" | state=="11"

gen engl=hrs_exp>=0.1
gen had_policy=0 
replace had_policy=1 if state=="01" & (cohort>=1990 & cohort<=1995) & engl==1
replace had_policy=1 if state=="05" & (cohort>=1988 & cohort<=1996) & engl==1
replace had_policy=1 if state=="10" & (cohort>=1991 & cohort<=1996) & engl==1
replace had_policy=1 if state=="19" & (cohort>=1987 & cohort<=1996) & engl==1
replace had_policy=1 if state=="25" & (cohort>=1993 & cohort<=1996) & engl==1
replace had_policy=1 if state=="26" & (cohort>=1993 & cohort<=1996) & engl==1
replace had_policy=1 if state=="28" & (cohort>=1990 & cohort<=1996) & engl==1
keep if cohort>=1975 & cohort<=1996

eststo clear
eststo: areg hrs_exp had_policy i.cohort i.edu female indigenous married ///
[aw=weight] if paidw==1, absorb(geo) vce(cluster geo)
boottest had_policy, seed(6) noci
eststo: areg eng had_policy i.cohort i.edu cohort female indigenous married ///
[aw=weight] if paidw==1, absorb(geo) vce(cluster geo)
boottest had_policy, seed(6) noci
eststo: areg lwage had_policy i.cohort i.edu female indigenous married ///
[aw=weight] if paidw==1, absorb(geo) vce(cluster geo)
boottest had_policy, seed(6) noci
eststo: areg paidw had_policy i.cohort i.edu female indigenous married ///
[aw=weight], absorb(geo) vce(cluster geo)
boottest had_policy, seed(6) noci
esttab using "$doc\tab_StaggDD1.tex", cells(b(star fmt(%9.3f)) se(par)) ///
star(* 0.10 ** 0.05 *** 0.01) title(English abilities) keep(had_policy) ///
stats(N ar2, fmt(%9.0fc %9.3f)) replace

/*
Excluding localities with no exposure in treatment states 
*/
use "$data/eng_abil.dta", clear
keep if biare==1
keep if state=="01" | state=="05" | state=="10" ///
| state=="19" | state=="25" | state=="26" | state=="28" ///
| state=="02" | state=="03" | state=="08" | state=="18" ///
| state=="14" | state=="24" | state=="32" | state=="06" | state=="11"

gen engl=hrs_exp>=0.1
gen had_policy=0 
replace had_policy=1 if state=="01" & (cohort>=1990 & cohort<=1995) & engl==1
replace had_policy=1 if state=="05" & (cohort>=1988 & cohort<=1996) & engl==1
replace had_policy=1 if state=="10" & (cohort>=1991 & cohort<=1996) & engl==1
replace had_policy=1 if state=="19" & (cohort>=1987 & cohort<=1996) & engl==1
replace had_policy=1 if state=="25" & (cohort>=1993 & cohort<=1996) & engl==1
replace had_policy=1 if state=="26" & (cohort>=1993 & cohort<=1996) & engl==1
replace had_policy=1 if state=="28" & (cohort>=1990 & cohort<=1996) & engl==1
keep if cohort>=1975 & cohort<=1996

gen delayed_uptake=0
replace delayed_uptake=1 if state=="01" & cohort==1990 & engl == 0
replace delayed_uptake=1 if state=="05" & cohort==1988 & engl == 0
replace delayed_uptake=1 if state=="10" & cohort==1991 & engl == 0
replace delayed_uptake=1 if state=="19" & cohort==1987 & engl == 0
replace delayed_uptake=1 if state=="25" & cohort==1993 & engl == 0
replace delayed_uptake=1 if state=="26" & cohort==1993 & engl == 0
replace delayed_uptake=1 if state=="28" & cohort==1990 & engl == 0

egen any_delayed_uptake = max(delayed_uptake), by(geo)
bysort geo (any_delayed_uptake): drop if any_delayed_uptake[1] == 1
drop delayed_uptake, any_delayed_uptake

eststo clear
eststo: areg hrs_exp had_policy i.cohort i.edu female indigenous married ///
[aw=weight] if paidw==1, absorb(geo) vce(cluster geo)
boottest had_policy, seed(6) noci
eststo: areg eng had_policy i.cohort i.edu cohort female indigenous married ///
[aw=weight] if paidw==1, absorb(geo) vce(cluster geo)
boottest had_policy, seed(6) noci
eststo: areg lwage had_policy i.cohort i.edu female indigenous married ///
[aw=weight] if paidw==1, absorb(geo) vce(cluster geo)
boottest had_policy, seed(6) noci
eststo: areg paidw had_policy i.cohort i.edu female indigenous married ///
[aw=weight], absorb(geo) vce(cluster geo)
boottest had_policy, seed(6) noci
esttab using "$doc\tab_StaggDD2.tex", cells(b(star fmt(%9.3f)) se(par)) ///
star(* 0.10 ** 0.05 *** 0.01) title(English abilities) keep(had_policy) ///
stats(N ar2, fmt(%9.0fc %9.3f)) replace
