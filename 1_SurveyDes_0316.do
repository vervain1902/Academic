/*

Project:			master thesis
Author:				liuziyu
Create Date:		2024.02

--------------------------------------------------

This script is for:	
  	描述性统计；
  	相关分析；
  	信效度检验；

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

set scheme plotplain, perm

*--- 1: 前测数据处理
*------ 1.5: 前测描述统计与相关分析
cd "$mydir"
use 1_pretest_detail, clear
local vars "age score_1 EMO EXT OPN AGR CON pre_CFL_*"
estpost sum `vars'
cd "$desdir\3_Survey"
esttab using 1_des_pretest.csv, ///
	cells("count mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") ///
	noobs replace title(esttab_Table: Descriptive statistics)
estpost correlate `vars', matrix
esttab using 2_corr_pretest.csv, ///
	unstack not noobs compress nogaps replace star(* 0.1 ** 0.05 *** 0.01) ///
	b(%8.3f) p(%8.3f) title(esttab_Table: correlation coefficient matrix)

*------ 1.6: 信效度检验
*---------: 1.6.1: 信度检验_计算大五人格问卷、冲突管理风格问卷alpha值
alpha a11d3 a11d6 a11d16 a11d17 a11d26 a11d27
alpha a11d2 a11d10 a11d11 a11d13 a11d19 a11d24
alpha a11d1 a11d4 a11d5 a11d7 a11d12 a11d14 a11d15 a11d20 a11d22 a11d23 a11d28
alpha a11d8 a11d9 a11d18 a11d21 a11d25 a11d27
alpha a11d1-a11d28
alpha a4d1-a10d5

*---------: 1.6.2: 效度检验_CFA
cfa1 a11d3 a11d6 a11d16 a11d17 a11d26 a11d27
sem(CFL_1 -> a11d3 a11d6 a11d16 a11d17 a11d26 a11d27)
estat gof, stats(all)
sem(CFL_2 -> a11d2 a11d10 a11d11 a11d13 a11d19 a11d24)
estat gof, stats(all)
sem(CFL_3 -> a11d1 a11d4 a11d5 a11d7 a11d12 a11d14 a11d15 a11d20 a11d22 a11d23 a11d28)
estat gof, stats(all)
sem(CFL_4 -> a11d8 a11d9 a11d18 a11d21 a11d25 a11d27)
estat gof, stats(all)


*--- 2: 后测数据处理
*------ 2.4: 后测描述统计与相关分析
cd "$mydir"
use 2_posttest_detail, clear
cd "$desdir\3_Survey"
local vars "age score_1 score_2 EMO EXT OPN AGR CON post_CFL_*"
estpost sum `vars'
esttab using 3_des_posttest.csv, ///
 	cells("count mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") ///
 	noobs replace title(esttab_Table: Descriptive statistics)
estpost correlate `vars', matrix
esttab using 4_corr_posttest.csv, ///
 	unstack not noobs compress nogaps replace star(* 0.1 ** 0.05 *** 0.01) ///
 	b(%8.3f) p(%8.3f) title(esttab_Table: correlation coefficient matrix)

*------ 2.5: 信效度检验
*---------: 2.5.1: 信度检验_计算大五人格问卷、冲突管理风格问卷alpha值
alpha a2d1-a2d28

*---------: 2.5.2: 效度检验_因子分析
factor a2d1-a2d28, factors(4) pcf
