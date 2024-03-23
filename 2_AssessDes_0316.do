/*==================================================

Project:			master thesis
Author:				liuziyu
Create Date:		2024.02

--------------------------------------------------

Note:	问题解决活动成果评价；
			任务单评价；
			小组自评与互评；
			视频评价；
		评分数据读取、另存；
		缺失值分析与插补；
		描述；
		
==================================================*/

*--- 0: 清空内存，定义路径
clear 
cls 

global dir "D:\Onedrive\OneDrive - mail.bnu.edu.cn\0 Academic\1_Graduation\1_毕业设计_202306\1_data"
global mydir "$dir\1_mydata"
global masterdir "$dir\2_mymaster"
global desdir "$dir\3_mydescription"

set scheme plotplain, perm

*--- 3 描述统计
*------ 3.1 截面
cd "$masterdir"
use 3_Assess, clear

// 全班层面
cd "$desdir\1_Assess"
foreach i in item_best item_worst {
	tab `i'
	hist `i', by(group) freq
	gr export "`i'_group.png", as(png) replace
	hist `i', freq
	gr export "`i'_class.png", as(png) replace
}

foreach i in score_sub score_group score_task {
	tab `i'
	/* bytwoway(hist `i' date), by(date) */
	mkdensity `i', by(date) 
	gr export "`i'Density_date.png", as(png) replace
}

*------ 3.2 时间趋势
