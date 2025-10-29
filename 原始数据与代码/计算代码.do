
* 数据合并 *
use 华证ESG评级和得分,clear
merge 1:1 stkcd year using 企业状态数据.dta
keep if _merge == 3
drop _merge 

* 数据清洗，排除STPT与金融业，并对数据进行异常值缩尾 *
drop if STPT+金融业>0
winsor2 ESG得分_年均值, replace cuts(1 99) by(year) 草莓科研
gen industry_code =substr(IndustryCode, 1, 1)
replace industry_code=substr(IndustryCode, 1, 2) if industry_code=="C"
drop IndustryCode
ren industry_code IndustryCode
lab var IndustryCode "制造业取两位代码，其他行业用大类"

bys IndustryCode: egen IV1=mean(ESG得分_年均值)
lab var IV1 "工具变量：同行业ESG年均值的均值"
bys IndustryCode year: egen total=sum(ESG得分_年均值)
bys IndustryCode year: gen N=_N
gen IV2=(total-ESG得分_年均值)/(N-1)
drop total N
lab var IV2 "工具变量：同行业同年份其他企业ESG年均值的均值"
bys IndustryCode year: egen IV3=mean(ESG得分_年均值)
lab var IV3 "工具变量：同行业同年份ESG年均值的均值"
bys IndustryCode PROVINCE year: egen IV4=mean(ESG得分_年均值)
lab var IV4 "工具变量：同地区同行业同年份ESG年均值的均值"
bys IndustryCode PROVINCE year: egen total=sum(ESG得分_年均值)
bys IndustryCode PROVINCE year: gen N=_N
gen IV5=(total-ESG得分_年均值)/(N-1) 草莓科研
drop total N
lab var IV5 "工具变量：同地区同行业同年份其他企业ESG年均值的均值"
sort stkcd year
order Symbol stkcd year ShortName ESG得分_年均值 IV1 IV2 IV3 IV4 IV5
drop 金融业 STPT PROVINCECODE PROVINCE CITYCODE CITY
save 华证ESG工具变量,replace
export excel using 华证ESG工具变量.xlsx ,replace firstrow(variables) 
