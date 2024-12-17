*2014-2020家庭调查数据合并
*Date：2023.07
*Author：张珊齐 香港中文大学

*1.2014并2016
clear
use "/Users/shanqizhang/Desktop/西南财大实习/数据/cfps2014merged_201906.dta"
append using "/Users/shanqizhang/Desktop/西南财大实习/数据/cfps2016merged_201906.dta"
*unite all variables
replace cfps_age=cfps2014_age if cfps_age==.
drop cfps2014_age
drop fid16
replace provcd14=provcd16 if provcd14==.
drop provcd16
replace urban14=urban16 if urban14==.
drop urban16
replace cfps2012_marriage_update=cfps2014_marriage_update if cfps2012_marriage_update==.
count if cfps2012_marriage_update==.
drop if cfps2012_marriage_update==.
drop cfps2014_marriage_update
replace fml2014num=fml2016_count if fml2014num==.
drop fml2016_count
replace cfps2014eduy_im=cfps2016eduy_im if cfps2014eduy_im==.
count if cfps2014eduy_im==.
drop if cfps2014eduy_im==.
drop cfps2016eduy_im
count if pid!=fresp1pid
count if fresp1pid==.
replace pid=fresp1pid if fresp1pid!=.
*(at this time realized that pid should be fresp1pid instead of fresp4pid for 2014)
drop fresp1pid

reg durable_c durable_r cfps_age total_asset savings cfps2014eduy_im house_debts nonhousing_debts cfps2012_marriage_update fml2014num i.year i.provcd14, robust

save "/Users/shanqizhang/Desktop/西南财大实习/数据/cfps2016merged.dta",replace

*2.2014-16并2018
append using "/Users/shanqizhang/Desktop/西南财大实习/数据/cfps2018merged_202012.dta"
*unite all variables
replace cfps_age=age if cfps_age==.
count if cfps_age==.
drop age
replace provcd14=provcd18 if provcd14==.
*observation in 2018 survey where Province ID is not given are dropped.
count if provcd14==.
drop if provcd14==.
drop provcd18
replace urban14=urban18 if urban14==.
count if urban14==.
drop urban18
replace cfps2012_marriage_update=marriage_last_update if cfps2012_marriage_update==.
*observation in 2018 survey where marraige status is not given are dropped.
*INNER VALIDITY ISSUE: attrition caused OVB
count if cfps2012_marriage_update==.
drop if cfps2012_marriage_update==.
drop marriage_last_update
replace fml2014num=fml_count if fml2014num==.
drop fml_count
replace cfps2014eduy_im=cfps2018eduy_im if cfps2014eduy_im==.
count if cfps2014eduy_im==.
*INNER VALIDITY ISSUE: attrition caused OVB
drop if cfps2014eduy_im==.
drop cfps2018eduy_im

reg durable_c durable_r cfps_age total_asset savings cfps2014eduy_im house_debts nonhousing_debts cfps2012_marriage_update fml2014num i.year i.provcd14, robust

save "/Users/shanqizhang/Desktop/西南财大实习/数据/cfps2018merged.dta",replace

*3.2014-18并2020
append using "/Users/shanqizhang/Desktop/西南财大实习/数据/cfps2020merged_202306.dta"
replace cfps_age=age if cfps_age==.
count if cfps_age==.
drop age
replace provcd14=provcd20 if provcd14==.
count if provcd14==.
drop provcd20
replace urban14=urban20 if urban14==.
count if urban14==.
drop urban20
replace cfps2012_marriage_update=marriage_last_update if cfps2012_marriage_update==.
*observation in 2018 survey where marraige status is not given are dropped.
*INNER VALIDITY ISSUE: attrition caused OVB
count if cfps2012_marriage_update==.
drop if cfps2012_marriage_update==.
drop marriage_last_update
replace fml2014num=fml_count if fml2014num==.
count if fml2014num==.
drop fml_count
replace cfps2014eduy_im=cfps2020eduy_im if cfps2014eduy_im==.
count if cfps2014eduy_im==.
drop cfps2020eduy_im

*clean durable_asset
replace fs6v=. if fs6v<0

*截尾处理,生成新var nonhousing_debts_w
winsor2 nonhousing_debts,cut(1 99)

*gen debt= house_debts+ nonhousing_debts
*gen debt_ratio= debt_w/asset

gen durable_c_ln=ln(durable_c)



save "/Users/shanqizhang/Desktop/西南财大实习/数据/cfps2020merged.dta",replace
