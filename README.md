# Pretty_Codes
This is a repository of some pretty codes.



## 20170811: install_nc4.sh

### 简介

这个shell脚本可以交互实现Netcdf4和MPICH的安装。

**目前只在3台电脑上测试过，如果有问题，可以在`github`上直接`issues`**。



### 特点

- 可以自由选择安装哪些软件包（目前只有两种）
- 可以自定义安装路径（目前只能实现在`/home/user/`目录下的任意安装）
- 可以联网安装或是离线安装（离线安装需要当前目录下有安装包）
- 可以无需设定环境变量，直接运行脚本（程序内部自行设定）
- 可以自行检测在给定路径下是否已安装目标软件，不会重复安装
- 需要`Intel`编译器支持
- 程序会自动检测以下内容：
  - 安装所需的一些依赖软件是否存在
  - 安装所需的`Intel`编译器是否存在
  - 安装时所处的网络环境
  - 安装所需的环境变量是否设置正确



### 更新

- 2017-08-11：install_nc4.sh
  - netcdf4和mpich的安装实现





### 反馈

目前这个属于测试版，初衷仅供课题组内部使用。如果有问题，可以邮件反馈或是直接`issues`。

**邮箱**：gaox1993@mail.ustc.edu.cn
