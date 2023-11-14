*========================================================================*
/* English skills and labor market outcomes in Mexico */
*========================================================================*
/* Author: Oscar Galvez-Soriano */
*========================================================================*
clear
set more off
gl data= "https://raw.githubusercontent.com/galvez-soriano/Papers/main/ReturnsEng/Data"
gl base= "C:\Users\rdeangelis\OneDrive - The University of Chicago"
gl doc= "C:\Users\rdeangelis\OneDrive - The University of Chicago"
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

/* Locality by cohort variation */
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

*========================================================================*

/* Callaway and SantAnna (2021) */
destring geo, replace
destring id, replace

gen engl=hrs_exp>=0.1
gen first_cohort=0
gen min_cohort =.

replace min_cohort = 1990 if state == "01"
replace min_cohort = 1988 if state == "05"
replace min_cohort = 1991 if state == "10"
replace min_cohort = 1987 if state == "19"
replace min_cohort = 1993 if state == "25"
replace min_cohort = 1993 if state == "26"
replace min_cohort = 1990 if state == "28"

bysort geo: egen min_locality_cohort = min(cohort) if engl == 1 & cohort >= min_cohort ///
& (state=="01" | state=="05" | state=="10" | state=="19" | state=="25" ///
| state=="26" | state=="28")

replace first_cohort = max(min_locality_cohort, min_cohort)

keep if cohort>=1975 & cohort<=1996

foreach x in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23{
gen educ`x' = edu == `x'
}

csdid paidw female indigenous married educ* [iw = weight], time(cohort) gvar(first_cohort) method(dripw) wboot vce(cluster geo)
estat all

keep if paidw==1

csdid hrs_exp female indigenous married educ* [iw = weight], time(cohort) gvar(first_cohort) method(dripw) wboot vce(cluster geo)
estat all

csdid eng female indigenous married educ* [iw = weight], time(cohort) gvar(first_cohort) method(dripw) wboot vce(cluster geo)
estat all

csdid lwage female indigenous married educ* [iw = weight], time(cohort) gvar(first_cohort) method(dripw) wboot vce(cluster geo)
estat all

*========================================================================*

/* Sun and Abraham (2021) */
replace first_cohort = 1990 if state == "01"
replace first_cohort = 1988 if state == "05"
replace first_cohort = 1991 if state == "10"
replace first_cohort = 1987 if state == "19"
replace first_cohort = 1993 if state == "25"
replace first_cohort = 1993 if state == "26"
replace first_cohort = 1990 if state == "28"

gen tgroup = first_cohort
replace tgroup=. if state=="02" | state=="03" | state=="08" | state=="18" | state=="14" | state=="24" | state=="32" | state=="06" | state=="11"
gen cgroup = tgroup ==.

eventstudyinteract hrs_exp had_policy if paidw == 1 [aw = weight], absorb(geo cohort) ///
cohort(tgroup) control_cohort(cgroup) covariates(i.edu female indigenous married) vce(cluster geo)

eventstudyinteract eng had_policy if paidw == 1 [aw = weight], absorb(geo cohort) ///
cohort(tgroup) control_cohort(cgroup) covariates(i.edu female indigenous married) vce(cluster geo)

eventstudyinteract lwage had_policy if paidw == 1 [aw = weight], absorb(geo cohort) ///
cohort(tgroup) control_cohort(cgroup) covariates(i.edu female indigenous married) vce(cluster geo)

eventstudyinteract paidw had_policy [aw = weight], absorb(geo cohort) ///
cohort(tgroup) control_cohort(cgroup) covariates(i.edu female indigenous married) vce(cluster geo)

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

*========================================================================*

/* Excluding localities with no exposure in treatment states  */
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

/* Enrollment as a mechanism? */
use "$data/eng_abil.dta", clear
grstyle init
grstyle set plain, horizontal
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

merge m:1 age using "$data/cumm_enroll_15.dta", nogen

quietly areg stud had_policy i.cohort i.edu female indigenous married ///
[aw=weight] if age<=22, absorb(geo) vce(cluster geo)
estimates store age22
quietly areg stud had_policy i.cohort i.edu female indigenous married ///
[aw=weight] if age<=23, absorb(geo) vce(cluster geo)
estimates store age23
quietly areg stud had_policy i.cohort i.edu female indigenous married ///
[aw=weight] if age<=24, absorb(geo) vce(cluster geo)
estimates store age24
quietly areg stud had_policy i.cohort i.edu female indigenous married ///
[aw=weight] if age<=25, absorb(geo) vce(cluster geo)
estimates store age25
quietly areg stud had_policy i.cohort i.edu female indigenous married ///
[aw=weight] if age<=26, absorb(geo) vce(cluster geo)
estimates store age26
quietly areg stud had_policy i.cohort i.edu female indigenous married ///
[aw=weight] if age<=27, absorb(geo) vce(cluster geo)
estimates store age27
quietly areg stud had_policy i.cohort i.edu female indigenous married ///
[aw=weight] if age<=28, absorb(geo) vce(cluster geo)
estimates store age28
quietly areg stud had_policy i.cohort i.edu female indigenous married ///
[aw=weight] if age<=29, absorb(geo) vce(cluster geo)
estimates store age29
quietly areg stud had_policy i.cohort i.edu female indigenous married ///
[aw=weight] if age<=30, absorb(geo) vce(cluster geo)
estimates store age30
quietly areg stud had_policy i.cohort i.edu female indigenous married ///
[aw=weight], absorb(geo) vce(cluster geo)
estimates store age_all

label var had_policy " "

coefplot ///
age22 age23 age24 age25 age26 age27 age28 age29 age30, ///
keep(had_policy) xline(0, lstyle(grid) lpattern(dash) lcolor(black)) ///
xtitle("Likelihood of being enrolled in school", size(medium) height(5)) ///
xlabel(-.1(0.1).3, labs(medium) format(%5.2f)) scheme(s2mono) ///
legend( pos(5) ring(0) col(1) region(lcolor(white)) size(medium)) ///
graphregion(color(white)) ciopts(recast(rcap)) levels(95) legend(off)
graph save "$doc\graphSDDenroll",replace
graph export "$doc\graphSDDenroll.png", replace

graph hbar (mean) enroll if age>=22 & age<=30, over(age) scheme(s2mono) ///
graphregion(color(white)) ytitle("School enrollment", size(medium) height(5)) ///
ylabel(0(0.1).3, labs(medium) format(%5.2f) nogrid)
graph save "$doc\graph_enroll",replace
graph export "$doc\graph_enroll.png", replace

graph combine "$doc\graphSDDenroll" "$doc\graph_enroll", ///
graphregion(color(white) margin()) cols(2) imargin(1 1.2 1.2 1) scale(0.9)
graph export "$doc\fig_edu_enroll.png", replace

*========================================================================*
/* APPENDIX */
*========================================================================*
/* FIGURE A.5. Pre-trends test pooling all states (SDD estimate) */
*========================================================================*
use "$data/eng_abil.dta", clear
keep if biare==1
gen engl=hrs_exp>=0.1
keep if state=="01" | state=="05" | state=="10" ///
| state=="19" | state=="25" | state=="26" | state=="28" ///
| state=="02" | state=="03" | state=="08" | state=="18" ///
| state=="14" | state=="24" | state=="32" | state=="06" | state=="11"

gen had_policy=0 
replace had_policy=1 if state=="01" & (cohort>=1990 & cohort<=1995) & engl==1
replace had_policy=1 if state=="05" & (cohort>=1988 & cohort<=1996) & engl==1
replace had_policy=1 if state=="10" & (cohort>=1991 & cohort<=1996) & engl==1
replace had_policy=1 if state=="19" & (cohort>=1987 & cohort<=1996) & engl==1
replace had_policy=1 if state=="25" & (cohort>=1993 & cohort<=1996) & engl==1
replace had_policy=1 if state=="26" & (cohort>=1993 & cohort<=1996) & engl==1
replace had_policy=1 if state=="28" & (cohort>=1990 & cohort<=1996) & engl==1
keep if cohort>=1975 & cohort<=1996

/*destring state, replace
gen state_cohort=state*cohort

eststo clear
eststo: areg hrs_exp had_policy i.cohort i.edu female indigenous married i.state_cohort ///
[aw=weight]  if paidw==1, absorb(geo) vce(cluster geo)
eststo: areg eng had_policy i.cohort i.edu female indigenous married i.state_cohort ///
[aw=weight]  if paidw==1, absorb(geo) vce(cluster geo)
eststo: areg paidw had_policy i.cohort i.edu female indigenous married i.state_cohort ///
[aw=weight], absorb(geo) vce(cluster geo)
eststo: areg lwage had_policy i.cohort i.edu female indigenous married i.state_cohort ///
[aw=weight]  if paidw==1, absorb(geo) vce(cluster geo)*/
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<=================================================================== I modified this part!!!
gen treat2=cohort==1980 & engl==1 & state=="05"
gen treat3=cohort==1981 & engl==1 & state=="05"
gen treat4=cohort==1981 & engl==1 & state=="19"
gen treat5=cohort==1982 & engl==1 & state=="19"
gen treat6=cohort==1983 & engl==1 & state=="19"
gen treat7=cohort==1984 & engl==1 & state=="19"
gen treat8=cohort==1985 & engl==1 & state=="19"
gen treat9=cohort==1986 & engl==1 & state=="19"
gen treat10=cohort==1987 & engl==1 & state=="19"
gen treat11=cohort==1988 & engl==1 & state=="19"
gen treat12=cohort==1989 & engl==1 & state=="19"
gen treat13=cohort==1990 & engl==1 & state=="19"
gen treat14=cohort==1991 & engl==1 & state=="19"
gen treat15=cohort==1992 & engl==1 & state=="19"
gen treat16=cohort==1993 & engl==1 & state=="19"
gen treat17=cohort==1994 & engl==1 & state=="19"
gen treat18=cohort==1995 & engl==1 & state=="19"
*gen treat19=cohort==1996 & state=="19"

replace treat6=1 if cohort==1986 & engl==1 & state=="01"
replace treat7=1 if cohort==1987 & engl==1 & state=="01"
replace treat8=1 if cohort==1988 & engl==1 & state=="01"
replace treat9=1 if cohort==1989 & engl==1 & state=="01"
replace treat10=1 if cohort==1990 & engl==1 & state=="01"
replace treat11=1 if cohort==1991 & engl==1 & state=="01"
replace treat12=1 if cohort==1992 & engl==1 & state=="01"
replace treat13=1 if cohort==1993 & engl==1 & state=="01"
replace treat14=1 if cohort==1994 & engl==1 & state=="01"
replace treat15=1 if cohort==1995 & engl==1 & state=="01"
replace treat16=1 if cohort==1996 & engl==1 & state=="01"

replace treat4=1 if cohort==1982 & engl==1 & state=="05"
replace treat5=1 if cohort==1983 & engl==1 & state=="05"
replace treat6=1 if cohort==1984 & engl==1 & state=="05"
replace treat7=1 if cohort==1985 & engl==1 & state=="05"
replace treat8=1 if cohort==1986 & engl==1 & state=="05"
replace treat9=1 if cohort==1987 & engl==1 & state=="05"
replace treat10=1 if cohort==1988 & engl==1 & state=="05"
replace treat11=1 if cohort==1989 & engl==1 & state=="05"
replace treat12=1 if cohort==1990 & engl==1 & state=="05"
replace treat13=1 if cohort==1991 & engl==1 & state=="05"
replace treat14=1 if cohort==1992 & engl==1 & state=="05"
replace treat15=1 if cohort==1993 & engl==1 & state=="05"
replace treat16=1 if cohort==1994 & engl==1 & state=="05"
replace treat17=1 if cohort==1995 & engl==1 & state=="05"
replace treat18=1 if cohort==1996 & engl==1 & state=="05"

replace treat4=1 if cohort==1985 & engl==1 & state=="10"
replace treat5=1 if cohort==1986 & engl==1 & state=="10"
replace treat6=1 if cohort==1987 & engl==1 & state=="10"
replace treat7=1 if cohort==1988 & engl==1 & state=="10"
replace treat8=1 if cohort==1989 & engl==1 & state=="10"
replace treat9=1 if cohort==1990 & engl==1 & state=="10"
replace treat10=1 if cohort==1991 & engl==1 & state=="10"
replace treat11=1 if cohort==1992 & engl==1 & state=="10"
replace treat12=1 if cohort==1993 & engl==1 & state=="10"
replace treat13=1 if cohort==1994 & engl==1 & state=="10"
replace treat14=1 if cohort==1995 & engl==1 & state=="10"
replace treat15=1 if cohort==1996 & engl==1 & state=="10"

replace treat6=1 if cohort==1989 & engl==1 & state=="25"
replace treat7=1 if cohort==1990 & engl==1 & state=="25"
replace treat8=1 if cohort==1991 & engl==1 & state=="25"
replace treat9=1 if cohort==1992 & engl==1 & state=="25"
replace treat10=1 if cohort==1993 & engl==1 & state=="25"
replace treat11=1 if cohort==1994 & engl==1 & state=="25"
replace treat12=1 if cohort==1995 & engl==1 & state=="25"
replace treat13=1 if cohort==1996 & engl==1 & state=="25"

*replace treat7=1 if cohort==1990 & state=="26"
replace treat8=1 if cohort==1991 & engl==1 & state=="26"
replace treat9=1 if cohort==1992 & engl==1 & state=="26"
replace treat10=1 if cohort==1993 & engl==1 & state=="26"
replace treat11=1 if cohort==1994 & engl==1 & state=="26"
replace treat12=1 if cohort==1995 & engl==1 & state=="26"
replace treat13=1 if cohort==1996 & engl==1 & state=="26"

replace treat3=1 if cohort==1983 & engl==1 & state=="28"
replace treat4=1 if cohort==1984 & engl==1 & state=="28"
replace treat5=1 if cohort==1985 & engl==1 & state=="28"
replace treat6=1 if cohort==1986 & engl==1 & state=="28"
replace treat7=1 if cohort==1987 & engl==1 & state=="28"
replace treat8=1 if cohort==1988 & engl==1 & state=="28"
replace treat9=1 if cohort==1989 & engl==1 & state=="28"
replace treat10=1 if cohort==1990 & engl==1 & state=="28"
replace treat11=1 if cohort==1991 & engl==1 & state=="28"
replace treat12=1 if cohort==1992 & engl==1 & state=="28"
replace treat13=1 if cohort==1993 & engl==1 & state=="28"
replace treat14=1 if cohort==1994 & engl==1 & state=="28"
replace treat15=1 if cohort==1995 & engl==1 & state=="28"
replace treat16=1 if cohort==1996 & engl==1 & state=="28"

replace treat9=0

label var treat2 "-8"
label var treat3 "-7"
label var treat4 "-6"
label var treat5 "-5"
label var treat6 "-4"
label var treat7 "-3"
label var treat8 "-2"
label var treat9 "-1"
foreach x in 0 1 2 3 4 5 6 7 8 {
	label var treat1`x' "`x'"
}
/* Panel (a) Hours of English */
areg hrs_exp treat* i.cohort cohort i.edu female indigenous married ///
[aw=weight] if cohort>=1980 & cohort<=1995 & paidw==1, absorb(geo) vce(cluster geo)
coefplot, vertical keep(treat*) yline(0) omitted baselevels ///
xline(9, lstyle(grid) lpattern(dash) lcolor(ltblue)) ///
ytitle("Weekly hours of English instruction", size(medium) height(5)) ///
ylabel(-0.5(0.25)1.25, labs(medium) grid format(%5.2f)) ///
xtitle("Cohorts since policy intervention", size(medium) height(5)) ///
xlabel(, angle(vertical) labs(medium)) ///
graphregion(color(white)) scheme(s2mono) ciopts(recast(rcap)) ///
ysc(r(-0.5 1.25)) recast(connected)
graph export "$doc\PTA_StaggDD1.png", replace
/* Panel (b) Speak English */
areg eng treat* i.cohort cohort i.edu female indigenous married ///
[aw=weight] if cohort>=1980 & cohort<=1996 & paidw==1, absorb(geo) vce(cluster geo)
coefplot, vertical keep(treat*) yline(0) omitted baselevels ///
xline(9, lstyle(grid) lpattern(dash) lcolor(ltblue)) ///
ytitle("Likelihood of having English speaking abilities", size(medium) height(5)) ///
ylabel(-0.5(0.25)0.5, labs(medium) grid format(%5.2f)) ///
xtitle("Cohorts since policy intervention", size(medium) height(5)) ///
xlabel(, angle(vertical) labs(medium)) ///
graphregion(color(white)) scheme(s2mono) ciopts(recast(rcap)) ///
ysc(r(-0.5 0.5)) recast(connected)
graph export "$doc\PTA_StaggDD2.png", replace
/* Panel (c) Paid work */
areg paidw treat* i.cohort cohort i.edu female indigenous married ///
[aw=weight] if cohort>=1980 & cohort<=1996, absorb(geo) vce(cluster geo)
coefplot, vertical keep(treat*) yline(0) omitted baselevels ///
xline(9, lstyle(grid) lpattern(dash) lcolor(ltblue)) ///
ytitle("Likelihood working for pay", size(medium) height(5)) ///
ylabel(-0.5(0.25)0.5, labs(medium) grid format(%5.2f)) ///
xtitle("Cohorts since policy intervention", size(medium) height(5)) ///
xlabel(, angle(vertical) labs(medium)) ///
graphregion(color(white)) scheme(s2mono) ciopts(recast(rcap)) ///
ysc(r(-0.5 0.5)) recast(connected)
graph export "$doc\PTA_StaggDD3.png", replace
/* Panel (d) Ln(wage) */
areg lwage treat* i.cohort i.edu female indigenous married ///
[aw=weight] if cohort>=1980 & cohort<=1996 & paidw==1, absorb(geo) vce(cluster geo)
coefplot, vertical keep(treat*) yline(0) omitted baselevels ///
xline(9, lstyle(grid) lpattern(dash) lcolor(ltblue)) ///
ytitle("Percentage change of wages (/100)", size(medium) height(5)) ///
ylabel(-2(1)2, labs(medium) grid format(%5.2f)) ///
xtitle("Cohorts since policy intervention", size(medium) height(5)) ///
xlabel(, angle(vertical) labs(medium)) ///
graphregion(color(white)) scheme(s2mono) ciopts(recast(rcap)) ///
ysc(r(-2 2)) recast(connected)
graph export "$doc\PTA_StaggDD4.png", replace
/* Panel not shown: School enrollment */
areg student treat* i.cohort i.edu female indigenous married ///
[aw=weight] if cohort>=1980 & cohort<=1996, absorb(geo) vce(cluster geo)
coefplot, vertical keep(treat*) yline(0) omitted baselevels ///
xline(9, lstyle(grid) lpattern(dash) lcolor(ltblue)) ///
ytitle("Likelihood of being enrolled in school", size(medium) height(5)) ///
ylabel(-.5(.25).5, labs(medium) grid format(%5.2f)) ///
xtitle("Cohorts since policy intervention", size(medium) height(5)) ///
xlabel(, angle(vertical) labs(medium)) ///
graphregion(color(white)) scheme(s2mono) ciopts(recast(rcap)) ///
ysc(r(-.5 .5)) recast(connected)
graph export "$doc\PTA_StaggDD5.png", replace
