#! /bin/bash

# 远程主机地址
pub_address="nslover.com"

# 远程需要同步的文件目录
pub_files_path="/root/test.sh"
# 本地的存放同步文件目录路径
local_files_path="/root/"

#数据库用户
db_user="root"

#数据库密码
pub_db_passwd="password"
local_db_psswd="password"

#数据库名
db_name1="db1"
db_name2="db2"


if [ $# -ne 1 ];then
	# 生成ssh 公钥私钥

	echo "请输入正确的脚本参数！"
	echo "初始化公钥授权请输入：sh sync_data.sh init "
	echo "同步数据请输入：sh sync_data.sh sync "
fi

if [ "$1" = "init" ];then
	ssh-keygen -t rsa
	scp ~/.ssh/id_rsa.pub root@$pub_address:~/.ssh/authorized_keys
        eval `ssh-agent -s`
	ssh-add
        cp -r ./sync_cron /etc/cron.d/
        service crond reload
fi

if [ "$1" = "sync" ];then
mysqldump --host=$pub_address --user=$db_user --password=$pub_db_passwd $db_name1 --single-transaction | mysql --user=$db_user --password=$local_db_psswd $db_name1
if [ $? -ne 0 ]; then
    echo `date`": 同步数据库$db_name1失败！"
	exit 1;
fi

mysqldump --host=$pub_address --user=$db_user --password=$pub_db_passwd $db_name2 --single-transaction | mysql --user=$db_user --password=$local_db_psswd $db_name2
if [ $? -ne 0 ]; then
    echo `date`": 同步数据库$db_name2失败！"
	exit 1;
fi

scp  -r root@$pub_address:$pub_files_path $local_files_path
if [ $? -ne 0 ]; then
    echo `date`": 同步文件数据失败！"
	exit 1;
else echo `date`": 同步数据库和文件数据成功！"
fi
fi
