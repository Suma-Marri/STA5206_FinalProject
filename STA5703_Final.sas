/*Question 1*/

DATA examp1;
INPUT before after;
difference=after-before;
CARDS;
186	188
171	177
177	176
168	169
191	196
172	172
177	165
191	190
170	166
171	180
188	181
187	172
;

proc print data=examp1;
run;

ods trace on;
ods output "Tests For Location"=LocationTest;
ods output "Quantiles"=Quantile;
ods output "Moments"=Moments;
ods output "Basic Measures of Location and Variability"=Location;
ods output "Extreme Observations"=Extreme;

PROC UNIVARIATE DATA=examp1 LOCATION=0 CIPCTLDF(ALPHA=0.05);
VAR difference;
RUN;
ods trace off;

*------------------------------------------------------;
*Prepare Wilcoxon Sined Rank Test output data set ;
*------------------------------------------------------;

data WL_test; set LocationTest;
if test="Signed Rank";
run;

title "test for location";
proc print data = WL_test;
run;

*-----------------------------------------------;
*Output data set of median rank and its 95% CI ;
*-----------------------------------------------;

data MedianCI; set quantile;
if quantile="50% Median";
keep Name Quantile Estimate LCLRank UCLRank;
run;

title "Quantiles and 95% CIs for quantiles";
proc print data=MedianCI;
run;

/* Question 4 Fisher's exact test*/
proc format;

value treatment
 0='std treatment'
 1='new treatment';

value condition
 0='infected'
 1='non-infected';
run;

data Clinicalstudy;
input treatment condition Count;
datalines;
0 0 4
0 1 112
1 0 2
1 1 114
;
run;

proc print; run;
ods output "Fisher's Exact Test"=Exact;
proc freq data=Clinicalstudy order=data;
format treatment treatment. condition condition.;
tables treatment*condition / expected chisq relrisk;
exact pchi or;
weight Count;
title í2x2 table analysis of CVD and salt intake dataí;
run;


data exact1; set exact;
if _n_ in (2,3,5,6);
drop Table Name1 nValue1;
run;


proc print data=exact1 noobs;
title "Output of Fisher Exact Test";
run;

*Simpler code;
proc freq data=Clinicalstudy;
tables treatment*condition/exact;
weight count;
run;
/* Question 5 Two-way Anova method*/
 data AA;
 input executives method $ conf;
 datalines;
1 Utility 1.3
1 Worry 4.8
1 Comparison 9.2
2 Utility 2.5
2 Worry 6.9
2 Comparison 14.4
3 Utility 7.2
3 Worry 9.1
3 Comparison 16.5
4 Utility 6.8
4 Worry 13.2
4 Comparison 17.6
5 Utility 12.6
5 Worry 13.6
5 Comparison 15.5

;
run;

options nodate nonumber;
proc print; run;
*ANOVA model without detergent and temperature interaction;

proc glm data=aa;
 class executives method;
 model conf=method executives / ss1;
run;
Proc GLM data =AA;
Class executives method;
Model conf=executives method / ss1;
CONTRAST 'Equality of confidence ratings among 1st and 3rd methods' method 1 0 -1;
CONTRAST 'Equality of confidence ratings among 1st and 2nd methods' method 1 -1 0;
CONTRAST 'Equality of confidence ratings among 2nd and 3rd methods' method 0 1 -1;
CONTRAST 'Equality of confidence ratings among 1st and 2nd executives' executives 1 -1 0 0 0;
CONTRAST 'Equality of confidence ratings among 1st and 3rd executives' executives 1 0 -1 0 0;
CONTRAST 'Equality of confidence ratings among 1st and 4th executives' executives 1 0 0 -1 0;
CONTRAST 'Equality of confidence ratings among 1st and 5th executives' executives 1 0 0 0 -1;
CONTRAST 'Equality of confidence ratings among 2nd and 3rd executives' executives 0 1 -1 0 0;
CONTRAST 'Equality of confidence ratings among 2nd and 4th executives' executives 0 1 0 -1 0;
CONTRAST 'Equality of confidence ratings among 2nd and 5th executives' executives 0 1 0 0 -1;
CONTRAST 'Equality of confidence ratings among 3rd and 4th executives' executives 0 0 1 -1 0;
CONTRAST 'Equality of confidence ratings among 3rd and 5th executives' executives 0 0 1 0 -1;
CONTRAST 'Equality of confidence ratings among 4th and 5th executives' executives 0 0 0 1 -1;
title '2-Way ANOVA For Test Detergent and Temperature Effects';
run;
/*Question 3 Chisqure test for contingency table*/

proc format;
 value result 1='Yes'
 2='No'
	3='Uncertain';
 value gender 1='Women'
 2='Men';
run;

proc format;
 value case 1='Case'
 0='Noncase';
 value age 1='>=30'
 0='<=29';
run;

data cancer;
 input gender result Count;

 datalines;
1 1 125
1 2 59
1 3 21
2 1 101
2 2 79
2 3 16
;
run;

proc print data=cancer;
run;

ods trace on;
ods output "Chi-Square Tests"=Chisquare;
proc freq data=cancer order=data;
 format gender gender. result result.;
 tables gender*result / expected chisq relrisk nocol norow nopercent;
 weight Count;
 title 'Breast Cancer and Age of First Birth Study';
run;
ods trace off;

*Chisqure test (with and without continuity correction);
data Chisq; set chisquare;
if statistic in ("Chi-Square","Continuity Adj. Chi-Square");
drop table;
run;

options nodate nonumber;
proc print data=Chisq noobs;
title "Chisqure Test of 2x2 Contingency Table";
run;

/*Question 2a*/


data example;
input g1 g2 g3 g4;
cards;
8.3 9.1 10.1 7.8
9.4 9.0 10.0 8.2
9.1 8.1 9.6 8.1
9.1 8.2 9.3 7.9
9.0 8.8 9.8 7.7
8.9 8.4 9.5 8.0
8.9 8.3 9.4 8.1
;
run;

*compute the means and medians of the three groups;
ods select none;
proc means data=example;
var g1 g2 g3 g4;
output out=a mean=mean1 mean2 mean3 mean4 median=med1 med2 med3 med4;
run;
ods select all;
proc print data=a noobs;
var mean1 mean2 mean3 mean4 med1 med2 med3 med4;
title "Means and medians from three groups";
run;

*Perform Wilcoxon test on equality of distributions from three groups;
data aa1 aa2 aa3 aa4;
set example;
group="group1"; y=g1; output aa1;
group="group2"; y=g2; output aa2;
group="group3"; y=g3; output aa3;
group="group4"; y=g4; output aa4;
run;
data W;
set aa1 aa2 aa3 aa4;
run;
*perform Kruskal-Wallis test to compare distributions;
ods select none;
ods output "Scores"=WS;
ods output "Kruskal-Wallis Test"=W1;
proc npar1way wilcoxon correct=yes data=W;
class group;
var y;
run;
ods select all;
proc print data=WS noobs;
format SumOfScores StdDevOfSum MeanScore 6.2;
var Class N SumOfScores StdDevOfSum MeanScore;
title "Scores of each group";
run;
proc print data=W1 noobs;
format cValue1 $6.;
var Variable Name1 Label1 cValue1;
title "Kruskal-Wallis Test for means";
run;

/*Question 2 part B*/
data example1;
input g3 g4;
cards;
10.1 7.8
10.0 8.2
9.6 8.1
9.3 7.9
9.8 7.7
9.5 8.0
9.4 8.1
;
run;

*compute the means and medians of the three groups;
ods select none;
proc means data=example1;
var g3 g4;
output out=a mean=mean1 mean2 median=med1 med2;
run;
ods select all;
proc print data=a noobs;
var mean1 mean2 med1 med2;
title "Means and medians from three groups";
run;

*Perform Wilcoxon test on equality of distributions from three groups;
data aa3 aa4;
set example1;
group="group3"; y=g3; output aa3;
group="group4"; y=g4; output aa4;
run;
data W;
set aa3 aa4;
run;
*perform Kruskal-Wallis test to compare distributions;
ods select none;
ods output "Scores"=WS;
ods output "Kruskal-Wallis Test"=W1;
proc npar1way wilcoxon correct=yes data=W;
class group;
var y;
run;
ods select all;
proc print data=WS noobs;
format SumOfScores StdDevOfSum MeanScore 6.2;
var Class N SumOfScores StdDevOfSum MeanScore;
title "Scores of each group";
run;
proc print data=W1 noobs;
format cValue1 $6.;
var Variable Name1 Label1 cValue1;
title "Kruskal-Wallis Test for means betweeen variety C and D";
run;

data ranksum; input VISUAL $ CLASS;
datalines;
10.1 1
10.0 1
9.6 1
9.3 1
9.8 1
9.5 1
9.4 1
7.8 2
8.2 2
8.1 2
7.9 2
7.7 2
8.0 2
8.1 2
;
run;
proc print data=ranksum;
run;
data ranksum; set ranksum;
if visual ="10.1" then VA=13;
if visual ="10.0" then VA=12;
if visual ="9.6" then VA=10;
if visual ="9.3" then VA=7;
if visual ="9.8" then VA=11;
if visual ="9.5" then VA=9;
if visual ="9.4" then VA=8;
if visual ="7.8" then VA=2;
if visual ="8.2" then VA=6;
if visual ="8.1" then VA=5;
if visual ="7.9" then VA=3;
if visual ="7.7" then VA=1;
if visual ="8.0" then VA=4;
run;

***************************************************;
*Call SAS procedure NP1WAY to perform Wicoxon ;
*rank sum test ;
***************************************************;
proc npar1way wilcoxon correct=yes data = ranksum;
 class CLASS;
 var VA;
run;

*------------------------------------------------------------;
*Use ODS data set label to create desired output data set ;
*Actual label name can be found from the SAS log file when ;
*the ODS trace function is activated (ods trace on) when ;
*option is specified ;
*------------------------------------------------------------;

ods trace on;
ods output "Two-Sample Test"=Wtest;
ods output "Scores"=Wscore;
proc npar1way wilcoxon correct=yes data=ranksum;
 class CLASS;
 var VA;
run;
ods trace off;

proc print data=ranksum;
title1 "Wilcoxon Rank Sum Test---Test Statistic and P-value Output";
title2 "Using Outout Deliveray System (ODS)";
run;

proc print data=ranksum;
title1 "Wilcoxon Rank Sum Test---Score Output";
title2 "Using Outout Deliveray System (ODS)";
run;


*-----------------------------------------------------;
*ODS output table using ods output data set name ;
*-----------------------------------------------------;
ods trace on;
proc npar1way wilcoxon correct=yes data=ranksum;
 class CLASS;
 var VA;
ods output WilcoxonScores=WL_Score WilcoxonTest=WL_test ;
run;
ods trace off;

proc print data=Wtest;
title1 "Wilcoxon Rank Sum Test---Test Statistic and P-value Output";
title2 "Using Outout Deliveray System (ODS)";
run;

proc print data=Wscore;
title1 "Wilcoxon Rank Sum Test---Score Output";
title2 "Using Outout Deliveray System (ODS)";
run;

On Mon, Dec 5, 2022 at 6:56 PM Suma Marri <smarri0612@gmail.com> wrote:
/*Question 1*/

DATA examp1;
INPUT before after;
difference=after-before;
CARDS;
186	188
171	177
177	176
168	169
191	196
172	172
177	165
191	190
170	166
171	180
188	181
187	172
;

proc print data=examp1;
run;

ods trace on;
ods output "Tests For Location"=LocationTest;
ods output "Quantiles"=Quantile;
ods output "Moments"=Moments;
ods output "Basic Measures of Location and Variability"=Location;
ods output "Extreme Observations"=Extreme;

PROC UNIVARIATE DATA=examp1 LOCATION=0 CIPCTLDF(ALPHA=0.05);
VAR difference;
RUN;
ods trace off;

*------------------------------------------------------;
*Prepare Wilcoxon Sined Rank Test output data set ;
*------------------------------------------------------;

data WL_test; set LocationTest;
if test="Signed Rank";
run;

title "test for location";
proc print data = WL_test;
run;

*-----------------------------------------------;
*Output data set of median rank and its 95% CI ;
*-----------------------------------------------;

data MedianCI; set quantile;
if quantile="50% Median";
keep Name Quantile Estimate LCLRank UCLRank;
run;

title "Quantiles and 95% CIs for quantiles";
proc print data=MedianCI;
run;

/* Question 4 Fisher's exact test*/
proc format;

value treatment
 0='std treatment'
 1='new treatment';

value condition
 0='infected'
 1='non-infected';
run;

data Clinicalstudy;
input treatment condition Count;
datalines;
0 0 4
0 1 112
1 0 2
1 1 114
;
run;

proc print; run;
ods output "Fisher's Exact Test"=Exact;
proc freq data=Clinicalstudy order=data;
format treatment treatment. condition condition.;
tables treatment*condition / expected chisq relrisk;
exact pchi or;
weight Count;
title í2x2 table analysis of CVD and salt intake dataí;
run;


data exact1; set exact;
if _n_ in (2,3,5,6);
drop Table Name1 nValue1;
run;


proc print data=exact1 noobs;
title "Output of Fisher Exact Test";
run;

*Simpler code;
proc freq data=Clinicalstudy;
tables treatment*condition/exact;
weight count;
run;
/* Question 5 Two-way Anova method*/
 data AA;
 input executives method $ conf;
 datalines;
1 Utility 1.3
1 Worry 4.8
1 Comparison 9.2
2 Utility 2.5
2 Worry 6.9
2 Comparison 14.4
3 Utility 7.2
3 Worry 9.1
3 Comparison 16.5
4 Utility 6.8
4 Worry 13.2
4 Comparison 17.6
5 Utility 12.6
5 Worry 13.6
5 Comparison 15.5

;
run;

options nodate nonumber;
proc print; run;
*ANOVA model without detergent and temperature interaction;

proc glm data=aa;
 class executives method;
 model conf=method executives / ss1;
run;
Proc GLM data =AA;
Class executives method;
Model conf=executives method / ss1;
CONTRAST 'Equality of confidence ratings among 1st and 3rd methods' method 1 0 -1;
CONTRAST 'Equality of confidence ratings among 1st and 2nd methods' method 1 -1 0;
CONTRAST 'Equality of confidence ratings among 2nd and 3rd methods' method 0 1 -1;
CONTRAST 'Equality of confidence ratings among 1st and 2nd executives' executives 1 -1 0 0 0;
CONTRAST 'Equality of confidence ratings among 1st and 3rd executives' executives 1 0 -1 0 0;
CONTRAST 'Equality of confidence ratings among 1st and 4th executives' executives 1 0 0 -1 0;
CONTRAST 'Equality of confidence ratings among 1st and 5th executives' executives 1 0 0 0 -1;
CONTRAST 'Equality of confidence ratings among 2nd and 3rd executives' executives 0 1 -1 0 0;
CONTRAST 'Equality of confidence ratings among 2nd and 4th executives' executives 0 1 0 -1 0;
CONTRAST 'Equality of confidence ratings among 2nd and 5th executives' executives 0 1 0 0 -1;
CONTRAST 'Equality of confidence ratings among 3rd and 4th executives' executives 0 0 1 -1 0;
CONTRAST 'Equality of confidence ratings among 3rd and 5th executives' executives 0 0 1 0 -1;
CONTRAST 'Equality of confidence ratings among 4th and 5th executives' executives 0 0 0 1 -1;
title '2-Way ANOVA For Test Detergent and Temperature Effects';
run;
/*Question 3 Chisqure test for contingency table*/

proc format;
 value result 1='Yes'
 2='No'
	3='Uncertain';
 value gender 1='Women'
 2='Men';
run;

proc format;
 value case 1='Case'
 0='Noncase';
 value age 1='>=30'
 0='<=29';
run;

data cancer;
 input gender result Count;

 datalines;
1 1 125
1 2 59
1 3 21
2 1 101
2 2 79
2 3 16
;
run;

proc print data=cancer;
run;

ods trace on;
ods output "Chi-Square Tests"=Chisquare;
proc freq data=cancer order=data;
 format gender gender. result result.;
 tables gender*result / expected chisq relrisk nocol norow nopercent;
 weight Count;
 title 'Breast Cancer and Age of First Birth Study';
run;
ods trace off;

*Chisqure test (with and without continuity correction);
data Chisq; set chisquare;
if statistic in ("Chi-Square","Continuity Adj. Chi-Square");
drop table;
run;

options nodate nonumber;
proc print data=Chisq noobs;
title "Chisqure Test of 2x2 Contingency Table";
run;

/*Question 2a*/


data example;
input g1 g2 g3 g4;
cards;
8.3 9.1 10.1 7.8
9.4 9.0 10.0 8.2
9.1 8.1 9.6 8.1
9.1 8.2 9.3 7.9
9.0 8.8 9.8 7.7
8.9 8.4 9.5 8.0
8.9 8.3 9.4 8.1
;
run;

*compute the means and medians of the three groups;
ods select none;
proc means data=example;
var g1 g2 g3 g4;
output out=a mean=mean1 mean2 mean3 mean4 median=med1 med2 med3 med4;
run;
ods select all;
proc print data=a noobs;
var mean1 mean2 mean3 mean4 med1 med2 med3 med4;
title "Means and medians from three groups";
run;

*Perform Wilcoxon test on equality of distributions from three groups;
data aa1 aa2 aa3 aa4;
set example;
group="group1"; y=g1; output aa1;
group="group2"; y=g2; output aa2;
group="group3"; y=g3; output aa3;
group="group4"; y=g4; output aa4;
run;
data W;
set aa1 aa2 aa3 aa4;
run;
*perform Kruskal-Wallis test to compare distributions;
ods select none;
ods output "Scores"=WS;
ods output "Kruskal-Wallis Test"=W1;
proc npar1way wilcoxon correct=yes data=W;
class group;
var y;
run;
ods select all;
proc print data=WS noobs;
format SumOfScores StdDevOfSum MeanScore 6.2;
var Class N SumOfScores StdDevOfSum MeanScore;
title "Scores of each group";
run;
proc print data=W1 noobs;
format cValue1 $6.;
var Variable Name1 Label1 cValue1;
title "Kruskal-Wallis Test for means";
run;

/*Question 2 part B*/
data example1;
input g3 g4;
cards;
10.1 7.8
10.0 8.2
9.6 8.1
9.3 7.9
9.8 7.7
9.5 8.0
9.4 8.1
;
run;

*compute the means and medians of the three groups;
ods select none;
proc means data=example1;
var g3 g4;
output out=a mean=mean1 mean2 median=med1 med2;
run;
ods select all;
proc print data=a noobs;
var mean1 mean2 med1 med2;
title "Means and medians from three groups";
run;

*Perform Wilcoxon test on equality of distributions from three groups;
data aa3 aa4;
set example1;
group="group3"; y=g3; output aa3;
group="group4"; y=g4; output aa4;
run;
data W;
set aa3 aa4;
run;
*perform Kruskal-Wallis test to compare distributions;
ods select none;
ods output "Scores"=WS;
ods output "Kruskal-Wallis Test"=W1;
proc npar1way wilcoxon correct=yes data=W;
class group;
var y;
run;
ods select all;
proc print data=WS noobs;
format SumOfScores StdDevOfSum MeanScore 6.2;
var Class N SumOfScores StdDevOfSum MeanScore;
title "Scores of each group";
run;
proc print data=W1 noobs;
format cValue1 $6.;
var Variable Name1 Label1 cValue1;
title "Kruskal-Wallis Test for means betweeen variety C and D";
run;

data ranksum; input VISUAL $ CLASS;
datalines;
10.1 1
10.0 1
9.6 1
9.3 1
9.8 1
9.5 1
9.4 1
7.8 2
8.2 2
8.1 2
7.9 2
7.7 2
8.0 2
8.1 2
;
run;
proc print data=ranksum;
run;
data ranksum; set ranksum;
if visual ="10.1" then VA=13;
if visual ="10.0" then VA=12;
if visual ="9.6" then VA=10;
if visual ="9.3" then VA=7;
if visual ="9.8" then VA=11;
if visual ="9.5" then VA=9;
if visual ="9.4" then VA=8;
if visual ="7.8" then VA=2;
if visual ="8.2" then VA=6;
if visual ="8.1" then VA=5;
if visual ="7.9" then VA=3;
if visual ="7.7" then VA=1;
if visual ="8.0" then VA=4;
run;

***************************************************;
*Call SAS procedure NP1WAY to perform Wicoxon ;
*rank sum test ;
***************************************************;
proc npar1way wilcoxon correct=yes data = ranksum;
 class CLASS;
 var VA;
run;

*------------------------------------------------------------;
*Use ODS data set label to create desired output data set ;
*Actual label name can be found from the SAS log file when ;
*the ODS trace function is activated (ods trace on) when ;
*option is specified ;
*------------------------------------------------------------;

ods trace on;
ods output "Two-Sample Test"=Wtest;
ods output "Scores"=Wscore;
proc npar1way wilcoxon correct=yes data=ranksum;
 class CLASS;
 var VA;
run;
ods trace off;

proc print data=ranksum;
title1 "Wilcoxon Rank Sum Test---Test Statistic and P-value Output";
title2 "Using Outout Deliveray System (ODS)";
run;

proc print data=ranksum;
title1 "Wilcoxon Rank Sum Test---Score Output";
title2 "Using Outout Deliveray System (ODS)";
run;


*-----------------------------------------------------;
*ODS output table using ods output data set name ;
*-----------------------------------------------------;
ods trace on;
proc npar1way wilcoxon correct=yes data=ranksum;
 class CLASS;
 var VA;
ods output WilcoxonScores=WL_Score WilcoxonTest=WL_test ;
run;
ods trace off;

proc print data=Wtest;
title1 "Wilcoxon Rank Sum Test---Test Statistic and P-value Output";
title2 "Using Outout Deliveray System (ODS)";
run;

proc print data=Wscore;
title1 "Wilcoxon Rank Sum Test---Score Output";
title2 "Using Outout Deliveray System (ODS)";
run;
