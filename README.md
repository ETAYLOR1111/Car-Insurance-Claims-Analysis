# Car-Insurance-Claims-Analysis
# Overview
This project uses MySQL to analyse car insurance claims and identify high-risk policyholder groups.
The dataset, sourced from Kaggle, contains 8149 policyholders with demographic, behavioural and vehicle-related attributes.
The analysis highlights differences in claim behaviour that can inform premium adjustments.

# Objectives
- For each group within policyholder attributes, highlight their:
    - Policyholder Share (%) 
    - Claim Share (%)
    - Claim Frequency (%)
    - Relative Risk Ratio
- Create a high-risk table including each attribute, highlighting the group within with the greatest relative-risk ratio and compare them to other     attributes to identify which groups are the largest threats.

# Process
- Create multiple CTEs, each containing:
    - Selected attribute and the number of claims made by each group (utilising the outcome column).
    - Selected attribute and the number of policyholders.
    - Table of previous CTEs using LEFT JOIN, including group frequencies.
- Applying the CTEs, find policyholder share, claim share, claim frequency and relative-risk ratio.
- To find the relative-risk ratios, let the group with the minimum frequency be the baseline group, and then compare to each other group.
- Create a summary table to display the high-risk groups within each attribute, comparing each using their relative-risk ratios.
- For attributes that have a large number of groups, i.e. credit score, create bands to develop greater insights into the groups.
- Groups with 0 claims caused issues with calculating relative-risk ratios. To resolve this:
    - Zero values were coverted to NULL and the baseline group was defined by the group with the minimum, non-zero frequency.
  
# Insights
From the summary table,
- Policyholders with 0-9 years of driving-experience show the highest relative-risk ratio (34). Each band contains a large number of policyholders, meaning this result is well-supported by the data.
- Policyholders with 0 past accidents also display a high relative-risk ratio (23.43). Because the distribution of policyholders is heavily skewed, past accidents alone are not a reliable predictor of future claims, and meaningful inference cannot be drawn from this attribute.
- Alternatively, Polyholders aged 16-25 and those in the poverty class band exhibit a higher claim frequency with strong sample sizes. However, their relative-risk ratios are substantially lower than the 0-9 year driving-experience group, indicating they do not pose the same level of risk.
- Poliycholders driving 20,000+ miles annually have a claim frequency of 100%. However, the polichyholder share for this group is very small, making the result unreliable and not suitable for premium adjustments.

Based on strenght of sample sizes and identified risk, premium rates adjustments should be considered for policyholders in the following groups:
- 0-9 years of driving-expereience
- 16-25 years of age
- Poverty Class


# Learning Outcomes
