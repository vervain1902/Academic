/*==================================================

Project:			master thesis
Author:				liuziyu
Create Date:		2024.02

--------------------------------------------------

Note:	问卷数据处理；
		文本数据读取与分析；
		课堂评价读取与分析；
		视频评价读取与分析；
		
==================================================*/

*--- 0: 清空内存，定义路径
clear 
cls 

global dir "D:\Onedrive\OneDrive - mail.bnu.edu.cn\0 Academic\1_Graduation\1_毕业设计_202306\data"
global scriptdir "$dir\9_myscript"

*--- 1: 运行脚本

run "1_survey_0219.do"

run "2_task_0219.do"

run "3_assessment_0219.do"

run "4_discourse_0219.do"
