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

label var phy_act_s "O*NET importance score accross occupations"

histogram phy_act_s, frac graphregion(fcolor(white)) color(gs12) ///
xline(68, lstyle(grid) lpattern(dash) lcolor(red)) 
graph export "$doc\histo_occup.png", replace

gen phy_act1=phy_act_s>=75 & phy_act_s!=.
gen comm1 = communica_s>=75 & communica_s!=.
gen analy1 = analy_s>=75 & analy_s!=.
gen mach1 = mach_s>=75 & mach_s!=.
gen doc1 = doc_s>=75 & doc_s!=.

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
coefplot phys, vertical yline(0) drop(Pre_avg Post_avg) omitted baselevels ///
xline(9, lstyle(grid) lpattern(dash) lcolor(ltblue)) ///
ytitle("Likelihood of working in physically-intensive jobs", size(medium) height(5)) ///
ylabel(-.75(0.25)1.25, labs(medium) grid format(%5.2f)) ///
xtitle("Cohorts since policy intervention", size(medium) height(5)) ///
xlabel(, angle(vertical) labs(medium)) ///
graphregion(color(white)) scheme(s2mono) ciopts(recast(rcap)) ///
ysc(r(-0.75 1.25)) recast(connected)
graph export "$doc\PTA_SDD_PhysicalOccup.png", replace

snapshot save, label(snapshot1)
keep if edu<=9
csdid phy_act1 female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat event, window(-6 8) estore(phys_low)
snapshot restore 1

snapshot save, label(snapshot1)
keep if edu>9
csdid phy_act1 female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat event, window(-6 8) estore(phys_high)
snapshot restore 1

coefplot ///
(phys_low, label("Low-education") msymbol(O) mcolor(gs14) ciopt(lc(gs14) recast(rcap))) ///
(phys_high, label("High-education") msymbol(O) mcolor(dknavy) ciopt(lc(dknavy) recast(rcap))) ///
, vertical yline(0) drop(Pre_avg Post_avg Tp6) omitted baselevels ///
xline(9, lstyle(grid) lpattern(dash) lcolor(ltblue)) ///
ytitle("Likelihood of working in physically-demanding jobs", size(medium) height(5)) ///
ylabel(-1.5(.5)1.5, labs(medium) grid format(%5.2f)) ///
xtitle("Cohorts since policy intervention", size(medium) height(5)) ///
xlabel(, angle(vertical) labs(medium)) ///
graphregion(color(white)) scheme(s2mono) ciopts(recast(rcap)) ///
legend( pos(8) ring(0) col(1) region(lcolor(white)) size(medium)) ///
ysc(r(-1.5 1.5)) levels(90) 
graph export "$doc\PTA_SDD_PhysicalOccup_Educa.png", replace

snapshot save, label(snapshot1)
keep if female==1
csdid phy_act1 female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat event, window(-6 8) estore(phys_women)
snapshot restore 1

snapshot save, label(snapshot1)
keep if female==0
csdid phy_act1 female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat event, window(-6 8) estore(phys_men)
snapshot restore 1

coefplot ///
(phys_women, label("Women") msymbol(O) mcolor(gs14) ciopt(lc(gs14) recast(rcap))) ///
(phys_men, label("Men") msymbol(O) mcolor(dknavy) ciopt(lc(dknavy) recast(rcap))) ///
, vertical yline(0) drop(Pre_avg Post_avg) omitted baselevels ///
xline(9, lstyle(grid) lpattern(dash) lcolor(ltblue)) ///
ytitle("Likelihood of working in physically-demanding jobs", size(medium) height(5)) ///
ylabel(-1(.25)1, labs(medium) grid format(%5.2f)) ///
xtitle("Cohorts since policy intervention", size(medium) height(5)) ///
xlabel(, angle(vertical) labs(medium)) ///
graphregion(color(white)) scheme(s2mono) ciopts(recast(rcap)) ///
legend( pos(8) ring(0) col(1) region(lcolor(white)) size(medium)) ///
ysc(r(-1 1)) levels(90) 
graph export "$doc\PTA_SDD_PhysicalOccup_Gender.png", replace

*========================================================================*
gen comm1=communica>=75 & communica!=.

csdid comm1 female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat event, window(-6 8) estore(comm)
coefplot comm, vertical yline(0) drop(Pre_avg Post_avg) omitted baselevels ///
xline(9, lstyle(grid) lpattern(dash) lcolor(ltblue)) ///
ytitle("Likelihood of working in communication-intensive jobs", size(medium) height(5)) ///
ylabel(-1(0.25).5, labs(medium) grid format(%5.2f)) ///
xtitle("Cohorts since policy intervention", size(medium) height(5)) ///
xlabel(, angle(vertical) labs(medium)) ///
graphregion(color(white)) scheme(s2mono) ciopts(recast(rcap)) ///
ysc(r(-1 .5)) recast(connected)
graph export "$doc\PTA_SDD_CommunicaOccup.png", replace

snapshot save, label(snapshot1)
keep if edu<=9
csdid comm1 female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat event, window(-6 8) estore(comm_low)
snapshot restore 1

snapshot save, label(snapshot1)
keep if edu>9
csdid comm1 female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat event, window(-6 8) estore(comm_high)
snapshot restore 1

coefplot ///
(comm_low, label("Low-Educational Achievement") msymbol(O) mcolor(gs14) ciopt(lc(gs14) recast(rcap))) ///
(comm_high, label("High-Educational Achievement") msymbol(O) mcolor(dknavy) ciopt(lc(dknavy) recast(rcap))) ///
, vertical yline(0) drop(Pre_avg Post_avg) omitted baselevels ///
xline(9, lstyle(grid) lpattern(dash) lcolor(ltblue)) ///
ytitle("Likelihood of working in communication-intensive jobs", size(medium) height(5)) ///
ylabel(-.8(.4).8, labs(medium) grid format(%5.2f)) ///
xtitle("Cohorts since policy intervention", size(medium) height(5)) ///
xlabel(, angle(vertical) labs(medium)) ///
graphregion(color(white)) scheme(s2mono) ciopts(recast(rcap)) ///
legend( pos(8) ring(0) col(1) region(lcolor(white)) size(medium)) ///
ysc(r(-.8 .8)) levels(90) 
graph export "$doc\PTA_SDD_CommunicaOccup_Educa.png", replace

snapshot save, label(snapshot1)
keep if female==1
csdid comm1 female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat event, window(-6 8) estore(comm_women)
snapshot restore 1

snapshot save, label(snapshot1)
keep if female==0
csdid comm1 female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat event, window(-6 8) estore(comm_men)
snapshot restore 1

coefplot ///
(comm_women, label("Women") msymbol(O) mcolor(gs14) ciopt(lc(gs14) recast(rcap))) ///
(comm_men, label("Men") msymbol(O) mcolor(dknavy) ciopt(lc(dknavy) recast(rcap))) ///
, vertical yline(0) drop(Pre_avg Post_avg) omitted baselevels ///
xline(9, lstyle(grid) lpattern(dash) lcolor(ltblue)) ///
ytitle("Likelihood of working in communication-intensive jobs", size(medium) height(5)) ///
ylabel(-1(0.25)1, labs(medium) grid format(%5.2f)) ///
xtitle("Cohorts since policy intervention", size(medium) height(5)) ///
xlabel(, angle(vertical) labs(medium)) ///
graphregion(color(white)) scheme(s2mono) ciopts(recast(rcap)) ///
legend( pos(8) ring(0) col(1) region(lcolor(white)) size(medium)) ///
ysc(r(-1 1)) levels(90) 
graph export "$doc\PTA_SDD_CommunicaOccup_Gender.png", replace

*========================================================================*
csdid analy1 female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat event, window(-6 8) estore(analy)
coefplot analy, vertical yline(0) drop(Pre_avg Post_avg) omitted baselevels ///
xline(9, lstyle(grid) lpattern(dash) lcolor(ltblue)) ///
ytitle("Likelihood of working in analysis-intensive jobs", size(medium) height(5)) ///
ylabel(-1(0.25).5, labs(medium) grid format(%5.2f)) ///
xtitle("Cohorts since policy intervention", size(medium) height(5)) ///
xlabel(, angle(vertical) labs(medium)) ///
graphregion(color(white)) scheme(s2mono) ciopts(recast(rcap)) ///
ysc(r(-1 .5)) recast(connected)
graph export "$doc\PTA_SDD_AnalysisOccup.png", replace

snapshot save, label(snapshot1)
keep if edu<=9
csdid analy1 female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat event, window(-6 8) estore(analy_low)
snapshot restore 1

snapshot save, label(snapshot1)
keep if edu>9
csdid analy1 female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat event, window(-6 8) estore(analy_high)
snapshot restore 1

coefplot ///
(analy_low, label("Low-Educational Achievement") msymbol(O) mcolor(gs14) ciopt(lc(gs14) recast(rcap))) ///
(analy_high, label("High-Educational Achievement") msymbol(O) mcolor(dknavy) ciopt(lc(dknavy) recast(rcap))) ///
, vertical yline(0) drop(Pre_avg Post_avg) omitted baselevels ///
xline(9, lstyle(grid) lpattern(dash) lcolor(ltblue)) ///
ytitle("Likelihood of working in analysis-intensive jobs", size(medium) height(5)) ///
ylabel(-.8(.4).8, labs(medium) grid format(%5.2f)) ///
xtitle("Cohorts since policy intervention", size(medium) height(5)) ///
xlabel(, angle(vertical) labs(medium)) ///
graphregion(color(white)) scheme(s2mono) ciopts(recast(rcap)) ///
legend( pos(8) ring(0) col(1) region(lcolor(white)) size(medium)) ///
ysc(r(-.8 .8)) levels(90) 
graph export "$doc\PTA_SDD_AnalysisOccup_Educa.png", replace

snapshot save, label(snapshot1)
keep if female==1
csdid analy1 female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat event, window(-6 8) estore(analy_women)
snapshot restore 1

snapshot save, label(snapshot1)
keep if female==0
csdid analy1 female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat event, window(-6 8) estore(analy_men)
snapshot restore 1

coefplot ///
(analy_women, label("Women") msymbol(O) mcolor(gs14) ciopt(lc(gs14) recast(rcap))) ///
(analy_men, label("Men") msymbol(O) mcolor(dknavy) ciopt(lc(dknavy) recast(rcap))) ///
, vertical yline(0) drop(Pre_avg Post_avg) omitted baselevels ///
xline(9, lstyle(grid) lpattern(dash) lcolor(ltblue)) ///
ytitle("Likelihood of working in analysis-intensive jobs", size(medium) height(5)) ///
ylabel(-1(0.25)1, labs(medium) grid format(%5.2f)) ///
xtitle("Cohorts since policy intervention", size(medium) height(5)) ///
xlabel(, angle(vertical) labs(medium)) ///
graphregion(color(white)) scheme(s2mono) ciopts(recast(rcap)) ///
legend( pos(8) ring(0) col(1) region(lcolor(white)) size(medium)) ///
ysc(r(-1 1)) levels(90) 
graph export "$doc\PTA_SDD_AnalysisOccup_Gender.png", replace
*========================================================================*
csdid mach1 female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat event, window(-6 8) estore(mach)
coefplot mach, vertical yline(0) drop(Pre_avg Post_avg) omitted baselevels ///
xline(9, lstyle(grid) lpattern(dash) lcolor(ltblue)) ///
ytitle("Likelihood of working in machine-intensive jobs", size(medium) height(5)) ///
ylabel(-1(0.25).5, labs(medium) grid format(%5.2f)) ///
xtitle("Cohorts since policy intervention", size(medium) height(5)) ///
xlabel(, angle(vertical) labs(medium)) ///
graphregion(color(white)) scheme(s2mono) ciopts(recast(rcap)) ///
ysc(r(-1 .5)) recast(connected)
graph export "$doc\PTA_SDD_MachOccup.png", replace

snapshot save, label(snapshot1)
keep if edu<=9
csdid mach1 female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat event, window(-6 8) estore(mach_low)
snapshot restore 1

snapshot save, label(snapshot1)
keep if edu>9
csdid mach1 female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat event, window(-6 8) estore(mach_high)
snapshot restore 1

coefplot ///
(mach_low, label("Low-Educational Achievement") msymbol(O) mcolor(gs14) ciopt(lc(gs14) recast(rcap))) ///
(mach_high, label("High-Educational Achievement") msymbol(O) mcolor(dknavy) ciopt(lc(dknavy) recast(rcap))) ///
, vertical yline(0) drop(Pre_avg Post_avg) omitted baselevels ///
xline(9, lstyle(grid) lpattern(dash) lcolor(ltblue)) ///
ytitle("Likelihood of working in machine-intensive jobs", size(medium) height(5)) ///
ylabel(-.8(.4).8, labs(medium) grid format(%5.2f)) ///
xtitle("Cohorts since policy intervention", size(medium) height(5)) ///
xlabel(, angle(vertical) labs(medium)) ///
graphregion(color(white)) scheme(s2mono) ciopts(recast(rcap)) ///
legend( pos(8) ring(0) col(1) region(lcolor(white)) size(medium)) ///
ysc(r(-.8 .8)) levels(90) 
graph export "$doc\PTA_SDD_MachOccup_Educa.png", replace

snapshot save, label(snapshot1)
keep if female==1
csdid mach1 female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat event, window(-6 8) estore(mach_women)
snapshot restore 1

snapshot save, label(snapshot1)
keep if female==0
csdid mach1 female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat event, window(-6 8) estore(mach_men)
snapshot restore 1

coefplot ///
(mach_women, label("Women") msymbol(O) mcolor(gs14) ciopt(lc(gs14) recast(rcap))) ///
(mach_men, label("Men") msymbol(O) mcolor(dknavy) ciopt(lc(dknavy) recast(rcap))) ///
, vertical yline(0) drop(Pre_avg Post_avg) omitted baselevels ///
xline(9, lstyle(grid) lpattern(dash) lcolor(ltblue)) ///
ytitle("Likelihood of working in machine-intensive jobs", size(medium) height(5)) ///
ylabel(-1(0.25)1, labs(medium) grid format(%5.2f)) ///
xtitle("Cohorts since policy intervention", size(medium) height(5)) ///
xlabel(, angle(vertical) labs(medium)) ///
graphregion(color(white)) scheme(s2mono) ciopts(recast(rcap)) ///
legend( pos(8) ring(0) col(1) region(lcolor(white)) size(medium)) ///
ysc(r(-1 1)) levels(90) 
graph export "$doc\PTA_SDD_MachOccup_Gender.png", replace
*========================================================================*
csdid doc1 female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat event, window(-6 8) estore(doc)
coefplot doc, vertical yline(0) drop(Pre_avg Post_avg) omitted baselevels ///
xline(9, lstyle(grid) lpattern(dash) lcolor(ltblue)) ///
ytitle("Likelihood of working in document-intensive jobs", size(medium) height(5)) ///
ylabel(-1(0.25).5, labs(medium) grid format(%5.2f)) ///
xtitle("Cohorts since policy intervention", size(medium) height(5)) ///
xlabel(, angle(vertical) labs(medium)) ///
graphregion(color(white)) scheme(s2mono) ciopts(recast(rcap)) ///
ysc(r(-1 .5)) recast(connected)
graph export "$doc\PTA_SDD_DOcOccup.png", replace

snapshot save, label(snapshot1)
keep if edu<=9
csdid doc1 female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat event, window(-6 8) estore(doc_low)
snapshot restore 1

snapshot save, label(snapshot1)
keep if edu>9
csdid doc1 female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat event, window(-6 8) estore(doc_high)
snapshot restore 1

coefplot ///
(doc_low, label("Low-Educational Achievement") msymbol(O) mcolor(gs14) ciopt(lc(gs14) recast(rcap))) ///
(doc_high, label("High-Educational Achievement") msymbol(O) mcolor(dknavy) ciopt(lc(dknavy) recast(rcap))) ///
, vertical yline(0) drop(Pre_avg Post_avg) omitted baselevels ///
xline(9, lstyle(grid) lpattern(dash) lcolor(ltblue)) ///
ytitle("Likelihood of working in document-intensive jobs", size(medium) height(5)) ///
ylabel(-.8(.4).8, labs(medium) grid format(%5.2f)) ///
xtitle("Cohorts since policy intervention", size(medium) height(5)) ///
xlabel(, angle(vertical) labs(medium)) ///
graphregion(color(white)) scheme(s2mono) ciopts(recast(rcap)) ///
legend( pos(8) ring(0) col(1) region(lcolor(white)) size(medium)) ///
ysc(r(-.8 .8)) levels(90) 
graph export "$doc\PTA_SDD_DocOccup_Educa.png", replace

snapshot save, label(snapshot1)
keep if female==1
csdid doc1 female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat event, window(-6 8) estore(doc_women)
snapshot restore 1

snapshot save, label(snapshot1)
keep if female==0
csdid doc1 female indigenous married educ* [iw=weight], time(cohort) gvar(fist_cohort) method(dripw) wboot vce(cluster geo)
estat event, window(-6 8) estore(doc_men)
snapshot restore 1

coefplot ///
(doc_women, label("Women") msymbol(O) mcolor(gs14) ciopt(lc(gs14) recast(rcap))) ///
(doc_men, label("Men") msymbol(O) mcolor(dknavy) ciopt(lc(dknavy) recast(rcap))) ///
, vertical yline(0) drop(Pre_avg Post_avg) omitted baselevels ///
xline(9, lstyle(grid) lpattern(dash) lcolor(ltblue)) ///
ytitle("Likelihood of working in document-intensive jobs", size(medium) height(5)) ///
ylabel(-1(0.25)1, labs(medium) grid format(%5.2f)) ///
xtitle("Cohorts since policy intervention", size(medium) height(5)) ///
xlabel(, angle(vertical) labs(medium)) ///
graphregion(color(white)) scheme(s2mono) ciopts(recast(rcap)) ///
legend( pos(8) ring(0) col(1) region(lcolor(white)) size(medium)) ///
ysc(r(-1 1)) levels(90) 
graph export "$doc\PTA_SDD_DocOccup_Gender.png", replace
