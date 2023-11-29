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
/* FIGURE 5: Effect of English instruction on occupational decisions */
*========================================================================*
use "$data/eng_abil.dta", clear
keep if biare==1
replace hrs_exp=hrs_exp/2 if state=="19" & cohort<1987
replace hrs_exp=hrs_exp/2 if state=="01" & cohort<1990
drop if state=="05" | state=="17"
gen engl=hrs_exp>=0.1

gen had_policy=0 
replace had_policy=1 if state=="01" & (cohort>=1990 & cohort<=1996)
replace had_policy=1 if state=="10" & (cohort>=1991 & cohort<=1996)
replace had_policy=1 if state=="19" & (cohort>=1987 & cohort<=1996)
replace had_policy=1 if state=="25" & (cohort>=1993 & cohort<=1996)
replace had_policy=1 if state=="26" & (cohort>=1993 & cohort<=1996)
replace had_policy=1 if state=="28" & (cohort>=1990 & cohort<=1996)
keep if cohort>=1981 & cohort<=1996

destring geo, replace
gen fist_cohort=0
replace fist_cohort=1990 if state=="01" & engl==1
replace fist_cohort=1991 if state=="10" & engl==1
replace fist_cohort=1987 if state=="19" & engl==1
replace fist_cohort=1993 if state=="25" & engl==1
replace fist_cohort=1993 if state=="26" & engl==1
replace fist_cohort=1990 if state=="28" & engl==1

foreach x in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23{
gen educ`x'=edu==`x'
}

destring sinco, replace
gen occup=.
replace occup=1 if (sinco>6101 & sinco<=6131) | (sinco>6201 & sinco<=6231) ///
| sinco==6999
replace occup=2 if (sinco>=9111 & sinco<=9899) 
replace occup=3 if sinco==6311 | (sinco>=8111 & sinco<=8199) | (sinco>=8211 ///
& sinco<=8212) | (sinco>=8311 & sinco<=8999)
replace occup=4 if (sinco>=7111 & sinco<=7135) | (sinco>=7211 & sinco<=7223) ///
| (sinco>=7311 & sinco<=7353) | (sinco>=7411 & sinco<=7412) | (sinco>=7511 & ///
sinco<=7517) | (sinco>=7611 & sinco<=7999)
replace occup=5 if (sinco>=5111 & sinco<=5116) | (sinco>=5211 & sinco<=5254) ///
| (sinco>=5311 & sinco<=5314) | (sinco>=5411 & sinco<=5999)
replace occup=6 if sinco==4111 | (sinco>=4211 & sinco<=4999)
replace occup=7 if (sinco>=3111 & sinco<=3142) | (sinco>=3211 & sinco<=3999)
replace occup=8 if (sinco>=2111 & sinco<=2625) | (sinco>=2631 & sinco<=2639) ///
| (sinco>=2641 & sinco<=2992)
replace occup=9 if (sinco>=1111 & sinco<=1999) | sinco==2630 ///
| sinco==2630 | sinco==2640 | sinco==3101 | sinco==3201 | sinco==4201 ///
| sinco==5101 | sinco==5201 | sinco==5301 | sinco==5401 | sinco==6101 ///
| sinco==6201 | sinco==7101 | sinco==7201 | sinco==7301 | sinco==7401 ///
| sinco==7501 | sinco==7601 | sinco==8101 | sinco==8201 | sinco==8301
replace occup=10 if sinco==980

label define occup 1 "Farming" 2 "Elementary occupations" 3 "Machine operators" ///
4 "Crafts" 5 "Customer service" 6 "Sales" 7 "Clerical support" ///
8 "Professionals/Technicians" 9 "Managerial" 10 "Abroad" 
label values occup occup

gen farm=occup==1
gen elem=occup==2
gen mach=occup==3
gen craf=occup==4
gen cust=occup==5
gen sale=occup==6
gen cler=occup==7
gen prof=occup==8
gen mana=occup==9
gen abro=occup==10

keep if paidw==1

quietly csdid farm female rural indigenous married educ* [iw=weight], ///
time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat simple, [estore(farm)]
snapshot save, label(snapshot1)
keep if edu<=9
quietly csdid farm female rural indigenous married educ* [iw=weight], ///
time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat simple, [estore(farm_low)]
snapshot restore 1
snapshot save, label(snapshot1)
keep if edu>9
quietly csdid farm female rural indigenous married educ* [iw=weight], ///
time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat simple, [estore(farm_high)]
snapshot restore 1

quietly csdid elem female rural indigenous married educ* [iw=weight], ///
time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat simple, [estore(elem)]
snapshot save, label(snapshot1)
keep if edu<=9
quietly csdid elem female rural indigenous married educ* [iw=weight], ///
time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat simple, [estore(elem_low)]
snapshot restore 1
snapshot save, label(snapshot1)
keep if edu>9
quietly csdid elem female rural indigenous married educ* [iw=weight], ///
time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat simple, [estore(elem_high)]
snapshot restore 1

quietly csdid mach female rural indigenous married educ* [iw=weight], ///
time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat simple, [estore(mach)]
snapshot save, label(snapshot1)
keep if edu<=9
quietly csdid mach female rural indigenous married educ* [iw=weight], ///
time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat simple, [estore(mach_low)]
snapshot restore 1
snapshot save, label(snapshot1)
keep if edu>9
quietly csdid mach female rural indigenous married educ* [iw=weight], ///
time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat simple, [estore(mach_high)]
snapshot restore 1

quietly csdid craf female rural indigenous married educ* [iw=weight], ///
time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat simple, [estore(craf)]
snapshot save, label(snapshot1)
keep if edu<=9
quietly csdid craf female rural indigenous married educ* [iw=weight], ///
time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat simple, [estore(craf_low)]
snapshot restore 1
snapshot save, label(snapshot1)
keep if edu>9
quietly csdid craf female rural indigenous married educ* [iw=weight], ///
time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat simple, [estore(craf_high)]
snapshot restore 1

quietly csdid cust female rural indigenous married educ* [iw=weight], ///
time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat simple, [estore(cust)]
snapshot save, label(snapshot1)
keep if edu<=9
quietly csdid cust female rural indigenous married educ* [iw=weight], ///
time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat simple, [estore(cust_low)]
snapshot restore 1
snapshot save, label(snapshot1)
keep if edu>9
quietly csdid cust female rural indigenous married educ* [iw=weight], ///
time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat simple, [estore(cust_high)]
snapshot restore 1

quietly csdid sale female rural indigenous married educ* [iw=weight], ///
time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat simple, [estore(sale)]
snapshot save, label(snapshot1)
keep if edu<=9
quietly csdid sale female rural indigenous married educ* [iw=weight], ///
time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat simple, [estore(sale_low)]
snapshot restore 1
snapshot save, label(snapshot1)
keep if edu>9
quietly csdid sale female rural indigenous married educ* [iw=weight], ///
time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat simple, [estore(sale_high)]
snapshot restore 1

quietly csdid cler female rural indigenous married educ* [iw=weight], ///
time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat simple, [estore(cler)]
snapshot save, label(snapshot1)
keep if edu<=9
quietly csdid cler female rural indigenous married educ* [iw=weight], ///
time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat simple, [estore(cler_low)]
snapshot restore 1
snapshot save, label(snapshot1)
keep if edu>9
quietly csdid cler female rural indigenous married educ* [iw=weight], ///
time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat simple, [estore(cler_high)]
snapshot restore 1

quietly csdid prof female rural indigenous married educ* [iw=weight], ///
time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat simple, [estore(prof)]
snapshot save, label(snapshot1)
keep if edu<=9
quietly csdid prof female rural indigenous married educ* [iw=weight], ///
time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat simple, [estore(prof_low)]
snapshot restore 1
snapshot save, label(snapshot1)
keep if edu>9
quietly csdid prof female rural indigenous married educ* [iw=weight], ///
time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat simple, [estore(prof_high)]
snapshot restore 1

quietly csdid mana female rural indigenous married educ* [iw=weight], ///
time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat simple, [estore(mana)]
snapshot save, label(snapshot1)
keep if edu<=9
quietly csdid mana female rural indigenous married educ* [iw=weight], ///
time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat simple, [estore(mana_low)]
snapshot restore 1
snapshot save, label(snapshot1)
keep if edu>9
quietly csdid mana female rural indigenous married educ* [iw=weight], ///
time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat simple, [estore(mana_high)]
snapshot restore 1

quietly csdid abro female rural indigenous married educ* [iw=weight], ///
time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat simple, [estore(abro)]
snapshot save, label(snapshot1)
keep if edu<=9
quietly csdid abro female rural indigenous married educ* [iw=weight], ///
time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat simple, [estore(abro_low)]
snapshot restore 1
snapshot save, label(snapshot1)
keep if edu>9
quietly csdid abro female rural indigenous married educ* [iw=weight], ///
time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat simple, [estore(abro_high)]
snapshot restore 1

label var had_policy " "
/* Panel (a) Farming */
coefplot ///
(farm_high, label(High-education) msymbol(S) mcolor(blue) ciopt(lc(blue) recast(rcap))) ///
(farm, label(Full sample) msymbol(S) mcolor(black) ciopt(lc(black) recast(rcap))) ///
(farm_low, label(Low-education) msymbol(S) mcolor(ltblue) ciopt(lc(ltblue) recast(rcap))), ///
xline(0, lstyle(grid) lpattern(dash) lcolor(black)) ///
ytitle("Likelihood of working in farming occupations", size(medium) height(5)) ///
xlabel(-.2(0.1).2, labs(medium) format(%5.2f)) ///
legend( pos(5) ring(0) col(1) region(lcolor(white)) size(medium)) ///
graphregion(color(white)) ciopts(recast(rcap)) levels(90)
graph export "$doc\graphSDDheterFarm.png", replace
/* Panel (b) Elementary */
coefplot ///
(elem_high, label(High-education) msymbol(S) mcolor(blue) ciopt(lc(blue) recast(rcap))) ///
(elem, label(Full sample) msymbol(S) mcolor(black) ciopt(lc(black) recast(rcap))) ///
(elem_low, label(Low-education) msymbol(S) mcolor(ltblue) ciopt(lc(ltblue) recast(rcap))), ///
xline(0, lstyle(grid) lpattern(dash) lcolor(black)) ///
ytitle("Likelihood of working in elementary occupations", size(medium) height(5)) ///
xlabel(-.2(0.1).2, labs(medium) format(%5.2f)) ///
legend(off) ///
graphregion(color(white)) ciopts(recast(rcap)) levels(90)
graph export "$doc\graphSDDheterElem.png", replace
/* Panel (c) Machine operator */
coefplot ///
(mach_high, label(High-education) msymbol(S) mcolor(blue) ciopt(lc(blue) recast(rcap))) ///
(mach, label(Full sample) msymbol(S) mcolor(black) ciopt(lc(black) recast(rcap))) ///
(mach_low, label(Low-education) msymbol(S) mcolor(ltblue) ciopt(lc(ltblue) recast(rcap))), ///
xline(0, lstyle(grid) lpattern(dash) lcolor(black)) ///
ytitle("Likelihood of working in machine operator occupations", size(medium) height(5)) ///
xlabel(-.2(0.1).2, labs(medium) format(%5.2f)) ///
legend(off) ///
graphregion(color(white)) ciopts(recast(rcap)) levels(90)
graph export "$doc\graphSDDheterMach.png", replace
/* Panel (d) Crafts */
coefplot ///
(craf_high, label(High-education) msymbol(S) mcolor(blue) ciopt(lc(blue) recast(rcap))) ///
(craf, label(Full sample) msymbol(S) mcolor(black) ciopt(lc(black) recast(rcap))) ///
(craf_low, label(Low-education) msymbol(S) mcolor(ltblue) ciopt(lc(ltblue) recast(rcap))), ///
xline(0, lstyle(grid) lpattern(dash) lcolor(black)) ///
ytitle("Likelihood of working in crafts occupations", size(medium) height(5)) ///
xlabel(-.2(0.1).2, labs(medium) format(%5.2f)) ///
legend(off) ///
graphregion(color(white)) ciopts(recast(rcap)) levels(90)
graph export "$doc\graphSDDheterCraft.png", replace
/* Panel (e) Customer service */
coefplot ///
(cust_high, label(High-education) msymbol(S) mcolor(blue) ciopt(lc(blue) recast(rcap))) ///
(cust, label(Full sample) msymbol(S) mcolor(black) ciopt(lc(black) recast(rcap))) ///
(cust_low, label(Low-education) msymbol(S) mcolor(ltblue) ciopt(lc(ltblue) recast(rcap))), ///
xline(0, lstyle(grid) lpattern(dash) lcolor(black)) ///
ytitle("Likelihood of working in customer service", size(medium) height(5)) ///
xlabel(-.2(0.1).2, labs(medium) format(%5.2f)) ///
legend(off) ///
graphregion(color(white)) ciopts(recast(rcap)) levels(90)
graph export "$doc\graphSDDheterCust.png", replace
/* Panel (f ) Sales */
coefplot ///
(sale_high, label(High-education) msymbol(S) mcolor(blue) ciopt(lc(blue) recast(rcap))) ///
(sale, label(Full sample) msymbol(S) mcolor(black) ciopt(lc(black) recast(rcap))) ///
(sale_low, label(Low-education) msymbol(S) mcolor(ltblue) ciopt(lc(ltblue) recast(rcap))), ///
xline(0, lstyle(grid) lpattern(dash) lcolor(black)) ///
ytitle("Likelihood of working in sales", size(medium) height(5)) ///
xlabel(-.2(0.1).2, labs(medium) format(%5.2f)) ///
legend(off) ///
graphregion(color(white)) ciopts(recast(rcap)) levels(90)
graph export "$doc\graphSDDheterSale.png", replace
/* Panel (g) Clerks */
coefplot ///
(cler_high, label(High-education) msymbol(S) mcolor(blue) ciopt(lc(blue) recast(rcap))) ///
(cler, label(Full sample) msymbol(S) mcolor(black) ciopt(lc(black) recast(rcap))) ///
(cler_low, label(Low-education) msymbol(S) mcolor(ltblue) ciopt(lc(ltblue) recast(rcap))), ///
xline(0, lstyle(grid) lpattern(dash) lcolor(black)) ///
ytitle("Likelihood of working in clerical occupations", size(medium) height(5)) ///
xlabel(-.2(0.1).2, labs(medium) format(%5.2f)) ///
legend(off) ///
graphregion(color(white)) ciopts(recast(rcap)) levels(90)
graph export "$doc\graphSDDheterCler.png", replace
/* Panel (h) Professionals */
coefplot ///
(prof_high, label(High-education) msymbol(S) mcolor(blue) ciopt(lc(blue) recast(rcap))) ///
(prof, label(Full sample) msymbol(S) mcolor(black) ciopt(lc(black) recast(rcap))) ///
(prof_low, label(Low-education) msymbol(S) mcolor(ltblue) ciopt(lc(ltblue) recast(rcap))), ///
xline(0, lstyle(grid) lpattern(dash) lcolor(black)) ///
ytitle("Likelihood of working in professional occupations", size(medium) height(5)) ///
xlabel(-.2(0.1).2, labs(medium) format(%5.2f)) ///
legend(off) ///
graphregion(color(white)) ciopts(recast(rcap)) levels(90)
graph export "$doc\graphSDDheterProf.png", replace
/* Panel (i) Managerial */
coefplot ///
(mana_high, label(High-education) msymbol(S) mcolor(blue) ciopt(lc(blue) recast(rcap))) ///
(mana, label(Full sample) msymbol(S) mcolor(black) ciopt(lc(black) recast(rcap))) ///
(mana_low, label(Low-education) msymbol(S) mcolor(ltblue) ciopt(lc(ltblue) recast(rcap))), ///
xline(0, lstyle(grid) lpattern(dash) lcolor(black)) ///
ytitle("Likelihood of working in managerial occupations", size(medium) height(5)) ///
xlabel(-.2(0.1).2, labs(medium) format(%5.2f)) ///
legend(off) ///
graphregion(color(white)) ciopts(recast(rcap)) levels(90)
graph export "$doc\graphSDDheterMana.png", replace
/* Panel (j) Abroad */
coefplot ///
(abro_high, label(High-education) msymbol(S) mcolor(blue) ciopt(lc(blue) recast(rcap))) ///
(abro, label(Full sample) msymbol(S) mcolor(black) ciopt(lc(black) recast(rcap))) ///
(abro_low, label(Low-education) msymbol(S) mcolor(ltblue) ciopt(lc(ltblue) recast(rcap))), ///
xline(0, lstyle(grid) lpattern(dash) lcolor(black)) ///
ytitle("Likelihood of working abroad", size(medium) height(5)) ///
xlabel(-.2(0.1).2, labs(medium) format(%5.2f)) ///
legend(off) ///
graphregion(color(white)) ciopts(recast(rcap)) levels(90)
graph export "$doc\graphSDDheterAbro.png", replace
*========================================================================*
/* TABLE XX. English programs and types of occupations */
*========================================================================*
use "$data/eng_abil.dta", clear
keep if biare==1
destring sinco, replace
rename sinco sinco2011
merge m:1 sinco2011 using "$data/sinco11_onet19.dta"
drop if _merge==2
drop _merge
merge m:1 o_net_code19 using "$data/onet_physical_activ.dta"
drop if _merge==2
drop _merge
merge m:1 o_net_code19 using "$data/onet_moving_objects.dta"
drop if _merge==2
drop _merge
merge m:1 o_net_code19 using "$data/onet_machines.dta"
drop if _merge==2
drop _merge
merge m:1 o_net_code19 using "$data/onet_doc_info.dta"
drop if _merge==2
drop _merge
merge m:1 o_net_code19 using "$data/onet_communicating.dta"
drop if _merge==2
drop _merge
merge m:1 o_net_code19 using "$data/onet_analyzing.dta"
drop if _merge==2
drop _merge

replace hrs_exp=hrs_exp/2 if state=="19" & cohort<1987
replace hrs_exp=hrs_exp/2 if state=="01" & cohort<1990
drop if state=="05" | state=="17"
gen engl=hrs_exp>=0.1

gen had_policy=0 
replace had_policy=1 if state=="01" & (cohort>=1990 & cohort<=1996)
replace had_policy=1 if state=="10" & (cohort>=1991 & cohort<=1996)
replace had_policy=1 if state=="19" & (cohort>=1987 & cohort<=1996)
replace had_policy=1 if state=="25" & (cohort>=1993 & cohort<=1996)
replace had_policy=1 if state=="26" & (cohort>=1993 & cohort<=1996)
replace had_policy=1 if state=="28" & (cohort>=1990 & cohort<=1996)
keep if cohort>=1981 & cohort<=1996

destring geo, replace
gen fist_cohort=0
replace fist_cohort=1990 if state=="01" & engl==1
replace fist_cohort=1991 if state=="10" & engl==1
replace fist_cohort=1987 if state=="19" & engl==1
replace fist_cohort=1993 if state=="25" & engl==1
replace fist_cohort=1993 if state=="26" & engl==1
replace fist_cohort=1990 if state=="28" & engl==1

foreach x in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23{
gen educ`x'=edu==`x'
}

gen treat2=cohort==1980 & state=="05"
gen treat3=cohort==1981 & state=="05"
gen treat4=cohort==1981 & state=="19"
gen treat5=cohort==1982 & state=="19"
gen treat6=cohort==1983 & state=="19"
gen treat7=cohort==1984 & state=="19"
gen treat8=cohort==1985 & state=="19"
gen treat9=cohort==1986 & state=="19"
gen treat10=cohort==1987 & state=="19"
gen treat11=cohort==1988 & state=="19"
gen treat12=cohort==1989 & state=="19"
gen treat13=cohort==1990 & state=="19"
gen treat14=cohort==1991 & state=="19"
gen treat15=cohort==1992 & state=="19"
gen treat16=cohort==1993 & state=="19"
gen treat17=cohort==1994 & state=="19"
gen treat18=cohort==1995 & state=="19"
*gen treat19=cohort==1996 & state=="19"

replace treat6=1 if cohort==1986 & state=="01"
replace treat7=1 if cohort==1987 & state=="01"
replace treat8=1 if cohort==1988 & state=="01"
replace treat9=1 if cohort==1989 & state=="01"
replace treat10=1 if cohort==1990 & state=="01"
replace treat11=1 if cohort==1991 & state=="01"
replace treat12=1 if cohort==1992 & state=="01"
replace treat13=1 if cohort==1993 & state=="01"
replace treat14=1 if cohort==1994 & state=="01"
replace treat15=1 if cohort==1995 & state=="01"
replace treat16=1 if cohort==1996 & state=="01"

replace treat4=1 if cohort==1982 & state=="05"
replace treat5=1 if cohort==1983 & state=="05"
replace treat6=1 if cohort==1984 & state=="05"
replace treat7=1 if cohort==1985 & state=="05"
replace treat8=1 if cohort==1986 & state=="05"
replace treat9=1 if cohort==1987 & state=="05"
replace treat10=1 if cohort==1988 & state=="05"
replace treat11=1 if cohort==1989 & state=="05"
replace treat12=1 if cohort==1990 & state=="05"
replace treat13=1 if cohort==1991 & state=="05"
replace treat14=1 if cohort==1992 & state=="05"
replace treat15=1 if cohort==1993 & state=="05"
replace treat16=1 if cohort==1994 & state=="05"
replace treat17=1 if cohort==1995 & state=="05"
replace treat18=1 if cohort==1996 & state=="05"

replace treat4=1 if cohort==1985 & state=="10"
replace treat5=1 if cohort==1986 & state=="10"
replace treat6=1 if cohort==1987 & state=="10"
replace treat7=1 if cohort==1988 & state=="10"
replace treat8=1 if cohort==1989 & state=="10"
replace treat9=1 if cohort==1990 & state=="10"
replace treat10=1 if cohort==1991 & state=="10"
replace treat11=1 if cohort==1992 & state=="10"
replace treat12=1 if cohort==1993 & state=="10"
replace treat13=1 if cohort==1994 & state=="10"
replace treat14=1 if cohort==1995 & state=="10"
replace treat15=1 if cohort==1996 & state=="10"

replace treat6=1 if cohort==1989 & state=="25"
replace treat7=1 if cohort==1990 & state=="25"
replace treat8=1 if cohort==1991 & state=="25"
replace treat9=1 if cohort==1992 & state=="25"
replace treat10=1 if cohort==1993 & state=="25"
replace treat11=1 if cohort==1994 & state=="25"
replace treat12=1 if cohort==1995 & state=="25"
replace treat13=1 if cohort==1996 & state=="25"

*replace treat7=1 if cohort==1990 & state=="26"
replace treat8=1 if cohort==1991 & state=="26"
replace treat9=1 if cohort==1992 & state=="26"
replace treat10=1 if cohort==1993 & state=="26"
replace treat11=1 if cohort==1994 & state=="26"
replace treat12=1 if cohort==1995 & state=="26"
replace treat13=1 if cohort==1996 & state=="26"

replace treat3=1 if cohort==1983 & state=="28"
replace treat4=1 if cohort==1984 & state=="28"
replace treat5=1 if cohort==1985 & state=="28"
replace treat6=1 if cohort==1986 & state=="28"
replace treat7=1 if cohort==1987 & state=="28"
replace treat8=1 if cohort==1988 & state=="28"
replace treat9=1 if cohort==1989 & state=="28"
replace treat10=1 if cohort==1990 & state=="28"
replace treat11=1 if cohort==1991 & state=="28"
replace treat12=1 if cohort==1992 & state=="28"
replace treat13=1 if cohort==1993 & state=="28"
replace treat14=1 if cohort==1994 & state=="28"
replace treat15=1 if cohort==1995 & state=="28"
replace treat16=1 if cohort==1996 & state=="28"

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

label var phy_act_s "O*NET importance score accross occupations"

histogram phy_act_s, frac graphregion(fcolor(white)) color(gs12) ///
xline(68, lstyle(grid) lpattern(dash) lcolor(red)) 
graph export "$doc\histo_occup.png", replace

gen phy_act1=phy_act_s>=75 & phy_act_s!=.

snapshot save, label(snapshot1)
keep if paidw==1
keep if edu>9
csdid phy_act1 female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat event, window(-6 8) estore(physical)
restore snapshot 1
*========================================================================*
/* XXX */
*========================================================================*
keep if paidw==1
csdid phy_act1 female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat event, window(-6 8) estore(phys)
coefplot phys, vertical yline(0) omitted baselevels ///
xline(9, lstyle(grid) lpattern(dash) lcolor(ltblue)) ///
ytitle("Likelihood of working in physically-intensive jobs", size(medium) height(5)) ///
ylabel(-.5(0.25).5, labs(medium) grid format(%5.2f)) ///
xtitle("Cohorts since policy intervention", size(medium) height(5)) ///
xlabel(, angle(vertical) labs(medium)) ///
graphregion(color(white)) scheme(s2mono) ciopts(recast(rcap)) ///
ysc(r(-0.5 .5)) recast(connected)
graph export "$doc\PTA_SDD_PhysicalOccup.png", replace


areg phy_act1 treat* i.cohort cohort i.edu female indigenous married ///
[aw=weight] if cohort>=1980 & cohort<=1995 & paidw==1, absorb(geo) vce(cluster geo)
coefplot, vertical keep(treat*) yline(0) omitted baselevels ///
xline(9, lstyle(grid) lpattern(dash) lcolor(ltblue)) ///
ytitle("Likelihood of working in physically-intensive jobs", size(medium) height(5)) ///
ylabel(-.5(0.25).5, labs(medium) grid format(%5.2f)) ///
xtitle("Cohorts since policy intervention", size(medium) height(5)) ///
xlabel(, angle(vertical) labs(medium)) ///
graphregion(color(white)) scheme(s2mono) ciopts(recast(rcap)) ///
ysc(r(-0.5 .5)) recast(connected)
graph export "$doc\PTA_SDD_PhysicalOccup.png", replace

snapshot save, label(snapshot1)
keep if edu<=9
csdid phy_act1 female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat event, window(-6 8) estore(phys_low)
restore snapshot 1

snapshot save, label(snapshot1)
keep if edu>9
csdid phy_act1 female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat event, window(-6 8) estore(phys_high)
restore snapshot 1

areg phy_act1 treat* i.cohort cohort i.edu female indigenous married ///
[aw=weight] if cohort>=1980 & cohort<=1995 & paidw==1 & edu<=9, absorb(geo) vce(cluster geo)
estimates store low
areg phy_act1 treat* i.cohort cohort i.edu female indigenous married ///
[aw=weight] if cohort>=1980 & cohort<=1995 & paidw==1 & edu>9, absorb(geo) vce(cluster geo)
estimates store high

coefplot ///
(phys_low, label("Low-education") msymbol(O) mcolor(gs14) ciopt(lc(gs14) recast(rcap))) ///
(phys_high, label("High-education") msymbol(O) mcolor(dknavy) ciopt(lc(dknavy) recast(rcap))) ///
, vertical yline(0) omitted baselevels ///
xline(9, lstyle(grid) lpattern(dash) lcolor(ltblue)) ///
ytitle("Likelihood of working in physically-demanding jobs", size(medium) height(5)) ///
ylabel(-.8(.4).8, labs(medium) grid format(%5.2f)) ///
xtitle("Cohorts since policy intervention", size(medium) height(5)) ///
xlabel(, angle(vertical) labs(medium)) ///
graphregion(color(white)) scheme(s2mono) ciopts(recast(rcap)) ///
legend( pos(8) ring(0) col(1) region(lcolor(white)) size(medium)) ///
ysc(r(-.8 .8)) levels(90) 
graph export "$doc\PTA_SDD_PhysicalOccup_Educa.png", replace

snapshot save, label(snapshot1)
keep if female==1
csdid phy_act1 female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat event, window(-6 8) estore(phys_women)
restore snapshot 1

snapshot save, label(snapshot1)
keep if female==0
csdid phy_act1 female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat event, window(-6 8) estore(phys_men)
restore snapshot 1

areg phy_act1 treat* i.cohort cohort i.edu female indigenous married ///
[aw=weight] if cohort>=1980 & cohort<=1995 & paidw==1 & female==1, absorb(geo) vce(cluster geo)
estimates store women
areg phy_act1 treat* i.cohort cohort i.edu female indigenous married ///
[aw=weight] if cohort>=1980 & cohort<=1995 & paidw==1 & female==0, absorb(geo) vce(cluster geo)
estimates store men

coefplot ///
(phys_women, label("Women") msymbol(O) mcolor(gs14) ciopt(lc(gs14) recast(rcap))) ///
(phys_men, label("Men") msymbol(O) mcolor(dknavy) ciopt(lc(dknavy) recast(rcap))) ///
, vertical yline(0) omitted baselevels ///
xline(9, lstyle(grid) lpattern(dash) lcolor(ltblue)) ///
ytitle("Likelihood of working in physically-demanding jobs", size(medium) height(5)) ///
ylabel(-.8(.4).8, labs(medium) grid format(%5.2f)) ///
xtitle("Cohorts since policy intervention", size(medium) height(5)) ///
xlabel(, angle(vertical) labs(medium)) ///
graphregion(color(white)) scheme(s2mono) ciopts(recast(rcap)) ///
legend( pos(8) ring(0) col(1) region(lcolor(white)) size(medium)) ///
ysc(r(-.8 .8)) levels(90) 
graph export "$doc\PTA_SDD_PhysicalOccup_Gender.png", replace

*========================================================================*

areg communica treat* i.cohort cohort i.edu female indigenous married ///
[aw=weight] if cohort>=1980 & cohort<=1995 & paidw==1, absorb(geo) vce(cluster geo)
coefplot, vertical keep(treat*) yline(0) omitted baselevels ///
xline(9, lstyle(grid) lpattern(dash) lcolor(ltblue)) ///
ytitle("Likelihood of working in communication-intensive jobs", size(medium) height(5)) ///
ylabel(-.5(0.25).5, labs(medium) grid format(%5.2f)) ///
xtitle("Cohorts since policy intervention", size(medium) height(5)) ///
xlabel(, angle(vertical) labs(medium)) ///
graphregion(color(white)) scheme(s2mono) ciopts(recast(rcap)) ///
ysc(r(-0.5 .5)) recast(connected)
graph export "$doc\PTA_SDD_CommunicaOccup.png", replace

areg communica treat* i.cohort cohort i.edu female indigenous married ///
[aw=weight] if cohort>=1980 & cohort<=1995 & paidw==1 & edu<=9, absorb(geo) vce(cluster geo)
estimates store low
areg communica treat* i.cohort cohort i.edu female indigenous married ///
[aw=weight] if cohort>=1980 & cohort<=1995 & paidw==1 & edu>9, absorb(geo) vce(cluster geo)
estimates store high

coefplot ///
(low, label("Low-Educational Achievement") msymbol(O) mcolor(gs14) ciopt(lc(gs14) recast(rcap))) ///
(high, label("High-Educational Achievement") msymbol(O) mcolor(dknavy) ciopt(lc(dknavy) recast(rcap))) ///
, vertical keep(treat*) yline(0) omitted baselevels ///
xline(9, lstyle(grid) lpattern(dash) lcolor(ltblue)) ///
ytitle("Likelihood of working in communication-intensive jobs", size(medium) height(5)) ///
ylabel(-.8(.4).8, labs(medium) grid format(%5.2f)) ///
xtitle("Cohorts since policy intervention", size(medium) height(5)) ///
xlabel(, angle(vertical) labs(medium)) ///
graphregion(color(white)) scheme(s2mono) ciopts(recast(rcap)) ///
legend( pos(8) ring(0) col(1) region(lcolor(white)) size(medium)) ///
ysc(r(-.8 .8)) levels(90) 
graph export "$doc\PTA_SDD_CommunicaOccup_Educa.png", replace

areg communica treat* i.cohort cohort i.edu female indigenous married ///
[aw=weight] if cohort>=1980 & cohort<=1995 & paidw==1 & female==1, absorb(geo) vce(cluster geo)
estimates store women
areg communica treat* i.cohort cohort i.edu female indigenous married ///
[aw=weight] if cohort>=1980 & cohort<=1995 & paidw==1 & female==0, absorb(geo) vce(cluster geo)
estimates store men

coefplot ///
(women, label("Women") msymbol(O) mcolor(gs14) ciopt(lc(gs14) recast(rcap))) ///
(men, label("Men") msymbol(O) mcolor(dknavy) ciopt(lc(dknavy) recast(rcap))) ///
, vertical keep(treat*) yline(0) omitted baselevels ///
xline(9, lstyle(grid) lpattern(dash) lcolor(ltblue)) ///
ytitle("Likelihood of working in communication-intensive jobs", size(medium) height(5)) ///
ylabel(-.8(.4).8, labs(medium) grid format(%5.2f)) ///
xtitle("Cohorts since policy intervention", size(medium) height(5)) ///
xlabel(, angle(vertical) labs(medium)) ///
graphregion(color(white)) scheme(s2mono) ciopts(recast(rcap)) ///
legend( pos(8) ring(0) col(1) region(lcolor(white)) size(medium)) ///
ysc(r(-.8 .8)) levels(90) 
graph export "$doc\PTA_SDD_CommunicaOccup_Gender.png", replace
