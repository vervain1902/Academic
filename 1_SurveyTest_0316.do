cls

/*==================================================

Project:		master thesis - survey
Author:			liuziyu
Create Date:	2024.2
Edit Date:		2024.3.27

--------------------------------------------------

This script is for:	
	- 读取前后测综合变量，检验前测时冲突管理风格差异
	- 检验后测时冲突管理风格差异
	- 检验前后测相同冲突管理风格差异

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

*--- 1: 前测数据处理
*------ 1.1: 差异检验_前测冲突管理风格
cd "$masterdir"
use 1_PreTest, clear
bys style: sum pre_cfl

gen style_1 = "回避" 
replace style_1 = "妥协" if style == 2
replace style_1 = "协作" if style == 3
replace style_1 = "强制" if style == 4

// 箱线图
cd "$desdir\3_Survey"
graph box pre_cfl, over(style_1) ytitle("冲突管理风格得分") 
gr export "Box_PreMng.png", as(png) replace
// q-q图
forvalues i = 1/4 {
	qnorm pre_cfl if style == `i', ytitle("冲突管理风格得分") xtitle("")
	gr export "Q-Q_PreMng`i'.png", as(png) replace
}
// 正态性检验
bys style: swilk pre_cfl
// 方差齐性检验
robvar pre_cfl, by(style)

// 协作维度非正态，方差不齐，故采用k-w非参数检验
kwallis2 pre_cfl, by(style)

*--- 2: 后测数据处理
*------ 2.8: 差异检验_后测冲突管理风格
cd "$masterdir"
use 2_PostTest, clear
bys style: sum post_cfl

gen style_1 = "回避" 
replace style_1 = "妥协" if style == 2
replace style_1 = "协作" if style == 3
replace style_1 = "强制" if style == 4

// 箱线图
graph box post_cfl, over(style_1) ytitle("冲突管理风格得分") 
cd "$desdir\3_Survey"
gr export "Box_PostMng.png", as(png) replace
// q-q图
forvalues i = 1/4 {
	qnorm post_cfl if style == `i', ytitle("冲突管理风格得分") xtitle("")
	gr export "Q-Q_PostMng`i'.png", as(png) replace
}
// 正态性检验
bys style: swilk post_cfl
// 方差齐性检验
robvar post_cfl, by(style)

// 强制维度非正态，方差不齐，故采用k-w非参数检验
kwallis2 post_cfl, by(style)

*------ 3.3: 前后测相同风格得分差异检验
cd "$masterdir"
use 3_Test, clear
// 正态性检验、方差齐性检验
forvalues i = 1/4 {
	cd "$masterdir"
	use 3_Test, clear
	keep if style == `i'
	sum *cfl
	gr box *cfl
	cd "$desdir\3_Survey"
	gr export "Box_Mng`i'.png", as(png) replace
	gen d_`i' = post_cfl - pre_cfl
	swilk d_`i'
	qnorm d_`i'
	gr export "Q-Q_Mng`i'.png", as(png) replace
}

// t检验
foreach i in 1 2 4 {
	cd "$masterdir"
	use 3_Test, clear
	keep if style == `i'
	ttest post_cfl == pre_cfl
}

cd "$masterdir"
use 3_Test, clear
keep if style == 3
signrank post_cfl = pre_cfl
