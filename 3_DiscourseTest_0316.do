/*==================================================

Proiect:		master thesis
Author:			liuziyu
Create Date:	2024.02
Edit Date:		2024.3.16

--------------------------------------------------

This script is for: 
	全班层面差异检验；
	小组层面差异检验；
	个人层面差异检验；
		
==================================================*/

/* ================================================== */
/* ================================================== */
*--- 0: 清空内存，定义路径
/* ================================================== */
/* ================================================== */

clear 
cls 

global dir "D:\Onedrive\OneDrive - mail.bnu.edu.cn\0 Academic\1_Graduation\1_毕业设计_202306\1_data"
	global rawdir "$dir\0_rawdata"
	global mydir "$dir\1_mydata"
		global textdir "$mydir\5_discourse"
	global masterdir "$dir\2_mymaster"
	global desdir "$dir\3_mydescription"

set scheme plotplain, perm

/* ================================================== */
/* ================================================== */
*--- 1 全班层面
/* ================================================== */
/* ================================================== */

*------ 1.1 截面差异
// 冲突与非冲突话轮数量、比例的差异
cd "$textdir\2_analysis\1_Class"
use cfl_class0, clear

foreach i in ncfl_class0 pcfl_class0 {
	gr box `i', over(cfl)
	cd "$desdir\2_Discourse\1_Class"
	gr export "`i'.png", as(png) replace
	di("sw正态性检验，＜0.1提示2组数据不服从正态分布")
	swilk `i' if cfl == 0
	swilk `i' if cfl == 1
	di("方差齐性检验，＜0.1提示2组数据方差不齐")
	robvar `i', by(cfl)
	di("Mann-Whitney U检验，＜0.05，提示2组数据存在显著差异")
	ranksum `i', by(cfl)
}

// 不同类别冲突话轮数量、比例的差异
cd "$textdir\2_analysis\1_Class"
use cfl_class1, clear

foreach i in ncfl_class1 pcfl_class1 {
	gr box `i', over(cfl)
	cd "$desdir\2_Discourse\1_Class"
	gr export "`i'.png", as(png) replace
	di("sw正态性检验，＜0.1提示3组数据不服从正态分布")
	swilk `i' if cfl == 1
	swilk `i' if cfl == 2
	swilk `i' if cfl == 3
	di("方差齐性检验，＜0.1提示3组数据方差不齐")
	robvar `i', by(cfl)
	di("Kruskal-Wallis H检验，＜0.05，提示3组数据存在显著差异")
	kwallis2 `i', by(cfl)
}

// 不同类别冲突管理话轮数量、比例的差异
cd "$textdir\2_analysis\1_Class"
use mng_class1, clear
foreach i in nmng_class1 pmng_class1 {
	gr box `i', over(mng)
	cd "$desdir\2_Discourse\1_Class"
	gr export "`i'.png", as(png) replace
	di("sw正态性检验，＜0.1提示4组数据不服从正态分布")
	swilk `i' if mng == 1
	swilk `i' if mng == 2
	swilk `i' if mng == 3
	swilk `i' if mng == 4
	di("方差齐性检验，＜0.1提示4组数据方差不齐")
	robvar `i', by(mng)
	di("Kruskal-Wallis H检验，＜0.05，提示4组数据存在显著差异")
	kwallis2 `i', by(mng)
}

// 不同课程内容下，有效话轮、冲突话轮、协作管理策略比例的差异
foreach i in cfl relate {
	cd "$textdir\2_analysis\1_Class"
	use `i'_class0, clear
	drop if `i' == 0

	foreach j in n`i' p`i' {
		gr box `j', over(orient)
		cd "$desdir\2_Discourse\1_Class"
		gr export "orient_`j'.png", as(png) replace
		di("sw正态性检验，＜0.1提示两组数据不服从正态分布")
		swilk `j' if orient == 1
		swilk `j' if orient == 2
		di("方差齐性检验，＜0.1提示两组数据方差不齐")
		robvar `j', by(orient)
	}
}

// 检验结果：ncfl方差不齐，pcfl方差齐性，nrelate方差齐性，prelate方差齐性
cd "$textdir\2_analysis\1_Class"
use cfl_class0, clear
drop if cfl == 0
di("Mann-Whitney U检验，＜0.05，提示两组数据存在显著差异")
ranksum ncfl_class0, by(orient)
di("独立样本t检验，<0.05，提示两组数据存在显著差异")
ttest pcfl_class0, by(orient)

cd "$textdir\2_analysis\1_Class"
use relate_class0, clear
drop if relate == 0
di("独立样本t检验，<0.05，提示两组数据存在显著差异")
ttest nrelate_class0, by(orient)
di("独立样本t检验，<0.05，提示两组数据存在显著差异")
ttest prelate_class0, by(orient)

// 不同课程内容下，任务冲突话轮、协作话轮数量、比例的差异
cd "$textdir\2_analysis\1_Class"
use cfl_class1, clear
keep if cfl == 1

foreach j in ncfl_class1 pcfl_class1 {
	gr box `j', over(orient)
	cd "$desdir\2_Discourse\1_Class"
	gr export "orient_`j'.png", as(png) replace
	di("sw正态性检验，＜0.1提示两组数据不服从正态分布")
	swilk `j' if orient == 1
	swilk `j' if orient == 2
	di("方差齐性检验，＜0.1提示两组数据方差不齐")
	robvar `j', by(orient)
}

// 检验结果：ncfl和pcfl方差齐性
cd "$textdir\2_analysis\1_Class"
use cfl_class1, clear
keep if cfl == 1
di("独立样本t检验，<0.05，提示两组数据存在显著差异")
ttest ncfl_class1, by(orient)
di("独立样本t检验，<0.05，提示两组数据存在显著差异")
ttest pcfl_class1, by(orient)

// 不同课程内容下，协作话轮数量、比例的差异
cd "$textdir\2_analysis\1_Class"
use mng_class1, clear
keep if mng == 3
foreach j in nmng_class1 pmng_class1 {
	gr box `j', over(orient)
	cd "$desdir\2_Discourse\1_Class"
	gr export "orient_`j'.png", as(png) replace
	di("sw正态性检验，＜0.1提示两组数据不服从正态分布")
	swilk `j' if orient == 1
	swilk `j' if orient == 2
	di("方差齐性检验，＜0.1提示两组数据方差不齐")
	robvar `j', by(orient)
}

// 检验结果：nmng方差不齐，pmng方差齐性
cd "$textdir\2_analysis\1_Class"
use mng_class1, clear
keep if mng == 3
di("Mann-Whitney U检验，＜0.05，提示两组数据存在显著差异")
ranksum nmng_class1, by(orient)
di("独立样本t检验，<0.05，提示两组数据存在显著差异")
ttest pmng_class1, by(orient)

// 不同课程内容下，竞争话轮数量、比例的差异
cd "$textdir\2_analysis\1_Class"
use mng_class1, clear
keep if mng == 2
foreach j in nmng_class1 pmng_class1 {
	gr box `j', over(orient)
	cd "$desdir\2_Discourse\1_Class"
	gr export "orient_`j'_2.png", as(png) replace
	di("sw正态性检验，＜0.1提示两组数据不服从正态分布")
	swilk `j' if orient == 1
	swilk `j' if orient == 2
	di("方差齐性检验，＜0.1提示两组数据方差不齐")
	robvar `j', by(orient)
}

// 检验结果：nmng非正态，pmng方差不齐
cd "$textdir\2_analysis\1_Class"
use mng_class1, clear
keep if mng == 2
di("Mann-Whitney U检验，＜0.05，提示两组数据存在显著差异")
ranksum pmng_class1, by(orient)
di("独立样本t检验，<0.05，提示两组数据存在显著差异")
ttest nmng_class1, by(orient)

// 不同课程内容下，非协作话轮数量、比例的差异
// 合并非协作话轮
cd "$textdir\2_analysis\1_Class"
use mng_class1, clear
keep if mng == 3
gen nmng_class1_others = Nmng_class1 - nmng_class1
gen pmng_class1_others = 1 - pmng_class1
foreach i in n p {
	gr box `i'mng_class1_others, over(orient)
	cd "$desdir\2_Discourse\1_Class"
	gr export "orient_`i'mng_class1_others.png", as(png) replace
	di("sw正态性检验，＜0.1提示两组数据不服从正态分布")
	swilk `i'mng_class1_others if orient == 1
	swilk `i'mng_class1_others if orient == 2
	di("方差齐性检验，＜0.1提示两组数据方差不齐")
	robvar `i'mng_class1_others, by(orient)
}

// 检验结果：ncfl和pcfl方差齐性
cd "$textdir\2_analysis\1_Class"
use mng_class1, clear
keep if mng == 3
gen nmng_class1_others = Nmng_class1 - nmng_class1
gen pmng_class1_others = 1 - pmng_class1
di("独立样本t检验，<0.05，提示两组数据存在显著差异")
ttest nmng_class1_others, by(orient)
di("独立样本t检验，<0.05，提示两组数据存在显著差异")
ttest pmng_class1_others, by(orient)

*------ 1.2 时间趋势检验
// 课次与冲突话轮数量、比例的相关
cd "$textdir\2_analysis\1_Class"
use cfl_class0, clear
foreach i in ncfl_group0 pcfl_group0 {


/* ================================================== */
/* ================================================== */
*--- 2 小组层面
/* ================================================== */
/* ================================================== */

*------ 2.1 第4组和7组冲突话轮数量的差异
cd "$textdir\2_analysis\2_Group"
use cfl_group0, clear
keep if group == 4 | group == 7 
foreach i in ncfl_group0 pcfl_group0 {
	gr box `i', over(group) by(cfl)
	cd "$desdir\2_Discourse\2_Group"
	gr export "4-7_`i'.png", as(png) replace
}
// 按小组，合并所有课次的冲突/非冲突话轮数量
bys group cfl: egen Ncfl = total(ncfl_group0)
duplicates drop group cfl, force 
// R×C χ2检验
tabi 425 394\606 534, expected row all exact

// 按课次配对，检验第4组和7组的冲突话轮数量、比例差异
foreach i in ncfl_group0 pcfl_group0 {
	cd "$textdir\2_analysis\2_Group"
	use cfl_group0, clear
	keep if group == 4 | group == 7 
	keep if cfl == 1
	drop if date == 2 | date == 3 | date == 9
	keep date group `i' 
	spread group `i'
	gen d_`i' = `i'7 - `i'4
	gr box `i'7 `i'4
	cd "$desdir\2_Discourse\2_Group"
	gr export "4-7_`i'_paired.png", as(png) replace
 	di("sw正态性检验，＜0.1提示两组差值不服从正态分布")
	swilk d_`i'
	di("配对样本t检验，＜0.05，提示两组数据存在显著差异")
	ttest `i'7 == `i'4
}

*------ 2.2 第4组和7组不同冲突类别数量的差异
cd "$textdir\2_analysis\2_Group"
use cfl_group1, clear
keep if group == 4 | group == 7 
foreach i in ncfl_group1 pcfl_group1 {
	gr box `i', over(group) by(cfl)
	cd "$desdir\2_Discourse\2_Group"
	gr export "4-7_`i'.png", as(png) replace
}
// 按小组，合并所有课次的不同类别冲突话轮数量
bys group cfl: egen Ncfl = total(ncfl_group1)
duplicates drop group cfl, force 
// R×C χ2检验
tabi 131 53 16\336 160 17, expected row all exact
tabi 131 53\336 160, expected row all exact
tabi 131 16\336 17, expected row all exact
tabi 53 16\160 17, expected row all exact

// 按课次配对，检验第4组和7组任务冲突话轮数量、比例差异
foreach i in ncfl_group1 pcfl_group1 {
	foreach j in 1 2 3 {
		cd "$textdir\2_analysis\2_Group"
		use cfl_group1, clear
		keep if group == 4 | group == 7 
		keep if cfl == `j'
		drop if date == 2 | date == 3 | date == 9
		keep date group `i' 
		spread group `i'
		gen d_`i' = `i'7 - `i'4
		gr box `i'7 `i'4
		cd "$desdir\2_Discourse\2_Group"
		gr export "4-7_`i'_`j'_paired.png", as(png) replace
	 	di("sw正态性检验，＜0.1提示两组差值不服从正态分布")
		swilk d_`i'
		di("配对样本t检验，＜0.05，提示两组数据存在显著差异")
		ttest `i'7 == `i'4
	}
}

*------ 2.3 第4组和7组不同冲突管理策略的差异
cd "$textdir\2_analysis\2_Group"
use mng_group1, clear
keep if group == 4 | group == 7 
foreach i in nmng_group1 pmng_group1 {
	gr box `i', over(group) by(mng)
	cd "$desdir\2_Discourse\2_Group"
	gr export "4-7_`i'.png", as(png) replace
}

// 按小组，合并所有课次的不同类别冲突管理话轮数量
bys group mng: egen Nmng = total(nmng_group1)
duplicates drop group mng, force 
// R×C χ2检验
tabi 18 50 42 36\71 43 111 95, expected row all exact
tabi 18 50\71 43, expected row all exact
tabi 18 42\71 111, expected row all exact
tabi 18 36\71 95, expected row all exact
tabi 50 42\43 111, expected row all exact
tabi 50 36\43 95, expected row all exact
tabi 42 36\111 95, expected row all exact
// 结果显示，4组在顺从策略的话轮更多，检验其他3类策略的差异
tabi 18 42 36\71 111 95, expected row all exact


// 按课次配对，检验第4组和7组不同类别冲突管理话轮数量、比例差异
foreach i in nmng_group1 pmng_group1 {
	foreach j in 1 2 3 4 {
		cd "$textdir\2_analysis\2_Group"
		use mng_group1, clear
		keep if group == 4 | group == 7 
		keep if mng == `j'
		drop if date == 2 | date == 3 | date == 9
		keep date group `i' 
		spread group `i'
		gen d_`i' = `i'7 - `i'4
		gr box `i'7 `i'4
		cd "$desdir\2_Discourse\2_Group"
		gr export "4-7_`i'_`j'_paired.png", as(png) replace
	 	di("sw正态性检验，＜0.1提示两组差值不服从正态分布")
		swilk d_`i'
		di("配对样本t检验，＜0.05，提示两组数据存在显著差异")
		if `j' == 4 {
			signrank `i'7 = `i'4
		}
		else ttest `i'7 == `i'4
	}
}

/* ================================================== */
*------ 3.3 个人层面
/* ================================================== */

// 时间趋势检验
cd "$textdir\2_analysis\3_Sub"
use cfl_sub0, clear
keep if cfl == 1
cd "$desdir\2_Discourse\3_Sub"
scatter ncfl_sub0 date
gr export "ncfl_sub0.png", as(png) replace
replace pcfl = . if ncfl_sub0 < 2
scatter pcfl_sub0 date 
gr export "pcfl_sub0.png", as(png) replace
corr ncfl_sub0 pcfl_sub0 date

/* ================================================== */
*--- 5 冲突话轮数量、冲突管理质量与任务单评价、小组评价的关系
/* ================================================== */

*------ 5.1 合并有效话轮、冲突话轮、不同类别冲突话轮、不同类别冲突管理话轮
cd "$textdir\2_analysis\3_Sub"
use cfl_sub0, clear
keep if cfl > 0 
drop cfl N*
merge 1:m date sub using cfl_sub1, nogen keepusing(cfl n* p*)
merge m:m date sub using mng_sub1, nogen keepusing(mng n* p*)
rename (ncfl_sub0 pcfl_sub0 ncfl_sub1 pcfl_sub1 nmng_sub1 pmng_sub1) (Ncfl Pcfl ncfl pcfl nmng pmng)
label var Ncfl "冲突话轮总数"
label var Pcfl "冲突话轮比例"
label var ncfl "不同类别冲突话轮数量"
label var pcfl "不同类别冲突话轮比例"
label var nmng "不同类别冲突管理话轮数量"
label var pmng "不同类别冲突管理话轮比例"
local vars "date sub cfl ncfl pcfl mng nmng pmng Ncfl Pcfl"
order `vars'
local vars "date sub cfl mng"
sor `vars'

// 链接小组评价和任务单评价得分
cd "$masterdir"
merge m:1 date sub using 5_Assess, nogen keep(match) keepusing(item* score*)
save 7_Assess_Cfl, replace

*------ 5.2 冲突话轮数量、比例与任务单评价、小组评价
// 散点图描述冲突话轮数量、比例与评价
cd "$masterdir"
use 7_Assess_Cfl, clear
local vars "score_task score_group score_sub"
foreach i in `vars' {
	foreach j in Ncfl Pcfl {
		scatter `i' `j'
		cd "$desdir\2_Discourse\3_Sub"
		gr export "Scatter_`j'_`i'.png", as(png) replace
	}
}

// 相关分析冲突话轮数量与评价
cd "$desdir\2_Discourse\3_Sub"
estpost correlate Ncfl Pcfl `vars', matrix
esttab using Corr_Score_Cfl.csv, ///
 	unstack not noobs compress nogaps replace star(* 0.1 ** 0.05 *** 0.01) ///
 	b(%8.3f) p(%8.3f) title(esttab_Table: correlation coefficient matrix)

*------ 5.3 不同类别冲突话轮数量、比例与任务单评价、小组评价
local vars "score_task score_group score_sub"
forvalues i = 1/3 {
	cd "$masterdir"
	use 7_Assess_Cfl, clear
	keep if cfl == `i'
	// 散点图描述不同类别冲突话轮数量、比例与评价
	foreach j in `vars' {
		foreach k in ncfl pcfl {
			scatter `j' `k'
			cd "$desdir\2_Discourse\3_Sub"
			gr export "Scatter_`k'_`j'_`i'.png", as(png) replace
		}
	}

	// 相关分析冲突话轮数量与评价
	cd "$desdir\2_Discourse\3_Sub"
	estpost correlate ncfl pcfl `vars', matrix
	esttab using Corr_Score_Cfl_`i'.csv, ///
	 	unstack not noobs compress nogaps replace star(* 0.1 ** 0.05 *** 0.01) ///
	 	b(%8.3f) p(%8.3f) title(esttab_Table: correlation coefficient matrix)
}

*------ 5.4 不同类别冲突管理话轮数量、比例与任务单评价、小组评价
// 散点图描述不同类别冲突管理话轮数量、比例与评价
local vars "score_task score_group score_sub"
forvalues i = 1/4 {
	cd "$masterdir"
	use 7_Assess_Cfl, clear
	keep if mng == `i'
	// 散点图描述不同类别冲突管理话轮数量与评价
	foreach j in `vars' {
		foreach k in nmng pmng {						
			scatter `j' `k'
			cd "$desdir\2_Discourse\3_Sub"
			gr export "Scatter_`k'_`j'_`i'.png", as(png) replace
		}
	}

	// 相关分析不同类别冲突管理话轮数量与评价
	cd "$desdir\2_Discourse\3_Sub"
	estpost correlate nmng pmng `vars', matrix
	esttab using Corr_Score_Mng_`i'.csv, ///
	 	unstack not noobs compress nogaps replace star(* 0.1 ** 0.05 *** 0.01) ///
	 	b(%8.3f) p(%8.3f) title(esttab_Table: correlation coefficient matrix)
}

*------ 4.1 冲突管理质量【（协作-其他）/其他】与任务单评价、小组评价
cd "$textdir\2_analysis\3_sub"
use mng_sub1, clear
spread mng nmng_sub1
rename (nmng_sub11-nmng_sub14) (mng1 mng2 mng3 mng4)
save mng_sub2, replace

forvalues i = 1/4 {
	use mng_sub2, clear
	drop if mng`i' == .
	keep date sub Nmng_sub1 mng`i'
	save mng`i', replace
}

use mng_sub2, clear
drop mng* pmng*

forvalues i = 1/4 {
	merge m:1 date sub using mng`i', nogen keepusing(mng`i') 
	replace mng`i' = 0 if mng`i' == .
}

gen mng_qual = (mng3-(mng1+mng2+mng4))/(mng1+mng2+mng4)
gen group_qual = 1
replace group_qual = 0 if mng_qual < 0
duplicates drop date sub, force

// 链接个人冲突话轮数量
cd "$textdir\2_analysis\3_sub"
merge 1:m date sub using cfl_sub1, nogen keep(match) keepusing(ncfl* pcfl*)

// 链接小组评价和任务单评价得分
cd "$masterdir"
merge m:1 date sub using 5_Assess, nogen keep(match)

local vars "score_sub score_group score_task"
foreach i in `vars' {
	scatter mng_qual `i'
	cd "$desdir\2_Discourse\3_Sub"
	gr export "mng_qual_`i'.png", as(png) replace
}

cd "$textdir\2_analysis\3_sub"
estpost correlate mng_qual `vars', matrix
esttab using 9_corr_mng_qual.csv, ///
 	unstack not noobs compress nogaps replace star(* 0.1 ** 0.05 *** 0.01) ///
 	b(%8.3f) p(%8.3f) title(esttab_Table: correlation coefficient matrix)



