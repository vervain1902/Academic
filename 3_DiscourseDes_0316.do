/*==================================================

Proiect:		master thesis
Author:			liuziyu
Create Date:	2024.02
Edit Date:		2024.3.16

--------------------------------------------------

This script is for: 
	全班层面描述统计；
		截面；时间趋势；
	小组层面描述统计；
		截面；时间趋势；
	个人层面描述统计；
		截面；时间趋势；
		
==================================================*/

*--- 0: 清空内存，定义路径
clear 
cls 

global dir "D:\Onedrive\OneDrive - mail.bnu.edu.cn\0 Academic\1_Graduation\1_毕业设计_202306\1_data"
	global rawdir "$dir\0_rawdata"
	global mydir "$dir\1_mydata"
		global textdir "$mydir\5_discourse"
	global masterdir "$dir\2_mymaster"
	global desdir "$dir\3_mydescription"

set scheme plotplain, perm

*--- 2: 描述统计
*------ 2.1 全班层面
cd "$masterdir"
use 6_Text, clear

*--------- 2.1.1 截面描述：有效话轮、冲突话轮、冲突管理话轮、认知层次、调节类别
local vars "relate cfl"
foreach i in `vars' {
	tab `i'
}

local vars "cfl mng apt reg"
foreach i in `vars' {
	tab `i' if `i' > 0
}

*--------- 2.1.2 时间趋势
// 分课次，计算有效话轮、冲突话轮数量和比例
foreach i in relate cfl {
	cd "$masterdir"
	use 6_Text, clear
	replace `i' = 1 if `i' > 0
	local vars "date `i'"
	sor `vars'
	egen group_id = group(`vars')
	egen n`i'_class0 = total(1), by(group_id)
	summarize n`i'_class0, detail
	local q1 = r(p25)
	local q3 = r(p75)
	local iqr = `q3' - `q1'
	local threshold = `q3' + 1.5 * `iqr'
	replace n`i'_class0 = `threshold' if n`i'_class0 > `threshold'
	local threshold = `q1' - 1.5 * `iqr'
	replace n`i'_class0 = `threshold' if n`i'_class0 < `threshold'
	egen N`i'_class0 = total(1), by(date)
	gen p`i'_class0 = n`i'_class0 / N`i'_class0

	drop group_id

	duplicates drop `vars', force
	keep `vars' *_class0 orient
	// 保存全班层面的分课次有效话轮、冲突话轮数量和比例
	cd "$textdir\2_analysis\1_Class"
	save `i'_class0, replace

	// 数量、比例与课次的散点图
	foreach j in p n {		
		bytwoway(scatter `j'`i'_class0 date), ///
			by(`i') legend(subtitle(""))
		cd "$desdir\2_Discourse\1_Class"
		gr export "Scatter_`j'`i'0.png", as(png) replace
	}

	// 有效话轮、冲突话轮数量、比例与课次的相关矩阵
	keep if `i' == 1
	estpost correlate n`i'_class0 p`i'_class0 date, matrix
	esttab using Corr_`i'_class0.csv, ///
	 	unstack not noobs compress nogaps replace star(* 0.1 ** 0.05 *** 0.01) ///
	 	b(%8.3f) p(%8.3f) title(esttab_Table: correlation coefficient matrix)
}

// 分课次，计算不同类别冲突话轮、不同类别冲突管理话轮数量和比例
foreach i in cfl mng {
	cd "$masterdir"
	use 6_Text, clear
	drop if `i' == 0 | `i' == .
	local vars "date `i'"
	sor `vars'
	egen group_id = group(`vars')
	egen n`i'_class1 = total(1), by(group_id)
	summarize n`i'_class1, detail
	local q1 = r(p25)
	local q3 = r(p75)
	local iqr = `q3' - `q1'
	local threshold = `q3' + 1.5 * `iqr'
	replace n`i'_class1 = `threshold' if n`i'_class1 > `threshold'
	local threshold = `q1' - 1.5 * `iqr'
	replace n`i'_class1 = `threshold' if n`i'_class1 < `threshold'
	egen N`i'_class1 = total(1), by(date)
	gen p`i'_class1 = n`i'_class1 / N`i'_class1
	drop group_id

	duplicates drop `vars', force
	keep `vars' *_class1 orient
	cd "$textdir\2_analysis\1_Class"
	save `i'_class1, replace

	// 数量、比例与课次的散点图
	foreach j in p n {	
		bytwoway(scatter `j'`i'_class1 date), ///
			by(`i') legend(subtitle(""))
		cd "$desdir\2_Discourse\1_Class"
		gr export "Scatter_`j'`i'1.png", as(png) replace
	}
}

// 数量、比例与课次的相关矩阵
cd "$textdir\2_analysis\1_Class"
use cfl_class1, clear
keep if cfl == 1
estpost correlate ncfl_class1 pcfl_class1 date, matrix
esttab using Corr_cfl_class1.csv, ///
 	unstack not noobs compress nogaps replace star(* 0.1 ** 0.05 *** 0.01) ///
 	b(%8.3f) p(%8.3f) title(esttab_Table: correlation coefficient matrix)

cd "$textdir\2_analysis\1_Class"
use mng_class1, clear
keep if mng == 3
estpost correlate nmng_class1 pmng_class1 date, matrix
esttab using Corr_mng_class1.csv, ///
 	unstack not noobs compress nogaps replace star(* 0.1 ** 0.05 *** 0.01) ///
 	b(%8.3f) p(%8.3f) title(esttab_Table: correlation coefficient matrix)

*------ 2.2: 小组层面
cd "$masterdir"
use 6_Text, clear

*--------- 2.2.1 截面描述
// 有效话轮
tab relate group
// 冲突话轮
tab cfl group
tab cfl group if cfl > 0
// 冲突管理策略
tab mng group if mng > 0

// 分小组，描述有效话轮、冲突话轮数量和比例


// 分小组，描述任务冲突话轮、协作策略话轮数量和比例

*--------- 2.2.2 时间趋势
// 分课次、小组，计算有效话轮、冲突话轮数量和比例
foreach i in relate cfl {
	cd "$masterdir"
	use 6_Text, clear

	replace `i' = 1 if `i' > 0
	local vars "date group `i'"
	sor `vars'
	egen group_id = group(`vars')
	egen n`i'_group0 = total(1), by(group_id)
	summarize n`i'_group0, detail
	local q1 = r(p25)
	local q3 = r(p75)
	local iqr = `q3' - `q1'
	local threshold = `q3' + 1.5 * `iqr'
	replace n`i'_group0 = `threshold' if n`i'_group0 > `threshold'
	local threshold = `q1' - 1.5 * `iqr'
	replace n`i'_group0 = `threshold' if n`i'_group0 < `threshold'
	egen N`i'_group0 = total(1), by(date group)
	gen p`i'_group0 = n`i'_group0 / N`i'_group0
	drop group_id

	duplicates drop `vars', force 
	keep `vars' *_group0 orient
	cd "$textdir\2_analysis\2_Group"
	save `i'_group0, replace

	foreach j in 4 7 {
		cd "$textdir\2_analysis\2_Group"
		use `i'_group0, clear
		keep if group == `j' 
		foreach k in n p {
			bytwoway(scatter `k'`i'_group0 date), ///
				by(`i') legend(subtitle(""))
			cd "$desdir\2_Discourse\2_Group"
			gr export "Scatter_`k'`i'_`j'0.png", as(png) replace
		}

		// 数量、比例与课次的相关矩阵
		keep if `i' == 1
		estpost correlate n`i'_group0 p`i'_group0 date, matrix
		esttab using Corr_`i'_group0_`j'.csv, ///
		 	unstack not noobs compress nogaps replace star(* 0.1 ** 0.05 *** 0.01) ///
		 	b(%8.3f) p(%8.3f) title(esttab_Table: correlation coefficient matrix)
	}
}

// 分课次、小组，计算不同类别冲突话轮、不同类别冲突管理话轮数量和比例
foreach i in cfl mng {
	cd "$masterdir"
	use 6_Text, clear

	drop if `i' == 0 | `i' == .
	local vars "date group `i'"
	sor `vars'
	egen group_id = group(`vars')
	egen n`i'_group1 = total(1), by(group_id)
	summarize n`i'_group1, detail
	local q1 = r(p25)
	local q3 = r(p75)
	local iqr = `q3' - `q1'
	local threshold = `q3' + 1.5 * `iqr'
	replace n`i'_group1 = `threshold' if n`i'_group1 > `threshold'
	local threshold = `q1' - 1.5 * `iqr'
	replace n`i'_group1 = `threshold' if n`i'_group1 < `threshold'
	egen N`i'_group1 = total(1), by(date group)
	gen p`i'_group1 = n`i'_group1 / N`i'_group1
	drop group_id

	duplicates drop `vars', force 
	keep `vars' *_group1 orient
	cd "$textdir\2_analysis\2_Group"
	save `i'_group1, replace

	foreach j in 4 7 {
		cd "$textdir\2_analysis\2_Group"
		use `i'_group1, clear
		keep if group == `j'
		foreach k in n p {
			bytwoway(scatter `k'`i'_group1 date), ///
				by(`i') legend(subtitle(""))
			cd "$desdir\2_Discourse\2_Group"
			gr export "Scatter_`k'`i'_`j'1.png", as(png) replace
		}


	}
}

// 数量、比例与课次的相关矩阵
foreach i in 4 7 {
	cd "$textdir\2_analysis\2_group"
	use cfl_group1, clear
	keep if group == `i'
	keep if cfl == 1
	estpost correlate ncfl_group1 pcfl_group1 date, matrix
	esttab using Corr_cfl_group1_`i'.csv, ///
	 	unstack not noobs compress nogaps replace star(* 0.1 ** 0.05 *** 0.01) ///
	 	b(%8.3f) p(%8.3f) title(esttab_Table: correlation coefficient matrix)
}

// 数量、比例与课次的相关矩阵
foreach i in 4 7 {
	cd "$textdir\2_analysis\2_group"
	use mng_group1, clear
	keep if group == `i'
	keep if mng == 3
	estpost correlate nmng_group1 pmng_group1 date, matrix
	esttab using Corr_mng_group1_`i'.csv, ///
	 	unstack not noobs compress nogaps replace star(* 0.1 ** 0.05 *** 0.01) ///
	 	b(%8.3f) p(%8.3f) title(esttab_Table: correlation coefficient matrix)
}

*------ 2.3 个人层面
cd "$masterdir"
use 6_Text, clear
*--------- 2.3.1 截面
// 有效话轮
tab relate sub
// 冲突话轮
tab cfl sub
tab cfl sub if cfl > 0
// 冲突管理策略
tab mng sub if mng > 0

*--------- 2.3.2 时间趋势
// 分课次、个人，计算有效话轮、冲突话轮数量和比例
foreach i in cfl {
	cd "$masterdir"
	use 6_Text, clear

	replace `i' = 1 if `i' > 0
	local vars "date sub `i'"
	sor `vars'
	egen group_id = group(`vars')
	egen n`i'_sub0 = total(1), by(group_id)
	summarize n`i'_sub0, detail
	local q1 = r(p25)
	local q3 = r(p75)
	local iqr = `q3' - `q1'
	local threshold = `q3' + 1.5 * `iqr'
	replace n`i'_sub0 = `threshold' if n`i'_sub0 > `threshold'
	local threshold = `q1' - 1.5 * `iqr'
	replace n`i'_sub0 = `threshold' if n`i'_sub0 < `threshold'
	egen N`i'_sub0 = total(1), by(date sub)
	gen p`i'_sub0 = n`i'_sub0 / N`i'_sub0
	drop group_id

	duplicates drop `vars', force 
	keep `vars' *_sub0 orient
	cd "$textdir\2_analysis\3_Sub"
	save `i'_sub0, replace

	foreach j in 13 14 15 16 25 26 27 28 {
		cd "$textdir\2_analysis\3_Sub"
		use `i'_sub0, clear
		keep if sub == `j'
		foreach k in n p {
			bytwoway(scatter `k'`i'_sub0 date), ///
				by(`i') legend(subtitle(""))
			cd "$desdir\2_Discourse\3_Sub"
			gr export "Scatter_`k'`i'_`j'.png", as(png) replace
		}

		// 数量、比例与课次的相关矩阵
		estpost correlate n`i'_sub0 p`i'_sub0 date, matrix
		esttab using Corr_`i'_sub0_`j'.csv, ///
		 	unstack not noobs compress nogaps replace star(* 0.1 ** 0.05 *** 0.01) ///
		 	b(%8.3f) p(%8.3f) title(esttab_Table: correlation coefficient matrix)
	}
}

// 分课次、个人，计算不同类别冲突话轮、不同类别冲突管理话轮数量和比例
foreach i in cfl mng {
	cd "$masterdir"
	use 6_Text, clear

	drop if `i' == 0 | `i' == .
	local vars "date sub `i'"
	sor `vars'
	egen group_id = group(`vars')
	egen n`i'_sub1 = total(1), by(group_id)
	summarize n`i'_sub1, detail
	local q1 = r(p25)
	local q3 = r(p75)
	local iqr = `q3' - `q1'
	local threshold = `q3' + 1.5 * `iqr'
	replace n`i'_sub1 = `threshold' if n`i'_sub1 > `threshold'
	local threshold = `q1' - 1.5 * `iqr'
	replace n`i'_sub1 = `threshold' if n`i'_sub1 < `threshold'
	egen N`i'_sub1 = total(1), by(date sub)
	gen p`i'_sub1 = n`i'_sub1 / N`i'_sub1
	drop group_id

	duplicates drop `vars', force 
	keep `vars' *_sub1 orient
	cd "$textdir\2_analysis\3_Sub"
	save `i'_sub1, replace
	foreach j in 13 14 15 16 25 26 27 28 {
		cd "$textdir\2_analysis\3_Sub"
		use `i'_sub1, clear
		keep if sub == `j'
		foreach k in n p {
			bytwoway(scatter `k'`i'_sub1 date), ///
				by(`i') legend(subtitle(""))
			cd "$desdir\2_Discourse\3_Sub"
			gr export "Scatter_`k'`i'_`j'.png", as(png) replace
		}
		keep if sub == 12 | sub == 13 | sub == 14 | sub ==15
		// 数量、比例与课次的相关矩阵
		estpost correlate n`i'_sub1 p`i'_sub1 date, matrix
		esttab using Corr_`i'_sub1_`j'_4.csv, ///
		 	unstack not noobs compress nogaps replace star(* 0.1 ** 0.05 *** 0.01) ///
		 	b(%8.3f) p(%8.3f) title(esttab_Table: correlation coefficient matrix)
	}
}
