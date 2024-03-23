/*

Project:			master thesis
Author:				liuziyu
Create Date:		2024.02

--------------------------------------------------

This script is for:	
	读取问卷调查前后测数据；
	前后测大五人格、冲突管理风格总分计算；
	合并前后测数据；

*/

*--- 0: 清空内存，定义路径
clear 
cls 

global dir "D:\Onedrive\OneDrive - mail.bnu.edu.cn\0 Academic\1_Graduation\1_毕业设计_202306\1_data"
global mydir "$dir\1_mydata"
global masterdir "$dir\2_mymaster"

set scheme plotplain, perm

*--- 1: 前测数据处理
*------ 1.1: 读取数据
cd "$mydir"
import excel using 1_pretest_0920, sheet(rawdata) firstrow clear

label var age "年龄"
label var gender "性别"
label define gender 1 "male" 2 "female"
label var leader "组长"
label define leader 1 "leader" 0 "non-leader"
label var leader_exp "组长经历"
label define leader_exp 1 "leader" 0 "non-leader"
label var score_1 "前测数学成绩"

egen st_score_1 = std(score_1) // 数学成绩标准化
label var st_score_1 "标准化前测数学成绩"

*------ 1.2: 计算大五人格归一化总分
foreach i in a4d1 a4d3 a4d7 a4d8 a4d9 {
	gen `i'r = 4 - `i'
}

gen EMO_1 = (a4d1r+a4d2+a4d3r+a4d4+a4d5+a4d6+a4d7r+a4d8r+a4d9r+a4d10)/10
gen EMO_2 = (a5d11+a5d12+a5d13+a5d14+a5d15)/5
gen EMO = (EMO_1/3+EMO_2/4)/2
label var EMO "情绪稳定性"
gen EXT_1 = (a6d1+a6d2+a6d3+a6d4)/4
gen EXT_2 = (a7d5+a7d6+a7d7+a7d8)/4
gen EXT = (EXT_1/4+EXT_2/7)/2
label var EXT "外向性"
gen OPN = (a8d1+a8d2+a8d3+a8d4)/4/5
label var OPN "思维开通性"
gen AGR = (a9d1+a9d2+a9d3+a9d4+a9d5)/5/3
label var AGR "宜人性"
gen CON = (a10d1+a10d2+a10d3+a10d4+a10d5)/5/5
label var CON "尽责性"

*------ 1.3: 计算冲突管理风格总分
gen pre_CFL_1 = (a11d3+a11d6+a11d16+a11d17+a11d26+a11d27)/6
gen pre_CFL_2 = (a11d2+a11d10+a11d11+a11d13+a11d19+a11d24)/6
gen pre_CFL_3 = (a11d1+a11d4+a11d5+a11d7+a11d12+a11d14+a11d15+a11d20+a11d22+a11d23+a11d28)/11 
gen pre_CFL_4 = (a11d8+a11d9+a11d18+a11d21+a11d25+a11d27)/5

*------ 1.4: 保存含综合变量的数据文件
cd "$mydir"
save 1_pretest_detail, replace

*------ 1.7: 保留综合变量，数据宽转长
cd "$mydir"
use 1_pretest_detail, clear
keep sub name score_1 st_score_1 pre* EMO EXT OPN AGR CON

gather pre*, variable(style_) value(pre_cfl)
label var pre_cfl "前测冲突管理风格得分"

gen style = 1 
replace style = 2 if style_ == "pre_CFL_2"
replace style = 3 if style_ == "pre_CFL_3"
replace style = 4 if style_ == "pre_CFL_4"
drop style_
label var style "冲突管理风格"

*------ 1.8: 保存数据文件
cd "$masterdir"
save 1_PreTest, replace

*--- 2: 后测数据处理
*------ 2.1: 读取数据
cd "$mydir"
import excel using 2_posttest_1107, sheet(rawdata) firstrow clear

label var score_2 "后测数学成绩"
egen st_score_2 = std(score_2)
label var st_score_2 "标准化后测数学成绩" // 数学成绩标准化

*------ 2.2: 计算冲突管理风格总分
gen post_CFL_1 = (a2d3+a2d6+a2d16+a2d17+a2d26+a2d27)/6
gen post_CFL_2 = (a2d2+a2d10+a2d11+a2d13+a2d19+a2d24)/6
gen post_CFL_3 = (a2d1+a2d4+a2d5+a2d7+a2d12+a2d14+a2d15+a2d20+a2d22+a2d23+a2d28)/11
gen post_CFL_4 = (a2d8+a2d9+a2d18+a2d21+a2d25+a2d27)/5

*------ 2.3: 保存含综合变量的数据文件
cd "$mydir"
save 2_posttest_detail, replace

*------ 2.6: 保留综合变量，数据宽转长
keep sub name score_2 st_score_2 post* 
gather post*, variable(style_) value(post_cfl)
label var post_cfl "后测冲突管理风格得分"
gen style = 1
replace style = 2 if style_ == "post_CFL_2"
replace style = 3 if style_ == "post_CFL_3"
replace style = 4 if style_ == "post_CFL_4"
drop style_

*------ 2.7: 保存数据文件
cd "$masterdir"
save 2_PostTest, replace

*--- 3: 合并前后测数据，差异检验
*------ 3.1: 合并前后测数据
cd "$masterdir"
use 1_PreTest, clear
merge 1:1 sub style using 2_PostTest, nogen keepusing(st_score_2 score_2 post*)
drop score*
cd "$mydir"
merge n:1 sub using 1_pretest_detail, nogen keepusing(gender leader* age group class)
order sub name gender class age group st_score_1 st_score_2 EMO EXT OPN AGR CON

*------ 3.2: 保存数据文件
cd "$masterdir"
save 3_Test, replace 
