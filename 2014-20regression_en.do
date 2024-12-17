*2014-2020 China Household Survey Data Processing & Regression
*Date：2023.07
*Author：Shanqi Zhang, The Chinese University of Hong Kong


clear
use "/Users/shanqizhang/Desktop/西南财大实习/数据/cfps2020merged.dta"
*0. drop variables
drop cid14 cid16 cid18 cid20 countyid14 countyid16 countyid18 countyid20 fid10 fid12 fid14 fid16 fid18 fid20 fq2 fq4 fq5 resp4 resp4pid fp5070 fp5070n durables_asset

*1.rename variables
rename cfps_age age
rename cfps2012_marriage_update marriage
rename provcd14 province
rename urban14 urban
rename fincome1 income
rename fincome1_per fincome_per
rename fml2014num family_num
rename cfps2014eduy_im edu
rename total_asset asset
rename qn12016 confidence
rename fs6v durable_asset


*2.create adjusted variables
replace confidence=. if confidence<0
gen age_sq=age*age
gen income_ln= ln(income)
replace income_ln=0 if income_ln==.
gen savings_ln= ln(savings)
replace savings_ln=0 if savings_ln==.
gen asset_ln= ln(asset)
replace asset_ln=0 if asset_ln==.
*gen durable_c_ln=ln(durable_c)
replace durable_c_ln=0 if durable_c_ln==.
gen durable_r_ln=ln(durable_r)
replace durable_r_ln=0 if durable_r_ln==.
gen nonhousing_debts_w_ln= ln(nonhousing_debts_w)
replace nonhousing_debts_w_ln=0 if nonhousing_debts_w_ln==.
gen debts= house_debts+ nonhousing_debts
winsor2 debts,cut(1 99)
gen debt_ratio= debts/asset
gen debt_ratio_sq= debt_ratio*debt_ratio
winsor2 debt_ratio,cut(1 99)

*clean variable values
*ATTRITION INTERNAL VALIDITY PROBLEM
drop if urban==-9
replace edu=. if edu<0
replace family_num=. if family_num<0
*create marriage dummy variable
replace marriage=. if marriage==-8
replace marriage=. if marriage==3
replace marriage=. if marriage==4
replace marriage=. if marriage==5
replace marriage=0 if marriage==1
replace marriage=1 if marriage==2
*create loan perference variable
replace ft7=. if ft7<0
replace ft7=1 if ft7==2
replace ft7=3 if ft7==4

*Set the data to time series data, assuming that the purchase time to be "year" variable
*tsset pid year
* Sort data by household ID purchase time
*sort pid year
* The average depreciation rate of durable goods calculated by the model is: 0.76/2yr, 0.87/yr, and the depreciation rate is used to calculate the value of last year's durable asset in this year, that is, the stock of durable goods)))
by pid: gen durable_asset_t0 = durable_asset[_n-1] if durable_asset_t0==.
*regress durable_asset_t0 durable_asset yr durable_c
replace durable_remains=durable_asset

* Calculate the mean and standard deviation of durable goods consumption values
sum durable_c_ln
* Output mean and standard deviation
di "耐用品消费值均值：" r(mean)
di "耐用品消费值标准差：" r(sd)
* Preliminary estimates of parameters s and S
local s_estimate = r(mean) - r(sd)
local S_estimate = r(meaPreliminary estimates of parameters s and Sn) + r(sd)
* Print parameter estimation results
di "初步估计的参数s：" `s_estimate'
di "初步估计的参数S：" `S_estimate'
* Set the data to time series data, assuming that the purchase time is the "year" variable
tsset pid year
* Sort data by household ID purchase time
sort pid year
* Calculate the cumulative durable goods consumption value within each household group
by pid: gen cumulative_consumption = sum(durable_c_ln)
* Calculate "durable goods stock" based on the (S, S) model
gen durable_remains = .
by pid: replace durable_remains = 9.862613 - L.cumulative_consumption
by pid: replace durable_remains = durable_c_ln - L.cumulative_consumption if durable_c_ln- L.cumulative_consumption > 0
* Drop the intermediate variable cumulative_consumption
drop cumulative_consumption
replace durable_remains=0 if durable_remains==.

reg durable_c_ln debt_ratio_w income_ln asset_ln family_num marriage age edu durable_remains i.year i.province, robust

reg durable_c_ln debt_ratio_w income_ln asset_ln family_num marriage age edu durable_remains urban i.year i.province if ft7==3, robust

reg durable_c_ln debt_ratio_w income_ln asset_ln family_num marriage age edu durable_remains urban i.year i.province if ft7==1, robust

reg durable_c_ln debt_ratio_w income_ln asset_ln family_num marriage age edu durable_remains urban i.year i.province if ft7==5, robust

reg durable_c_ln debt_ratio_w income_ln asset_ln family_num marriage age edu durable_remains urban i.year i.province if ft7==0, robust

vif
gen nonhousing_debt_ratio=nonhousing_debts_w/asset
gen housing_debt_ratio=house_debts/asset



// Identify unique IDs and count their occurrences
gen id_count = 1
bysort pid: egen id_count_unique = total(id_count)

// Drop observations where the ID appears only once
drop if id_count_unique == 1

// Sort the data by ID and any other relevant variables
sort pid

// Calculate the mean and standard deviation of durable consumption values for each family
egen mean_durable_c = mean(durable_c_ln), by(pid)
egen sd_durable_c = sd(durable_c_ln), by(pid)

// Output the mean and standard deviation
di "耐用品消费值均值：" mean_durable_c
di "耐用品消费值标准差：" sd_durable_c

// Calculate preliminary estimates for parameters s and S
gen s_estimate = mean_durable_c - sd_durable_c
gen S_estimate = mean_durable_c + sd_durable_c
replace s_estimate=0 if s_estimate<0
drop if S_estimate==0
* Calculate the cumulative durable goods consumption value within each household group
by pid: gen cumulative_consumption = sum(durable_c_ln)

gen durable_R=cumulative_consumption[_n-1]*0.87
replace durable_R=mean_durable_c if durable_R==0
replace durable_R=mean_durable_c if durable_R>S_estimate
gen durable_R_adjusted = durable_R/mean_durable_c

reg durable_c_ln debt_ratio_w income_ln asset_ln family_num marriage age edu durable_R_adjusted i.year i.province, robust
