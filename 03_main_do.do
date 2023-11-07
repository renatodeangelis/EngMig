*========================================================================*
/* English skills and labor market outcomes in Mexico */
*========================================================================*
/* Author: Oscar Galvez-Soriano */
*========================================================================*
clear
set more off
gl data= "https://raw.githubusercontent.com/galvez-soriano/Papers/main/ReturnsEng/Data"
gl base= "C:\Users\Oscar Galvez Soriano\Documents\Papers\ReturnsEng\Data"
gl doc= "C:\Users\Oscar Galvez Soriano\Documents\Papers\ReturnsEng\Doc"
*========================================================================*
/* TABLE 4. Effect of English programs (staggered DiD) */
*========================================================================*
use "$data/eng_abil.dta", clear
keep if biare==1
keep if state=="01" | state=="05" | state=="10" ///
| state=="19" | state=="25" | state=="26" | state=="28" ///
| state=="02" | state=="03" | state=="08" | state=="18" ///
| state=="14" | state=="24" | state=="32" | state=="06" | state=="11"

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
*========================================================================*
/* Callaway and SantAnna (2021) */
destring geo, replace
destring id, replace
gen fist_cohort=0
/*
replace fist_cohort=1990 if state=="01"
replace fist_cohort=1988 if state=="05"
replace fist_cohort=1991 if state=="10"
replace fist_cohort=1987 if state=="19"
replace fist_cohort=1993 if state=="25"
replace fist_cohort=1993 if state=="26"
replace fist_cohort=1990 if state=="28"
*/
replace fist_cohort=1990 if state=="01" & engl==1
replace fist_cohort=1988 if state=="05" & engl==1
replace fist_cohort=1991 if state=="10" & engl==1
replace fist_cohort=1987 if state=="19" & engl==1
replace fist_cohort=1993 if state=="25" & engl==1
replace fist_cohort=1993 if state=="26" & engl==1
replace fist_cohort=1990 if state=="28" & engl==1

foreach x in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23{
gen educ`x'=edu==`x'
}

csdid paidw female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) vce(cluster geo)
estat all
/*csdid student female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) vce(cluster geo)
estat all*/

keep if paidw==1
csdid hrs_exp female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) vce(cluster geo)
estat all
csdid eng female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) vce(cluster geo) 
estat all
csdid lwage edu female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) vce(cluster geo)
estat all

/* Sun and Abraham (2021) */
gen tgroup=fist_cohort
replace tgroup=. if state=="02" | state=="03" | state=="08" | state=="18" ///
| state=="14" | state=="24" | state=="32" | state=="06" | state=="11"
gen cgroup=tgroup==.

eventstudyinteract hrs_exp had_policy if paidw==1 [aw=weight], absorb(geo cohort) ///
cohort(tgroup) control_cohort(cgroup) covariates(i.edu female indigenous married) ///
vce(cluster geo)
eventstudyinteract eng had_policy if paidw==1 [aw=weight], absorb(geo cohort) ///
cohort(tgroup) control_cohort(cgroup) covariates(i.edu female indigenous married) ///
vce(cluster geo)
eventstudyinteract lwage had_policy if paidw==1 [aw=weight], absorb(geo cohort) ///
cohort(tgroup) control_cohort(cgroup) covariates(i.edu female indigenous married) ///
vce(cluster geo)
eventstudyinteract paidw had_policy [aw=weight], absorb(geo cohort) ///
cohort(tgroup) control_cohort(cgroup) covariates(i.edu female indigenous married) ///
vce(cluster geo)
/*eventstudyinteract student had_policy [aw=weight], absorb(geo cohort) ///
cohort(tgroup) control_cohort(cgroup) covariates(i.edu female indigenous married) ///
vce(cluster geo)*/

eststo clear
eststo: areg hrs_exp had_policy i.cohort i.edu female indigenous married ///
[aw=weight] if paidw==1, absorb(geo) vce(cluster geo)
eststo: areg eng had_policy i.cohort i.edu female indigenous married ///
[aw=weight] if paidw==1, absorb(geo) vce(cluster geo)
eststo: areg lwage had_policy i.cohort i.edu female indigenous married ///
[aw=weight] if paidw==1, absorb(geo) vce(cluster geo)
eststo: areg paidw had_policy i.cohort i.edu female indigenous married ///
[aw=weight], absorb(geo) vce(cluster geo)
/*eststo: areg student had_policy i.cohort i.edu female indigenous married ///
[aw=weight], absorb(geo) vce(cluster geo)*/
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
esttab using "$doc\tab_StaggDD.tex", cells(b(star fmt(%9.3f)) se(par)) ///
star(* 0.10 ** 0.05 *** 0.01) title(English abilities) keep(had_policy) ///
stats(N ar2, fmt(%9.0fc %9.3f)) replace

*========================================================================*
/* Callaway and SantAnna (2021) */
destring geo, replace
destring id, replace
gen fist_cohort=0
/*
replace fist_cohort=1990 if state=="01"
replace fist_cohort=1988 if state=="05"
replace fist_cohort=1991 if state=="10"
replace fist_cohort=1987 if state=="19"
replace fist_cohort=1993 if state=="25"
replace fist_cohort=1993 if state=="26"
replace fist_cohort=1990 if state=="28"
*/
replace fist_cohort=1990 if state=="01" & engl==1
replace fist_cohort=1988 if state=="05" & engl==1
replace fist_cohort=1991 if state=="10" & engl==1
replace fist_cohort=1987 if state=="19" & engl==1
replace fist_cohort=1993 if state=="25" & engl==1
replace fist_cohort=1993 if state=="26" & engl==1
replace fist_cohort=1990 if state=="28" & engl==1

foreach x in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23{
gen educ`x'=edu==`x'
}

csdid paidw female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) vce(cluster geo)
estat all
/*csdid student female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) vce(cluster geo)
estat all*/

keep if paidw==1
csdid hrs_exp female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) vce(cluster geo)
estat all
csdid eng female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) vce(cluster geo) 
estat all
csdid lwage edu female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) vce(cluster geo)
estat all

/* Sun and Abraham (2021) */
gen tgroup=fist_cohort
replace tgroup=. if state=="02" | state=="03" | state=="08" | state=="18" ///
| state=="14" | state=="24" | state=="32" | state=="06" | state=="11"
gen cgroup=tgroup==.

eventstudyinteract hrs_exp had_policy if paidw==1 [aw=weight], absorb(geo cohort) ///
cohort(tgroup) control_cohort(cgroup) covariates(i.edu female indigenous married) ///
vce(cluster geo)
eventstudyinteract eng had_policy if paidw==1 [aw=weight], absorb(geo cohort) ///
cohort(tgroup) control_cohort(cgroup) covariates(i.edu female indigenous married) ///
vce(cluster geo)
eventstudyinteract lwage had_policy if paidw==1 [aw=weight], absorb(geo cohort) ///
cohort(tgroup) control_cohort(cgroup) covariates(i.edu female indigenous married) ///
vce(cluster geo)
eventstudyinteract paidw had_policy [aw=weight], absorb(geo cohort) ///
cohort(tgroup) control_cohort(cgroup) covariates(i.edu female indigenous married) ///
vce(cluster geo)
/*eventstudyinteract student had_policy [aw=weight], absorb(geo cohort) ///
cohort(tgroup) control_cohort(cgroup) covariates(i.edu female indigenous married) ///
vce(cluster geo)*/

eststo clear
eststo: areg hrs_exp had_policy i.cohort i.edu female indigenous married ///
[aw=weight] if paidw==1, absorb(geo) vce(cluster geo)
eststo: areg eng had_policy i.cohort i.edu female indigenous married ///
[aw=weight] if paidw==1, absorb(geo) vce(cluster geo)
eststo: areg lwage had_policy i.cohort i.edu female indigenous married ///
[aw=weight] if paidw==1, absorb(geo) vce(cluster geo)
eststo: areg paidw had_policy i.cohort i.edu female indigenous married ///
[aw=weight], absorb(geo) vce(cluster geo)
/*eststo: areg student had_policy i.cohort i.edu female indigenous married ///
[aw=weight], absorb(geo) vce(cluster geo)*/
esttab using "$doc\tab_StaggDD.tex", cells(b(star fmt(%9.3f)) se(par)) ///
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
drop if state=="01" & had_policy==0
drop if state=="05" & had_policy==0
drop if state=="10" & had_policy==0
drop if state=="19" & had_policy==0
drop if state=="25" & had_policy==0
drop if state=="26" & had_policy==0
drop if state=="28" & had_policy==0
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
esttab using "$doc\tab_StaggDD.tex", cells(b(star fmt(%9.3f)) se(par)) ///
star(* 0.10 ** 0.05 *** 0.01) title(English abilities) keep(had_policy) ///
stats(N ar2, fmt(%9.0fc %9.3f)) replace

*========================================================================*
/* Callaway and SantAnna (2021) */
destring geo, replace
destring id, replace
gen fist_cohort=0
/*
replace fist_cohort=1990 if state=="01"
replace fist_cohort=1988 if state=="05"
replace fist_cohort=1991 if state=="10"
replace fist_cohort=1987 if state=="19"
replace fist_cohort=1993 if state=="25"
replace fist_cohort=1993 if state=="26"
replace fist_cohort=1990 if state=="28"
*/
replace fist_cohort=1990 if state=="01" & engl==1
replace fist_cohort=1988 if state=="05" & engl==1
replace fist_cohort=1991 if state=="10" & engl==1
replace fist_cohort=1987 if state=="19" & engl==1
replace fist_cohort=1993 if state=="25" & engl==1
replace fist_cohort=1993 if state=="26" & engl==1
replace fist_cohort=1990 if state=="28" & engl==1

foreach x in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23{
gen educ`x'=edu==`x'
}

csdid paidw female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) vce(cluster geo)
estat all
/*csdid student female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) vce(cluster geo)
estat all*/

keep if paidw==1
csdid hrs_exp female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) vce(cluster geo)
estat all
csdid eng female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) vce(cluster geo) 
estat all
csdid lwage edu female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) vce(cluster geo)
estat all

/* Sun and Abraham (2021) */
gen tgroup=fist_cohort
replace tgroup=. if state=="02" | state=="03" | state=="08" | state=="18" ///
| state=="14" | state=="24" | state=="32" | state=="06" | state=="11"
gen cgroup=tgroup==.

eventstudyinteract hrs_exp had_policy if paidw==1 [aw=weight], absorb(geo cohort) ///
cohort(tgroup) control_cohort(cgroup) covariates(i.edu female indigenous married) ///
vce(cluster geo)
eventstudyinteract eng had_policy if paidw==1 [aw=weight], absorb(geo cohort) ///
cohort(tgroup) control_cohort(cgroup) covariates(i.edu female indigenous married) ///
vce(cluster geo)
eventstudyinteract lwage had_policy if paidw==1 [aw=weight], absorb(geo cohort) ///
cohort(tgroup) control_cohort(cgroup) covariates(i.edu female indigenous married) ///
vce(cluster geo)
eventstudyinteract paidw had_policy [aw=weight], absorb(geo cohort) ///
cohort(tgroup) control_cohort(cgroup) covariates(i.edu female indigenous married) ///
vce(cluster geo)
/*eventstudyinteract student had_policy [aw=weight], absorb(geo cohort) ///
cohort(tgroup) control_cohort(cgroup) covariates(i.edu female indigenous married) ///
vce(cluster geo)*/

eststo clear
eststo: areg hrs_exp had_policy i.cohort i.edu female indigenous married ///
[aw=weight] if paidw==1, absorb(geo) vce(cluster geo)
eststo: areg eng had_policy i.cohort i.edu female indigenous married ///
[aw=weight] if paidw==1, absorb(geo) vce(cluster geo)
eststo: areg lwage had_policy i.cohort i.edu female indigenous married ///
[aw=weight] if paidw==1, absorb(geo) vce(cluster geo)
eststo: areg paidw had_policy i.cohort i.edu female indigenous married ///
[aw=weight], absorb(geo) vce(cluster geo)
/*eststo: areg student had_policy i.cohort i.edu female indigenous married ///
[aw=weight], absorb(geo) vce(cluster geo)*/
esttab using "$doc\tab_StaggDD.tex", cells(b(star fmt(%9.3f)) se(par)) ///
star(* 0.10 ** 0.05 *** 0.01) title(English abilities) keep(had_policy) ///
stats(N ar2, fmt(%9.0fc %9.3f)) replace
