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
global graphdir "$dir\3_mygraph"

set scheme plotplain, perm

*--- 1 
cd "$masterdir"
use 3_assess, clear
