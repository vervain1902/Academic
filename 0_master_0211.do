/*
Date: 2024.02
Goal:前后测大五人格、冲突管理风格总分计算；
	 描述性统计图表；
	 前后测冲突管理风格配对样本t检验；
Author: Liuziyu
*/

*--- 0: 清空内存，定义路径
clear 
cls 
global PATH "D:\Onedrive\OneDrive - mail.bnu.edu.cn\0 Academic\Graduation\202306-毕业设计\data"
global PATH_0 "$PATH/mydata"
global PATH_1 "$PATH/myoutput"

*--- 1: 读取前测数据，计算总分
*------ 1.1: 读取数据文件
cd "$PATH_0"
import excel using 0920-前测原始得分-筛选, sheet(rawdata) firstrow clear
drop if ID == .

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

*------ 1.2: 信效度检验
*--------- 1.2.1: 计算大五人格问卷、冲突管理风格问卷alpha值
alpha A11D1-A11D28
alpha A4D1-A10D5

*--------- 1.2.2: 大五人格问卷、冲突管理风格问卷效度检验
// factor A11D1-A11D28, factors(4) pcf

*------ 1.3: 计算大五人格归一化总分
gen A4D1r = 4 - A4D1
gen A4D3r = 4 - A4D3
gen A4D7r = 4 - A4D7
gen A4D8r = 4 - A4D8
gen A4D9r = 4 - A4D9

gen EMO_1 = (A4D1r+A4D2+A4D3r+A4D4+A4D5+A4D6+A4D7r+A4D8r+A4D9r+A4D10)/10
gen EMO_2 = (A5D11+A5D12+A5D13+A5D14+A5D15)/5
gen EMO = (EMO_1/3+EMO_2/4)/2
label var EMO "情绪稳定性"
gen EXT_1 = (A6D1+A6D2+A6D3+A6D4)/4
gen EXT_2 = (A7D5+A7D6+A7D7+A7D8)/4
gen EXT = (EXT_1/4+EXT_2/7)/2
label var EXT "外向性"
gen OPN = (A8D1+A8D2+A8D3+A8D4)/4/5
label var OPN "思维开通性"
gen AGR = (A9D1+A9D2+A9D3+A9D4+A9D5)/5/3
label var AGR "宜人性"
gen CON = (A10D1+A10D2+A10D3+A10D4+A10D5)/5/5
label var CON "尽责性"

*------ 1.3: 计算冲突管理风格总分
gen pre_CFL_1 = (A11D3+A11D6+A11D16+A11D17+A11D26+A11D27)/6
label var pre_CFL_1 "冲突管理风格-回避"
gen pre_CFL_2 = (A11D2+A11D10+A11D11+A11D13+A11D19+A11D24)/6
label var pre_CFL_2 "冲突管理风格-妥协"

gen pre_CFL_3 = (A11D1+A11D4+A11D5+A11D7+A11D12+ ///
	A11D14+A11D15+A11D20+A11D22+A11D23+ ///
	A11D28)/11
	
label var pre_CFL_3 "冲突管理风格-协作"
gen pre_CFL_4 = (A11D8+A11D9+A11D18+A11D21+A11D25+A11D27)/5
label var pre_CFL_4 "冲突管理风格-竞争"

*------ 1.4: 描述统计与相关分析
cd "$PATH_1"
outreg2 using descript.csv, replace sum(detail) ///
	keep(age score_1 EMO EXT OPN AGR CON pre_CFL_1-pre_CFL_4) title(Decriptive statistics)

	
*------ 1.5: 不同风格得分差异检验
display("回避=妥协？")
ttest pre_CFL_1 == pre_CFL_2
display("回避=协作？")
ttest pre_CFL_1 == pre_CFL_3
display("回避=竞争？")
ttest pre_CFL_1 == pre_CFL_4
display("妥协=协作？")
ttest pre_CFL_2 == pre_CFL_3
display("妥协=竞争？")
ttest pre_CFL_2 == pre_CFL_4
display("协作=竞争？")
ttest pre_CFL_3 == pre_CFL_4

*------ 1.6: 保存数据文件
drop if ID == .
save Pretest, replace

*--- 2: 读取后测数据，计算总分
*------ 2.1: 读取数据文件
cd "$PATH_0"
import excel using 1107-后测原始得分-筛选, sheet(rawdata) firstrow clear
drop if ID == .

alpha A2D1-A2D28
factor A2D1-A2D28, factors(4) pcf
label var score_2 "后测数学成绩"
egen st_score_2 = std(score_2)
label var st_score_2 "标准化后测数学成绩" // 数学成绩标准化

*------ 2.2: 计算冲突管理风格总分
gen post_CFL_1 = (A2D3+A2D6+A2D16+A2D17+A2D26+A2D27)/6
label var post_CFL_1 "冲突管理风格-回避"
gen post_CFL_2 = (A2D2+A2D10+A2D11+A2D13+A2D19+A2D24)/6
label var post_CFL_2 "冲突管理风格-妥协"

gen post_CFL_3 = (A2D1+A2D4+A2D5+A2D7+A2D12+ ///
	A2D14+A2D15+A2D20+A2D22+A2D23+ ///
	A2D28)/11
	
label var post_CFL_3 "冲突管理风格-协作"
gen post_CFL_4 = (A2D8+A2D9+A2D18+A2D21+A2D25+A2D27)/5
label var post_CFL_4 "冲突管理风格-竞争"

*------ 2.3: 不同风格得分差异检验
display("回避=妥协？")
ttest post_CFL_1 == post_CFL_2
display("回避=协作？")
ttest post_CFL_1 == post_CFL_3
display("回避=竞争？")
ttest post_CFL_1 == post_CFL_4
display("妥协=协作？")
ttest post_CFL_2 == post_CFL_3
display("妥协=竞争？")
ttest post_CFL_2 == post_CFL_4
display("协作=竞争？")
ttest post_CFL_3 == post_CFL_4

*------ 2.4: 保存数据文件
cd "$PATH_1"
save Posttest, replace

*--- 3: 合并前后测数据，差异检验
use Pretest, clear
merge 1:1 ID using Posttest, ///
	nogen keep(match) keepusing(st_score_2 score_2 post*)
	
keep ID name gender class age group leader* st_score* score* EMO ///
	EXT OPN AGR CON pre* post*
sor ID 
order ID name gender class age group st_score_1 st_score_2 EMO EXT OPN AGR CON
 
save Survey_Pilot, replace 

*------ 3.1: 前后测相同风格得分差异检验
display("后测-前测")
forvalues i = 1/4 {
	ttest pre_CFL_`i' == post_CFL_`i'
}
