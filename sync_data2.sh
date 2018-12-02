#! /bin/bash

# 远程主机地址
pub_address="192.168.1.1"

# 远程需要同步的文件目录
pub_files_path1="/usr/local/u-mail/data/www/tlj/ueditor"
pub_files_path2="/usr/local/u-mail/data/www/tlj/Public/Uploads"
pub_files_path3="/usr/local/u-mail/data/www/webmail/netdisk"
pub_files_path4="/usr/local/u-mail/data/mailbox"
# 本地的存放同步文件目录路径
local_files_path1="/usr/local/u-mail/data/www/tlj/ueditor"
local_files_path2="/usr/local/u-mail/data/www/tlj/Public/Uploads"
local_files_path3="/usr/local/u-mail/data/www/webmail/netdisk"
local_files_path4="/usr/local/u-mail/data/mailbox"

#数据库用户
db_user="root"

#数据库密码
pub_db_passwd="123456"
local_db_psswd="123456"

#数据库名
db_name1="think_tlj"
db_name2="umail"

cmd_path="/usr/local/u-mail/service/mysql/bin/"


if [ $# -ne 1 ];then
        # 生成ssh 公钥私钥

        echo "请输入正确的脚本参数！"
        echo "初始化公钥授权请输入：sh sync_data.sh init "
        echo "同步数据请输入：sh sync_data.sh sync "
fi

if [ "$1" = "init" ];then
        ssh-keygen -t rsa
        scp ~/.ssh/id_rsa.pub root@$pub_address:~/.ssh/authorized_keys
        ssh-add
fi

if [ "$1" = "sync" ];then
        cmd1="/usr/local/u-mail/service/mysql/bin/mysqldump -h$pub_address -u$db_user -p$pub_db_passwd $db_name1 | /usr/local/u-mail/service/mysql/bin/mysql -u$db_user -p$local_db_psswd  $db_name1"
        echo $cmd1
        cmd2="/usr/local/u-mail/service/mysql/bin/mysqldump -h$pub_address -u$db_user -p$pub_db_passwd $db_name2 | /usr/local/u-mail/service/mysql/bin/mysql -u$db_user -p$local_db_psswd $db_name2"
        echo $cmd2
my_process="/usr/local/u-mail/service/mysql/bin/mysql -u$db_user -p$local_db_psswd -e 'show processlist' -ss"
my_kill="/usr/local/u-mail/service/mysql/bin/mysql -u$db_user -p$local_db_psswd -e "
for i in $(eval $my_process | awk '{print $1}')
do
echo "kill $i"
eval $my_kill"'kill $i;'" > /dev/null
done

if (eval $cmd1 && eval $cmd2 );then
        echo `date`": 同步数据库成功！"
        scp  -r root@$pub_address:$pub_files_path1/* $local_files_path1/
        scp  -r root@$pub_address:$pub_files_path2/* $local_files_path2/
        scp  -r root@$pub_address:$pub_files_path3/* $local_files_path3/
        scp  -r root@$pub_address:$pub_files_path4/* $local_files_path4/
        chown -R umail:umail $local_files_path3
        chown -R umail:umail $local_files_path4
        echo `date`": 同步数据成功！"
else echo `date`": 同步数据库失败！"
fi
fi
