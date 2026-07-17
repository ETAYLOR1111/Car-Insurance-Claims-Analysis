# Car-Insurance-Claims-Analysis
# Overview
This project uses MySQL to analyse car insurance claims and identify policyholder groups at a high-risk of making claims.
The dataset, sourced from Kaggle, contains 8149 policyholders with demographic, behavioural and vehicle-related attributes.
The analysis compares claim behaviour across policyholder groups to identify factors that could support premium pricing decisions.

# Dataset
Source: Kaggle
Link: https://www.kaggle.com/datasets/sagnik1511/car-insurance-data/data
Rows: 8149
Attributes: demographic, behavioural, vehicle-related

# Tools Used
- MySQL
- Visual Studio Code
- Git
- Kaggle

# Objectives
- For each group within policyholder attributes, calculate:
    - Policyholder Share (%) 
    - Claim Share (%)
    - Claim Frequency (%)
    - Relative Risk Ratio
- Create a high-risk table including each attribute, highlighting the group within with the greatest relative-risk ratio and compare them to other     attributes to identify which groups are the largest risk.

# Process
- Create multiple Common Table Expressions (CTEs) in order:
    - Selected attribute and the number of claims made by each group (using the outcome column to identify successful claims).
    - Selected attribute and the number of policyholders.
    - Table of previous CTEs using LEFT JOIN, including group frequencies.
- Applying the CTEs, find policyholder share, claim share, claim frequency and relative-risk ratio.
- Use the group with the lowest, non-zero frequency as the baseline group to find relative-risk ratios, and then compare to each other group.
- Create a summary table to display the high-risk groups within each attribute, comparing each using their relative-risk ratios.
- For attributes that have a large number of groups, i.e. credit score, create bands to develop greater insights into the groups.
- Groups with 0 claims caused issues with calculating relative-risk ratios. To resolve this:
    - Zero values were converted to NULL and the baseline group was defined by the group with the minimum, non-zero frequency.
  
# Insights
From the summary table,
- Policyholders with 0-9 years of driving-experience show the highest relative-risk ratio (34). Each band contains a large number of policyholders, meaning this result is well-supported by the data.
- Although policyholders with no past accidents produced a high relative-risk ratio (23.43), the distribution of policyholders is heavily skewed. Therefore, the past accidents variable alone is not a reliable predictor of future claims, meaning the variable is not sufficiently reliable for drawing pricing conclusions.
- Alternatively, Policyholders aged 16-25 and those in the poverty class band exhibit a higher claim frequency with strong sample sizes. However, their relative-risk ratios are substantially lower than the 0-9 year driving-experience group, indicating they do not pose the same level of risk.
- Policycholders driving 20,000+ miles annually have a claim frequency of 100%. However, the policyholder share for this group is very small, making the result unreliable and not suitable for premium adjustments.

Based on the strength of sample sizes and identified risk, premium rate adjustments should be considered for policyholders in the following groups:
- 0-9 years of driving-expereience
- 16-25 years of age
- Poverty Class


# Learning Outcomes
- Improved my SQL skills through extensive use of CTEs, joins and window functions.
- Learned to calculate and interpret policyholder share, claim share, claim frequency and relative risk.
- Gained experience assessing statistical reliability by considering sample size alongside observed claim rates.
- Improved my ability to communicate technical findings in a clear and business-focused manner.
