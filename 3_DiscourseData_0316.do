cls

/*==================================================

Proiect:		master thesis - discourse data preprocess
Author:			liuziyu
Create Date:	2024.02
Edit Date:		2024.3.16

--------------------------------------------------

This script is for: 
	读取各组话语数据；
	合并所有话语数据；
	链接话语数据与任务单评价、小组评价数据；
		
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

*--- 1: 读取文本编码数据
*------ 1.1: 读取第4组文件
local dates "5 6 7 8 9 10"
foreach i in 4 `dates' {
	cd "$textdir\0_textdata"
	import excel using `i'_discourse, sheet(4_code) firstrow clear
	gen group = 4 	// 生成小组id
	gen date = `i' 	// 生成日期

	// 用编号替换座位号
	if `i' != 4 {
		gen speaker_ = speaker
		replace speaker_ = "s3" if speaker == "s4"
		replace speaker_ = "s4" if speaker == "s3"
		drop speaker 
		rename speaker_ speaker
	} 	

	destring apt* reg*, replace force // 删除多重编码
	cd "$textdir\1_discourse"
	save g4_`i'_discourse, replace 	// 保存数据文件
}

use g4_4_discourse, clear
foreach i in `dates' {
	ap using g4_`i'_discourse, force
	erase g4_`i'_discourse.dta
}
erase g4_4_discourse.dta
drop L-R
save g4_discourse, replace

*------ 1.2: 读取第7组文件
local dates "3 4 5 6 7 8 10"
foreach i in 2 `dates' {
	cd "$textdir\0_textdata"
	import excel using `i'_discourse, sheet(7_code) firstrow clear
	gen group = 7 	// 生成小组id
	gen date = `i' 	// 生成日期

	destring apt* reg*, replace force 	// 删除多重编码
	cd "$textdir\1_discourse"
	save g7_`i'_discourse, replace 	// 保存数据文件
}

use g7_2_discourse, clear
foreach i in `dates' {
	ap using g7_`i'_discourse, force
	erase g7_`i'_discourse.dta
}
erase g7_2_discourse.dta
save g7_discourse, replace

*------ 1.3: 读取第6组文件
local dates "2 3"
foreach i in 1 `dates' {
	cd "$textdir\0_textdata"
	import excel using `i'_discourse, sheet(6_code) firstrow clear
	gen group = 6 	// 生成小组id
	gen date = `i' 	// 生成日期

	// 用编号替换座位号
	if `i' == 2 {
		gen speaker_ = speaker
		replace speaker_ = "s3" if speaker == "s2"
		replace speaker_ = "s2" if speaker == "s3"
		drop speaker 
		rename speaker_ speaker
	} 
	else if `i' == 3 {
		gen speaker_ = speaker
		replace speaker_ = "s2" if speaker == "s4"
		drop speaker 
		rename speaker_ speaker
	} 	
	destring apt* reg*, replace force 	// 删除多重编码
	cd "$textdir\1_discourse"
	save g6_`i'_discourse, replace 	// 保存数据文件
}
use g6_1_discourse, clear
foreach i in 2 3 {
	ap using g6_`i'_discourse, force
	erase g6_`i'_discourse.dta
}
erase g6_1_discourse.dta
save g6_discourse, replace

*------ 1.4: 读取第5组文件
cd "$textdir\0_textdata"
import excel using 9_discourse, sheet(5_code) firstrow clear
gen group = 5 // 生成小组id
gen date = 9 // 生成日期
destring apt* reg*, replace force // 删除多重编码
cd "$textdir\1_discourse" 
save g5_discourse, replace // 保存数据文件

*------ 1.5: 合并所有话轮数据文件并另存
cd "$textdir\1_discourse"
use g5_discourse, clear
foreach i in 4 6 7 {
	ap using g`i'_discourse, force
}

drop if relate == 9 // 删除整段的无效话轮
drop if speaker == "t" | speaker == "t'" | speaker == "t2" | speaker == "t‘" // 删除教师话轮

// 根据第一次课的speaker编号，生成sub编号
gen sub = .
forvalues i = 1/7 {
	forvalues j = 1/4 {
		replace sub = 4*(`i'-1)+`j' if group == `i' & speaker == "s`j'"
	}
}

replace mng_t = 2 if mng_t == 3.1
gen mng_t_ = mng_t
replace mng_t_ = 3 if mng_t > 2 & mng_t < 4
gen orient = 1
replace orient = 2 if date < 9 & date > 4
replace apt_t = 1 if apt_t < 2 
replace apt_t = 2 if apt_t < 3
gen reg = 1
replace reg = 2 if reg_t > 2

local vars "apt_t cfl_t mng_t_"
rename (`vars') (apt cfl mng)

drop reg_t mng_t
label var group "小组编号"
label var sub "个人编号"
label var relate "话轮有效性"
label define relate 0 "无关话轮" 1 "相关话轮" 
label var cfl "冲突类别"
label define cfl 0 "非冲突话轮" 1 "任务冲突" 2 "过程冲突" 3 "关系冲突"
label var mng "冲突管理策略"
label define mng 1 "回避" 2 "顺从" 3 "协作" 4 "竞争"
label var reg "调节导向"
label define reg 1 "问题导向" 2 "组织导向"
label var apt "认知层次"
label define apt 1 "交流共同体" 2 "客观知识" 3 "逻辑思维"
label var orient "课程内容"
label define orient 1 "学科知识" 2 "合作技能"
foreach i in relate cfl mng reg apt orient {
	label values `i' `i'
}

local vars "date group sub relate cfl mng apt reg orient Ep"
keep `vars'
order `vars'
sor `vars'

// 链接任务单评价、小组评价
cd "$masterdir"
merge m:1 date sub using 5_Assess, nogen keep(match)

save 6_Text, replace

