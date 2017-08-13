# Pretty_Codes
This is a repository of some pretty codes.

## 20170813:check_google.sh

### 功能
- 每30s检测一次是否可以访问google，如果无法连接google会弹窗显示无法连接

### 使用
- 建议在后台开启
  ```shell
  nohup 。/check_google.sh &
  ```
- 程序中由于设置的是死循环（`while true`），因此只要不关机或是直接关闭运行终端（以exit方式退出可以），程序会一直运行
- 希望开机自启动，可以参考设置[Here](http://blog.csdn.net/marujunyy/article/details/8466255)

### 更新
- 20170813：Init

### 反馈
- 如果有问题可以随时反馈，虽然这个脚本实在太简单
- 邮箱：gaox1993@mail.ustc.edu.cn
