# Pretty_Codes
This is a repository of some pretty codes.



## 20170811: install_nc4.sh

### 简介

这个shell脚本可以交互实现Netcdf4和MPICH的安装。

- 目前只在3台电脑上测试过
- 目前只在Ubuntu16.04系统中测试实现，其他Linux发行版均未测试，并且也没有适配的打算
- 有问题可以`issues`或是邮件。




### 使用

```shell
chmod +x install_nc4.sh
./install_nc4
```




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




### 注意

仅针对课题组内部

- 组内程序的`Makefile`文件请按实际设置的路径更改
- 不同机器上跑程序，请务必首先修改`Makefile`中的各种库路径


### 反馈

目前这个属于测试版，初衷仅供课题组内部使用。如果有问题，可以邮件反馈或是直接`issues`。

**邮箱**：gaox1993@mail.ustc.edu.cn
