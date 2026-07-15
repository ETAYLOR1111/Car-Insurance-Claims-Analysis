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
- Create multiple CTEs, each displaying:
    - Selected attribute and the number of claims made by each group (utilising the outcome column).
    - Selected attribute and the number of policyholders.
    - Joined tables of previous CTEs using LEFT JOIN, and finding their frequency.
- Applying the CTEs, find policyholder share, claim share, claim frequency and relative-risk ratio.
- To find the relative-risk ratios, let the group with the minimum frequency be the baseline group, and then compare to each other group.
- Create a table of this result to later display in the high-risk table.
- For attributes that have a large number of groups, i.e. credit score, create bands to develop greater insights into the groups.
- Groups with 0 claims caused issues with calculating relative-risk ratios. To resolve this:
    - Zero values were coverted to NULL and the baseline group was defined by the group with the minimum, non-zero frequency.
    - 
# Insights

# Learning Outcomes
