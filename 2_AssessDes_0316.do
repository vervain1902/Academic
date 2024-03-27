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

*--- 1 描述统计
*------ 1.1 截面
// 个人评价：表现最佳和最差的项目
foreach i in item_best item_worst {
	cd "$masterdir"
	use 5_Assess, clear
	tab `i'
	hist `i', by(group) freq
	cd "$desdir\1_Assess\2_Group"
	gr export "Hist_`i'_group.png", as(png) replace
	hist `i', freq
	cd "$desdir\1_Assess\1_Class"
	gr export "Hist_`i'_class.png", as(png) replace
}

// 其他：个人评价、小组评价、任务单评价
foreach i in sub group task {
	foreach j in st score {
		cd "$masterdir"
		use 5_Assess, clear
		// 计算所有课次的个人均分，输出密度图
		bys sub: egen avg_`j'_`i' = mean(`j'_`i')
		kdensity avg_`j'_`i'
		cd "$desdir\1_Assess\1_Class"
		gr export "Density_Avg_`j'_`i'.png", as(png) replace
		mkdensity avg_`j'_`i', by(group) // 分小组输出密度图
		cd "$desdir\1_Assess\2_Group"
		gr export "Density_Avg_`j'_`i'_bygroup.png", as(png) replace
		// 计算所有课次的小组均分，输出密度图
		bys group: egen avg_group_`j'_`i' = mean(`j'_`i')
		kdensity avg_group_`j'_`i'
		cd "$desdir\1_Assess\1_Class"
		gr export "Density_Avg_`j'_`i'_group.png", as(png) replace	
	}
}

*------ 1.2 时间趋势
foreach i in sub group task {
	foreach j in st score {
		cd "$masterdir"
		use 5_Assess, clear
		// 分课次计算班级均分，输出折线图
		bys date: egen mean_`j'_`i' = mean(`j'_`i')
		scatter mean_`j'_`i' date, legend(subtitle(""))
		cd "$desdir\1_Assess\1_Class"
		gr export "Scatter_ClassMean_`j'_`i'.png", as(png) replace

		forvalues k = 4/7 {
			cd "$masterdir"
			use 5_Assess, clear
			keep if group == `k'
			// 分小组、分课次计算均分，输出折线图
			bys date: egen mean_`j'_`i' = mean(`j'_`i')
			scatter mean_`j'_`i' date, legend(subtitle(""))	
			cd "$desdir\1_Assess\2_Group"
			gr export "Scatter_GroupMean_`j'_`i'_`k'.png", as(png) replace
		}
	}
}
