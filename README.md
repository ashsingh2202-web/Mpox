Mpox Surveillance Project – Florida (2023–2024)
Analyst: Ashima Singh, MPH | Epidemiology & Public Health Surveillance  
Affiliation: Florida Department of Health – Public Health Internship  
Timeline: Fall 2024  
Tools: SAS · Microsoft Excel · Epidemiologic Surveillance Methodology
---
📌 Project Overview
This project presents a descriptive epidemiologic analysis of reported Mpox (Monkeypox) cases in Florida from 2023 to 2024. The analysis was conducted to identify demographic trends, high-risk adult populations, and disparities in disease burden among Hispanic communities — findings that directly informed targeted public health outreach and surveillance planning at the state level.
A condensed version of this analysis was presented as a poster at the International Conference on Aging in the Americas (ICAA 2025).
---
🎯 Objectives
Characterize the demographic distribution of reported Mpox cases in Florida
Identify age groups and populations at highest risk
Quantify and analyze the disproportionate burden among Hispanic/Latino populations
Examine geographic clustering across urban and rural Florida counties
Assess case reporting timeliness and identify surveillance gaps
Identify predictors of hospitalization using logistic regression
---
## My Role

As the primary analyst, I was responsible for:

- Cleaning and validating surveillance datasets
- Developing SAS programs for descriptive and inferential analyses
- Creating demographic and geographic summary tables
- Conducting logistic regression analyses
- Interpreting findings for public health reporting
- Contributing to conference poster development and dissemination
---
📂 Files in This Repository
File	Description
`mpox_analysis.sas`	Full SAS analysis pipeline
`README.md`	Project documentation
> Raw data not included — all analyses conducted on de-identified surveillance data per HIPAA and FDOH data governance policies.
---
📊 Methods
Data Source
De-identified surveillance case data consistent with CDC and FDOH public Mpox reporting standards. All data handled in compliance with HIPAA and public health surveillance ethics guidelines.
Analytic Approach
Step	Description
Data Cleaning	Standardized variables, created age categories, urban/rural classification, reporting delay flags
Descriptive Analysis	Case counts, demographic frequencies, temporal trend by quarter
Disparity Analysis	Hispanic vs. Non-Hispanic comparisons across age, hospitalization, geography
Geographic Analysis	County-level case distribution, urban/rural stratification
Timeliness Analysis	Days from symptom onset to report, late reporting flags (>14 days)
Logistic Regression	Bivariate and multivariable models predicting hospitalization
---
🔍 Key Findings
Adults aged 25–44 represented the highest proportion of reported cases, consistent with national surveillance data
Hispanic/Latino populations experienced a disproportionate case burden relative to population share — a finding with significant implications for health equity and targeted outreach
Urban counties — particularly Miami-Dade, Broward, and Palm Beach — accounted for the majority of cases, reflecting both population density and healthcare access patterns
Reporting timeliness varied significantly by county, suggesting opportunities for strengthening surveillance workflows in underperforming jurisdictions
Multivariable logistic regression identified age group and Hispanic ethnicity as independent predictors of hospitalization after adjusting for sex and urban/rural setting
---
💡 Public Health Implications
These findings were used to:
Support targeted community outreach toward Hispanic adults aged 25–44 in high-burden urban counties
Inform vaccination and education campaign planning at the state level
Identify surveillance gaps in late-reporting counties to strengthen case notification workflows
Contribute to epidemiologic literature on Mpox disparities in aging and Hispanic populations (ICAA 2025)
---
⚙️ Software Requirements
SAS 9.4 or later. Required procedures: PROC IMPORT, PROC FREQ, PROC MEANS, PROC SQL, PROC LOGISTIC, PROC TABULATE, PROC EXPORT.
---
🔒 Ethical Considerations
All data used in this analysis were de-identified and analyzed in accordance with:
HIPAA Privacy Rule requirements for public health surveillance
CDC Data Use Agreement standards
Florida Department of Health data governance policies
No individual-level identifiers are included in this repository.
---
📣 Conference Presentation
> **Singh A.** *Monkeypox in Florida: Trends, High-Risk Adults, and Hispanic Population Burden from 2023 to 2024.* Poster presented at: International Conference on Aging in the Americas (ICAA); 2025.
---
📫 Contact
Ashima Singh, MPH  
📧 ashsingh2202@gmail.com  
🔗 linkedin.com/in/ashimasingh-mph
