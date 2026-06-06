/*==============================================================================
  PROJECT:   Mpox Surveillance Analysis – Florida (2023–2024)
  AUTHOR:    Ashima Singh, MPH
  AFFILIATION: Florida Department of Health – Public Health Internship
  DATE:      Fall 2024
  PURPOSE:   Descriptive epidemiologic analysis of reported Mpox cases in
             Florida to identify demographic trends, high-risk populations,
             and disparities among Hispanic populations.
  DATA:      De-identified surveillance data consistent with CDC/FDOH
             public reporting standards. No individual-level identifiers used.
  NOTE:      All analyses conducted in compliance with public health
             surveillance ethics and HIPAA data handling standards.
==============================================================================*/


/*------------------------------------------------------------------------------
  SECTION 1: LIBRARY AND MACRO SETUP
------------------------------------------------------------------------------*/

/* Define working library */
libname mpox "C:\Projects\Mpox_Surveillance";

/* Define global macros */
%let project   = Mpox Surveillance Florida 2023-2024;
%let analyst   = Ashima Singh MPH;
%let run_date  = %sysfunc(today(), date9.);

options nodate nonumber linesize=120 pagesize=60;
title1 "&project";
title2 "Analyst: &analyst | Run Date: &run_date";


/*------------------------------------------------------------------------------
  SECTION 2: DATA IMPORT AND INITIAL REVIEW
------------------------------------------------------------------------------*/

/* Import raw surveillance data */
proc import datafile="C:\Projects\Mpox_Surveillance\data\mpox_florida_raw.csv"
    out=mpox.raw_data
    dbms=csv
    replace;
    getnames=yes;
    datarow=2;
run;

/* Initial data review */
proc contents data=mpox.raw_data varnum;
    title3 "Data Dictionary – Raw Import";
run;

proc print data=mpox.raw_data (obs=10);
    title3 "First 10 Observations – Data Review";
run;


/*------------------------------------------------------------------------------
  SECTION 3: DATA CLEANING AND VARIABLE CREATION
------------------------------------------------------------------------------*/

data mpox.clean_data;
    set mpox.raw_data;

    /* Standardize variable names to lowercase */
    rename CaseID        = case_id
           ReportDate    = report_date
           OnsetDate     = onset_date
           County        = county
           AgeGroup      = age_group
           Sex           = sex
           Ethnicity     = ethnicity
           Race          = race
           Hospitalized  = hospitalized
           Outcome       = outcome;

    /* Create age category variable */
    if      age_years < 18              then age_cat = "1_Under18";
    else if 18 <= age_years <= 24       then age_cat = "2_18to24";
    else if 25 <= age_years <= 34       then age_cat = "3_25to34";
    else if 35 <= age_years <= 44       then age_cat = "4_35to44";
    else if 45 <= age_years <= 54       then age_cat = "5_45to54";
    else if age_years >= 55             then age_cat = "6_55plus";
    else                                     age_cat = "Unknown";

    /* Create Hispanic indicator */
    if upcase(ethnicity) = "HISPANIC OR LATINO" then hispanic = 1;
    else if missing(ethnicity)                  then hispanic = .;
    else                                             hispanic = 0;

    /* Create urban/rural classification based on county population */
    if county in ("Miami-Dade","Broward","Palm Beach","Hillsborough",
                  "Orange","Pinellas","Duval","Lee","Polk","Brevard")
        then urban_rural = "Urban";
    else urban_rural = "Rural/Semi-urban";

    /* Calculate days from onset to report */
    if nmiss(onset_date, report_date) = 0 then
        days_to_report = report_date - onset_date;

    /* Flag cases with reporting delay > 14 days */
    if days_to_report > 14 then late_report = 1;
    else late_report = 0;

    /* Create quarter variable for trend analysis */
    report_qtr = cats("Q", quarter(report_date), "-", year(report_date));

    /* Label variables */
    label
        case_id       = "Unique Case Identifier"
        age_cat       = "Age Category (6 Groups)"
        hispanic      = "Hispanic/Latino Ethnicity (1=Yes, 0=No)"
        urban_rural   = "Urban/Rural Classification"
        days_to_report= "Days from Symptom Onset to Report"
        late_report   = "Late Reporting Flag (>14 days)"
        report_qtr    = "Reporting Quarter";

    /* Drop variables not needed for analysis */
    drop raw_notes temp_field1 temp_field2;

run;

/* Check cleaning results */
proc means data=mpox.clean_data n nmiss min max mean;
    var age_years days_to_report;
    title3 "Descriptive Statistics – Continuous Variables Post-Cleaning";
run;

proc freq data=mpox.clean_data;
    tables age_cat hispanic urban_rural late_report / missing;
    title3 "Frequency Check – Key Categorical Variables";
run;


/*------------------------------------------------------------------------------
  SECTION 4: DESCRIPTIVE ANALYSIS – OVERALL CASE COUNTS
------------------------------------------------------------------------------*/

/* Total case count */
proc sql;
    select count(*) as total_cases label="Total Reported Cases",
           sum(hospitalized) as hospitalized_n label="Hospitalized (n)",
           calculated hospitalized_n / calculated total_cases * 100
               as hospitalization_rate label="Hospitalization Rate (%)"
               format=5.1
    from mpox.clean_data;
    title3 "Overall Case Summary";
quit;

/* Cases by quarter – temporal trend */
proc freq data=mpox.clean_data order=data;
    tables report_qtr / nocum;
    title3 "Cases by Quarter – Temporal Trend";
run;


/*------------------------------------------------------------------------------
  SECTION 5: DEMOGRAPHIC DISTRIBUTION
------------------------------------------------------------------------------*/

/* Age group distribution */
proc freq data=mpox.clean_data;
    tables age_cat / nocum;
    title3 "Case Distribution by Age Group";
run;

/* Sex distribution */
proc freq data=mpox.clean_data;
    tables sex / nocum;
    title3 "Case Distribution by Sex";
run;

/* Race/Ethnicity distribution */
proc freq data=mpox.clean_data;
    tables ethnicity race / nocum missing;
    title3 "Case Distribution by Race and Ethnicity";
run;

/* Cross-tabulation: Age by Sex */
proc freq data=mpox.clean_data;
    tables age_cat * sex / norow nocol nopercent chisq;
    title3 "Age Group by Sex – Cross-Tabulation with Chi-Square Test";
run;


/*------------------------------------------------------------------------------
  SECTION 6: HISPANIC POPULATION DISPARITIES
------------------------------------------------------------------------------*/

/* Hispanic vs Non-Hispanic comparison */
proc freq data=mpox.clean_data;
    tables hispanic * age_cat / row nofreq nopercent chisq;
    title3 "Age Distribution by Hispanic Ethnicity";
run;

proc freq data=mpox.clean_data;
    tables hispanic * hospitalized / row nofreq nopercent chisq;
    title3 "Hospitalization Rate by Hispanic Ethnicity";
run;

proc freq data=mpox.clean_data;
    tables hispanic * urban_rural / row nofreq nopercent;
    title3 "Urban/Rural Distribution by Hispanic Ethnicity";
run;

/* Proportion Hispanic by county – top 10 */
proc sql outobs=10;
    select county,
           count(*) as total_cases,
           sum(hispanic) as hispanic_cases,
           sum(hispanic)/count(*)*100 as pct_hispanic format=5.1
    from mpox.clean_data
    where hispanic ne .
    group by county
    having count(*) >= 3
    order by pct_hispanic desc;
    title3 "Top 10 Counties by Proportion of Hispanic Cases";
quit;


/*------------------------------------------------------------------------------
  SECTION 7: GEOGRAPHIC DISTRIBUTION
------------------------------------------------------------------------------*/

/* Cases by county */
proc freq data=mpox.clean_data order=freq;
    tables county / nocum;
    title3 "Case Count by County – Descending Order";
run;

/* Urban vs Rural distribution */
proc freq data=mpox.clean_data;
    tables urban_rural / nocum;
    title3 "Cases by Urban/Rural Classification";
run;

/* Urban-Rural comparison on hospitalizations */
proc freq data=mpox.clean_data;
    tables urban_rural * hospitalized / row nofreq nopercent chisq;
    title3 "Hospitalization Rate by Urban/Rural Setting";
run;


/*------------------------------------------------------------------------------
  SECTION 8: REPORTING TIMELINESS ANALYSIS
------------------------------------------------------------------------------*/

proc means data=mpox.clean_data n mean median std min max p25 p75;
    var days_to_report;
    title3 "Reporting Timeliness – Days from Onset to Report";
run;

proc freq data=mpox.clean_data;
    tables late_report / nocum;
    title3 "Late Reporting Flag Distribution (>14 Days)";
run;

/* Timeliness by county */
proc means data=mpox.clean_data mean median;
    class county;
    var days_to_report;
    title3 "Mean Reporting Delay by County";
run;


/*------------------------------------------------------------------------------
  SECTION 9: LOGISTIC REGRESSION – PREDICTORS OF HOSPITALIZATION
------------------------------------------------------------------------------*/

/* Bivariate logistic regression: Age group */
proc logistic data=mpox.clean_data descending;
    class age_cat (ref="3_25to34") / param=ref;
    model hospitalized = age_cat;
    title3 "Bivariate Logistic Regression – Age Group and Hospitalization";
run;

/* Bivariate logistic regression: Hispanic ethnicity */
proc logistic data=mpox.clean_data descending;
    model hospitalized = hispanic;
    title3 "Bivariate Logistic Regression – Hispanic Ethnicity and Hospitalization";
run;

/* Multivariable logistic regression */
proc logistic data=mpox.clean_data descending;
    class age_cat (ref="3_25to34")
          sex     (ref="Male")
          urban_rural (ref="Urban") / param=ref;
    model hospitalized = age_cat sex hispanic urban_rural / lackfit;
    oddsratio age_cat;
    oddsratio sex;
    oddsratio hispanic;
    title3 "Multivariable Logistic Regression – Predictors of Hospitalization";
run;


/*------------------------------------------------------------------------------
  SECTION 10: SUMMARY OUTPUT TABLE
------------------------------------------------------------------------------*/

proc tabulate data=mpox.clean_data;
    class age_cat sex hispanic urban_rural;
    var hospitalized days_to_report;
    table (age_cat all="Total"),
          (n colpctn="Col %" mean*hospitalized="Hosp Rate" mean*days_to_report="Avg Days to Report")
          / box="Characteristic";
    title3 "Summary Table – Case Characteristics by Age Group";
run;


/*------------------------------------------------------------------------------
  SECTION 11: EXPORT RESULTS
------------------------------------------------------------------------------*/

/* Export clean dataset to Excel for reporting */
proc export data=mpox.clean_data
    outfile="C:\Projects\Mpox_Surveillance\output\mpox_clean_data.xlsx"
    dbms=xlsx
    replace;
    sheet="Clean Data";
run;

/* Export frequency results to CSV */
proc export data=mpox.clean_data
    outfile="C:\Projects\Mpox_Surveillance\output\mpox_analysis_output.csv"
    dbms=csv
    replace;
run;

/*==============================================================================
  END OF SCRIPT
  Questions: ashsingh2202@gmail.com
==============================================================================*/
