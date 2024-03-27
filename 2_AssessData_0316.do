cls

/*==================================================

Project:		master thesis - assess
Author:			liuziyu
Create Date:	2024.2
Edit Date:		2024.3.27

--------------------------------------------------

This script is for:	
	- 读取学习结果原始数据
	- 缺失值插补
	- 合成总分：任务单评价、小组评价、个人评价
	- 链接任务单、小组评价、个人评价
	- 保存综合变量到路径：mymaster
==================================================*/

*--- 0: 清空内存，定义路径
clear 

global dir "D:\Onedrive\OneDrive - mail.bnu.edu.cn\0 Academic\1_Graduation\1_毕业设计_202306\1_data"
	global rawdir "$dir\0_rawdata"
	global mydir "$dir\1_mydata"
		global textdir "$mydir\5_discourse"
	global masterdir "$dir\2_mymaster"
	global desdir "$dir\3_mydescription"

set scheme plotplain, perm

*--- 1.问题解决活动成果评价
*------ 1.1 读取数据
cd "$mydir"
import excel using 4_task_0219, firstrow clear
// 替换缺失值
foreach i of varlist a1_1-b1_10 {
	replace `i' = . if `i' == -9 // -9表示缺席
	gen `i'_1 = `i'
	replace `i'_1 = . if `i'_1 == -9 | `i'_1 == 99 // 99表示缺失值
 	egen `i'_mean = mean(`i'_1)
	replace `i'_1 = `i'_mean if missing(`i'_1)
	replace `i' = `i'_1 if `i' == 99
}

// 计算总分
gen score_1 = (a1_1+a2_1+b1_1)/3
gen score_2 = (a1_2+a2_2+b1_2+b2_2)/4
gen score_3 = (a1_3+a2_3+a3_3+b1_3+b2_3)/5
gen score_4 = (a1_4+a2_4+a3_4+b1_4+b2_4)/3
gen score_5 = (a1_5+a2_5+a3_5+b1_5+b2_5)/5
gen score_6 = (a1_6+a2_6+a3_6+b1_6+b2_6+b3_6)/6
gen score_7 = (a1_7+a2_7+b1_7+b2_7)/4
gen score_8 = (a1_8+a2_8+a3_8+b1_8+b2_8)/5
gen score_9 = (a1_9+a2_9+a3_9+b1_9)/4
gen score_10 = (a1_10+a2_10+b1_10)/3

// 标准化
forvalues i = 1/10 {
	egen st_`i' = std(score_`i')
}

drop a* b*
/* keep if group == 4 | group == 5 | group == 6 | group == 7 */
cd "$mydir"
save 4_task, replace

foreach i in score st {
	cd "$mydir"
	use 4_task, clear
	// 原始得分宽转长
	keep sub name group `i'*
	gather `i'*, variable(date) value(`i'_task)
	gen date_ = 1
	local dates "2 3 4 5 6 7 8 9 10"

	foreach j in `dates' {
		replace date_ = `j' if date == "`i'_`j'"
	}

	drop date name
	rename date_ date 
	sor date group sub
	order date group sub  

	save 4_task_`i', replace
}

merge 1:1 sub date using 4_task_score, nogen keepusing(score_task)
label var st_task "标准化任务单评价"
label var score_task "任务单评价"
erase 4_task_score.dta
erase 4_task.dta
cd "$masterdir"
save 4_Task, replace

*--- 2.小组评价、个人评价
*------ 2.1 读取数据
cd "$mydir"
local dates "1011 1012 1018 1019 1025 1026 1102"
foreach i in `dates' 1108 {
	import excel using 3_assessment_1108, sh(`i') firstrow clear
	gen date = `i'
	save `i'_assess, replace
}

use 1108_assess, clear
foreach i in `dates' {
	ap using `i'_assess
	erase `i'_assess.dta
}

/* keep if group == 4 | group == 5 | group == 6 | group == 7 */
replace date = 3 if date == 1011
replace date = 4 if date == 1012
replace date = 5 if date == 1018
replace date = 6 if date == 1019
replace date = 7 if date == 1025
replace date = 8 if date == 1026
replace date = 9 if date == 1102
replace date = 10 if date == 1108

// 替换缺失值：值为-9的是学生缺席，值为99的是缺失值
local vars "date group sub a1 a2 b1 b2 c1 c2 c3"
keep `vars' 
order `vars'
sor `vars'

local vars "a1 a2"
foreach i in `vars' {
	replace `i' = . if `i' == 99 | `i' == -9
}

local vars "b1 b2 c1 c2 c3"
foreach i in `vars' {
	replace `i' = . if `i' == -9
	gen `i'_1 = `i'
	replace `i'_1 = . if `i'_1 == -9 | `i'_1 == 99
 	egen `i'_mean = mean(`i'_1)
	replace `i'_1 = `i'_mean if missing(`i'_1)
	replace `i' = `i'_1 if `i' == 99
}

gen score_group = (b1+b2)/2
gen score_sub = (c1+c2+c3)/3

egen st_group = std(score_group)
egen st_sub = std(score_sub)

erase 1108_assess.dta

local vars "date group sub a1 a2 score* st*" 
keep `vars'
order `vars'
sor `vars'

label var a1 "表现最佳项目"
label var a2 "表现最差项目"
label var st_group "标准化小组评价"
label var st_sub "标准化个人评价"
label var score_group "小组评价"
label var score_sub "个人评价"

rename (a1 a2) (item_best item_worst)

// 合并任务评价和小组评价
cd "$masterdir"
merge 1:1 date sub using 4_Task, nogen 
order date sub group score* st*
sor date sub
save 5_Assess, replace
