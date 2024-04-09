clear all

cd "D:\..VUW\Assignment 1 ECON303"

***Task 1***

import excel Econ303-1.Survey.xlsx, sheet("Sheet0") firstrow

*delete first row
drop if Finished == "Finished" 

*delete unnescessary variables
drop Durationinseconds	Finished	ResponseId	RecipientLastName	RecipientFirstName	RecipientEmail	ExternalReference	DistributionChannel	UserLanguage P Q

*delete non-numeric values of variable q2
gen non_numberic = missing(real(q2))
replace q2 = "" if non_numberic==1
drop non_numberic

*destring variables 
destring q1 q2 q3 q4 q5_1 q6_1, replace

*delete nonsensical values
replace q2 = . if q2 < 18 | q2 > 80

*rename variables
rename q1 sex
rename q2 age
rename q3 id
rename q4 FinancialStress
rename q5_1 PDlikelihood0
rename q6_1 PDlikelihood1

*Merge survey responses and demographic
merge 1:1 id using demographic.dta
drop if _merge==2
drop _merge

*create value labels
label define sexx 1 "Female" 2 "Male" 3 "Others"
label values sex sexx
label define FS 1 "Never" 2 "Sometimes" 3 "Often" 4 "Always"
label values FinancialStress FS

*create variable labels
label variable sex "1-Female / 2-Male / 3-Others"
label variable age "Age"
label variable id "id"
label variable FinancialStress "How often do you worry about not having enough money?"
label variable PDlikelihood0 "Likelihood of enrolling in postgraduate degree"
label variable PDlikelihood1 " Likelihood of enrolling in postgraduate degree with $1,000/month scholarship"
label variable firstyear "1 if first year student, 0 if not"

*Order variables
order id

*Save dataset for the summary statistics
save Pham_sumstats, replace

*Create summary statistics table of variables
global sumstats age FinancialStress PDlikelihood0 PDlikelihood1 gpa firstyear
sum $sumstats
outreg2 using table1, sum(log) replace keep($sumstats) label excel

***Task 2***

*Reshape dataset from wide to long
reshape long PDlikelihood, i(id) j(scholarship)

*Regression of students' stated likelihood of pursuing a postgraduate degree on a dummy which is 1 if students answered the scholarship question and 0 if the students answered the current financial situation question. 
*a. All students
reg PDlikelihood scholarship, cluster(id)
outreg2 using table2, bdec(3) ctitle(Likelihood) addtext(Sample,All students) replace

*b. 1st year students
reg PDlikelihood scholarship if firstyear==1, cluster(id)
outreg2 using table2, bdec(3) ctitle(Likelihood) addtext(Sample,1st year students)

*c. 2nd year students
reg PDlikelihood scholarship if firstyear==0, cluster(id)
outreg2 using table2, bdec(3) ctitle(Likelihood) addtext(Sample,2nd year students) excel

*Save dataset for the results
save Pham_results, replace


