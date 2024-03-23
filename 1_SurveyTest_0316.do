/*

Project:			master thesis
Author:				liuziyu
Create Date:		2024.02

--------------------------------------------------

This script is for:	
  	前后测同一冲突管理风格差异检验；
	前后测不同冲突管理风格分别差异检验；

*/

*--- 0: 清空内存，定义路径
clear 
cls 

global dir "D:\Onedrive\OneDrive - mail.bnu.edu.cn\0 Academic\1_Graduation\1_毕业设计_202306\1_data"
	global rawdir "$dir\0_rawdata"
	global mydir "$dir\1_mydata"
		global textdir "$mydir\5_discourse"
	global masterdir "$dir\2_mymaster"
	global desdir "$dir\3_mydescription"

set scheme tufte, perm

*--- 1: 前测数据处理
*------ 1.9: 差异检验_前测冲突管理风格
cd "$masterdir"
use 1_pretest, clear
bys style: sum pre_cfl

gen style_1 = "回避" 
replace style_1 = "妥协" if style == 2
replace style_1 = "协作" if style == 3
replace style_1 = "强制" if style == 4

// 箱线图
graph box pre_cfl, over(style_1) ytitle("冲突管理风格得分") 
cd "$graphdir"
gr export "pre_cfl.png", as(png) replace
// q-q图
forvalues i = 1/4 {
	qnorm pre_cfl if style == `i', ytitle("冲突管理风格得分") xtitle("")
	gr export "q-q_pre_cfl_`i'.png", as(png) replace
}
// 正态性检验
bys style: swilk pre_cfl
// 方差齐性检验
robvar pre_cfl, by(style)

// 强制维度非正态，方差不齐，故采用k-w非参数检验
kwallis2 pre_cfl, by(style)

*--- 2: 后测数据处理
*------ 2.8: 差异检验_后测冲突管理风格
cd "$masterdir"
use 2_posttest, clear
bys style: sum post_cfl

gen style_1 = "回避" 
replace style_1 = "妥协" if style == 2
replace style_1 = "协作" if style == 3
replace style_1 = "强制" if style == 4

// 箱线图
graph box post_cfl, over(style_1) ytitle("冲突管理风格得分") 
cd "$graphdir"
gr export "post_cfl.png", as(png) replace
// q-q图
forvalues i = 1/4 {
	qnorm post_cfl if style == `i', ytitle("冲突管理风格得分") xtitle("")
	gr export "q-q_post_cfl_`i'.png", as(png) replace
}
// 正态性检验
bys style: swilk post_cfl
// 方差齐性检验
robvar post_cfl, by(style)

// 强制维度非正态，方差不齐，故采用k-w非参数检验
kwallis2 post_cfl, by(style)

*------ 3.3: 前后测相同风格得分差异检验
cd "$masterdir"
use 3_alltest, clear

forvalues i = 1/4 {
	cd "$masterdir"
	use 3_alltest, clear
	keep if style == `i'
	sum *cfl
	gr box *cfl
	cd "$graphdir"
	gr export "cfl_`i'.png", as(png) replace
	gen d_`i' = post_cfl - pre_cfl
	swilk d_`i'
	qnorm d_`i'
	gr export "q-q_cfl_`i'.png", as(png) replace
}

foreach i in 1 2 4 {
	cd "$masterdir"
	use 3_alltest, clear
	keep if style == `i'
	ttest post_cfl = pre_cfl
}

cd "$masterdir"
use 3_alltest, clear
keep if style == 3
signrank post_cfl = pre_cfl
