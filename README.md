## Autogdbserver

​	这是一个让远程调试时使用的gdbserver能够自动重新启动的脚本。**请注意，如果无法正常使用gdbserver进行远程调试，那么这个脚本无法帮助您修复这个问题，请检查您的本地和远程机器配置**

​	This is a bash script that makes remote gdbserver restart properly ( I hope, with faith ). **ATTENTION: If you CAN NOT remotely debug with gdbserver, this script will be of NO USE ! Please Check the related settings both on local and remote machine.** 



*   推荐使用方法[How to use it (recommended) ]：

    将这个脚本放在你保存cmake结果的同目录下（通常是xx-build）。切换到那个目录后，运行./autoGDBserver.sh {远程服务器监听的端口号} ../ ./ ./{你想要远程调试的文件}

    1.  Move this script to the directory that you save cmake result .(usually named xx-bulid).
    2.  Change to that directory.
    3.  Run: ./autoGDBserver.sh \$LISTEN_PORT ../ ./ ./\$EXECUTABLE_FILE



*   不推荐的使用方法[How to use it (unrecommended) ]：

    *   .......反正除了推荐的，我都没测试过

    *   Do what you want do and I have never test any other situation.



*   其它[Others]：
    *   我的环境是CLion + macOS && gdbserver + Ubuntu16.04，但是在启动远程debug的时候，非常非常的卡，需要等半分钟以上才能停在开始位置的breakpoint。（这与这个脚本无关，直接使用gdbserver也是一样的结果）不知道有没有好兄弟碰到一样的问题。
    *   I'm Using CLion + macOS && gdbserver + Ubuntu16.04. When it comes to STARTUP of remote debug, it becomes VERRRRRRY SLOW, which takes over half a minute to suspended on the first breakpoint. (It is NO relation to this script. It happens when running pure gdbserver command.) If you have good idea to solve this problem, thank you for telling me.





*全世界的无产者，联合起来！*

*Workers of the world, Unite!*

*Пролетарии всех стран, соединяйтесь!*

*Proletarier aller Länder, vereinigt euch!*

*Prolétaires de tous les pays, unissez-vous!*