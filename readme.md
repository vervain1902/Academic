# 毕业设计数据分析
## 1. survey
| 分析问卷调查数据
### 1. data
- 读取前后测原始数据：姓名、编号、性别、年龄、小组、测验成绩、大五人格、冲突管理风格
- 合成总分：大五人格、冲突管理风格
- 标准化转换：大五人格、冲突管理风格、测验成绩
- 链接前后测原始数据
- 保存原始数据到路径：mydata
- 保存综合变量到路径：mymaster
### 2. des
- 读取前后测综合变量，对综合变量描述统计、相关分析，输出表格到路径：des\survey
- 读取前后测原始数据，信效度检验
### 3. test
- 读取前后测综合变量，检验前测时冲突管理风格差异
- 检验后测时冲突管理风格差异
- 检验前后测相同冲突管理风格差异

## 2. assess
| 分析学习结果：任务单、小组评价、个人评价
### 1. data
- 读取学习结果原始数据
- 缺失值插补
- 合成总分：任务单评价、小组评价、个人评价
- 链接任务单、小组评价、个人评价
- 保存综合变量到路径：mymaster
### 2. des
- 读取学习结果综合变量，描述统计、相关分析，输出结果到路径：des\assess
	- 截面：个人均分的密度图
	- 时间序列：4、5、6、7小组每节课的均分随时间的变化
	- 相关分析：不同维度的评价结果
### 3. test
- 读取学习结果综合变量
- 比较4、5、6、7小组的均分是否显著不同
- 比较不同课程内容的个人均分是否显著不同
## 3. discourse
| 分析话语：冲突、冲突管理、apt
### 1. data
- 读取各组话语数据并合并
- 链接话语和任务单评价、小组评价
### 2. des
- 全班、小组、个人层面的截面描述、时间趋势描述
### 3. test
- 全班、小组、个人层面的差异检验