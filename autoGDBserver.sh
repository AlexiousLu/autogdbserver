#!/bin/bash

#这个脚本的主要目的，是为了防止clion基于gdb的远程调试每次都需要手动启动gdbserver设置端口的现象，这有点过于麻烦了，于是我打算，写一个服务监测特定的文件，当源代码发生变化的时候，自动重新编译并生成可执行文件，同时运行gdbserver监听指定端口。
#这个脚本估计还有非常多的bug暂时未被发现，说不定还有安全问题，对此我不负任何责任。请使用者自己注意，耗子尾汁。
#由于我非常不熟悉bash编程，以及我个人的愚蠢，推荐将这个脚本放在项目的xx-build文件夹下，以./autoGDBserver.sh 2333 ../ ./ ./项目名称 来运行 

#运行这个脚本需要gdbserver、cmake、make工具，请自行安装依赖

# $1 表示监听的端口
# $2 表示需要监测的路径
# $3 表示需要重新cmake（如果需要）的路径（xx-build）
# $4 表示需要调试的可执行文件的名称



#定义验证文件目录
FileDir=$(realpath "$3/autoGDBserverLog")
#定义需要监测的文件夹
CheckDir=$(realpath "$2")
#定义可执行文件的路径
ExecDir=$(realpath "$4")
#定义生成所需验证的文件样本日志的函数
function OldFile(){
        for i in ${CheckDir[@]}
        do
                find ${i} -path ${FileDir} -prune -o -type f -print0 | xargs -0 md5sum > ${FileDir}/old.log
        done
}
function NewFile(){
        for i in ${CheckDir[@]}
        do
                find ${i} -path ${FileDir} -prune -o -type f -print0 | xargs -0 md5sum > ${FileDir}/new.log
        done
}

if [ ! -d ${FileDir} ]
then
        mkdir ${FileDir} -p
fi

if [ ! -e ${FileDir}/old.log ]
then
        cat /dev/null>${FileDir}/old.log
fi

while [ [true] ]; do
	remakeFlag=0
	regdbFlag=0

	sleep 2s
	#生成新的日志文件
	NewFile
	#新的日志文件与旧的日志文件进行对比
	diff ${FileDir}/new.log ${FileDir}/old.log > ${FileDir}/diff.log
	status1=$?
	if [ $status1 -ne 0 ]
        then 
        	echo "文件变化"
                cat ${FileDir}/diff.log
                #清除新旧日志文件，备份比较结果
                #cp -f ${FileDir}/diff.log ${FileDir}/diff$(date +%F__%T).log
                cat /dev/null > ${FileDir}/old.log
                cat /dev/null > ${FileDir}/new.log
                #生成新的旧日志文件
                OldFile
		# 当源文件被修改的情况下，需要重新make以及重启gdbserver
		remakeFlag=1
		regdbFlag=1
        fi


	#如果端口没有被监听，则启动gdbserver
	arr=`netstat -ant | grep $1 | awk '{print $6}'`
	echo $arr | grep "LISTEN" > /dev/null
        status2=$?
	if [ $status2 -ne 0 ]
        then
        	echo "GDBserver未启动"
                regdbFlag=1
        fi


	#这里有两种情况，正在调试（正常）以及当clion连接上了debug但是长期不操作，从而在进行下一步操作的时候断连但本机仍然是EST的情况（非正常）
	#很遗憾，本人水平有限，只能处理第一种正常情况。
        echo $arr | grep "ESTABLISHED" > /dev/null
	status3=$?
	if [ $status3 -eq 0 ]
        then
        	echo "正在调试"
                sleep 5s
		# 也就是说，如果正在调试，那么所有的remake、regdb都会被截断
                continue
        fi	

	# 重新make:
	if [ $remakeFlag -eq 1 ]
	then
		echo "remakeing"
		echo "Cmaking...."
                temp=`cmake -DCMAKE_BUILD_TYPE=Debug -EXECUTABLE_OUTPUT_PATH=$3 $3/.. >> ${FileDir}/cmakeOut.log`
                echo "Cmake SUCCESS!"
                echo "Making...."
                temp=`make >> ${FileDir}/makeOut.log`
                echo "Make SUCCESS!"
	fi
	

	# 重启Gdbserver:
	if [ $regdbFlag -eq 1 ]
	then
		# gdbserver对应产生两个进程,killall可以将其子进程全部杀死(只要子进程不是以nohup方式产生的)
        	killall gdbserver
                echo "StartGdbServer"
                # 让标准输出输出到文件，并将标准错误也重定向过去,且让本条命令在后台执行
                gdbserver :$1 ${ExecDir} >> ${FileDir}/gdbserverOut.log 2>&1 &
                echo "GdbServer Starting SUCCESS!"
        fi
done
