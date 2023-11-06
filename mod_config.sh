#! /bin/bash

# 使用方法：在执行setup.sh安装成功后，执行sh config.sh [待分析项目的名称] [待分析项目的绝对路径]即可生成项目的dot文件
# 例如：待分析项目名称为project1,存放路径为/root/home/spj/project1, 则执行的命令为：sh config.sh project1 /root/home/spj/project1

# 记录脚本开始执行的时间
start_time=$(date +%s)

# 判断是否是一个目录，如果该目录存在则不在建立
[ -d "$1_res" ] && echo -e "$1_res existed" || { mkdir $1_res; }

cd $1_res
# 生成doxygen配置文件
doxygen -g $1"_doxyfile"

path=$(cd "$(dirname "$0")";pwd)
echo $path
cfgFilePath=$path/$1"_doxyfile"

echo "请输入您的项目路径：比如sh config.sh myproject /usr/src/myproject"
echo "您的项目路径为："$2
echo $cfgFilePath

# 更改doxyfile配置文件的配置项为生成调用图的配置
sed -i 's/OUTPUT_LANGUAGE        = English/OUTPUT_LANGUAGE        = Chinese/' $cfgFilePath
sed -i 's/CALL_GRAPH             = NO/CALL_GRAPH             = YES/' $cfgFilePath
sed -i 's/HAVE_DOT               = NO/HAVE_DOT               = YES/' $cfgFilePath
sed -i 's/EXTRACT_ALL            = NO/EXTRACT_ALL            = YES/' $cfgFilePath
sed -i 's/EXTRACT_PRIVATE        = NO/EXTRACT_PRIVATE        = YES/' $cfgFilePath
sed -i 's/EXTRACT_PACKAGE        = NO/EXTRACT_PACKAGE        = YES/' $cfgFilePath
sed -i 's/EXTRACT_STATIC         = NO/EXTRACT_STATIC         = YES/' $cfgFilePath
sed -i 's/EXTRACT_LOCAL_METHODS  = NO/EXTRACT_LOCAL_METHODS  = YES/' $cfgFilePath
sed -i 's/RECURSIVE              = NO/RECURSIVE              = YES/' $cfgFilePath
sed -i 's/DOT_MULTI_TARGETS      = NO/DOT_MULTI_TARGETS      = YES/' $cfgFilePath
sed -i 's/DOT_CLEANUP            = YES/DOT_CLEANUP            = NO/' $cfgFilePath
sed -i 's/GENERATE_LATEX         = YES/GENERATE_LATEX         = NO/' $cfgFilePath
sed -i 's/CALLER_GRAPH           = YES/CALLER_GRAPH           = NO/' $cfgFilePath
sed -i 's/DOT_NUM_THREADS        = 0/DOT_NUM_THREADS        = 32/' $cfgFilePath
sed -i 's/NUM_PROC_THREADS       = 1/NUM_PROC_THREADS       = 32/' $cfgFilePath
# GENERATE_HTML

# 删除INPUT项
sed -i "/INPUT                  =/d"     $cfgFilePath
# 添加用户待分析项目路径
sed -i '2 i INPUT                  ='"$2"'' $cfgFilePath

# 打印配置项信息，可以校验是否配置正确
cat $1"_doxyfile" | grep -n "CALL_GRAPH             ="
cat $1"_doxyfile" | grep -n "HAVE_DOT               ="
cat $1"_doxyfile" | grep -n "EXTRACT_ALL            ="
cat $1"_doxyfile" | grep -n "EXTRACT_PRIVATE        ="
cat $1"_doxyfile" | grep -n "EXTRACT_PACKAGE        ="
cat $1"_doxyfile" | grep -n "EXTRACT_STATIC         ="
cat $1"_doxyfile" | grep -n "EXTRACT_LOCAL_METHODS  ="
cat $1"_doxyfile" | grep -n "INPUT                  ="
cat $1"_doxyfile" | grep -n "OUTPUT_LANGUAGE        ="
cat $1"_doxyfile" | grep -n "RECURSIVE              ="
cat $1"_doxyfile" | grep -n "DOT_MULTI_TARGETS      ="
cat $1"_doxyfile" | grep -n "DOT_CLEANUP            ="
cat $1"_doxyfile" | grep -n "GENERATE_LATEX         ="
cat $1"_doxyfile" | grep -n "CALLER_GRAPH           ="
cat $1"_doxyfile" | grep -n "DOT_NUM_THREADS        ="
cat $1"_doxyfile" | grep -n "NUM_PROC_THREADS       ="

# doxygen配置就绪，生成.dot文件
sudo doxygen $1"_doxyfile" >> log.txt

# 生成项目相关的dot文件，并保存在$project_res/dot下
path=$(cd "$(dirname "$0")";pwd)
echo $path
DIR=$path/html
echo $DIR
sudo chmod 777 $DIR
FILE_TYPE_DOT="dot"
# 通过tmp.txt保存文件夹$DIR下所有的dot文件路径信息，方便之后压缩处理
TMP_FILE="tmp.txt"

mkdir dot
TARGET_FILE=$path/dot/"Dot.tar.gz"
echo $TARGET_FILE
if [ -f "$TARGET_FILE" ];then
  `rm -rf $TARGET_FILE`
fi

echo "You will compress the dot file in the { $path } "
exec 3>$TMP_FILE
TMP_CMD="find $DIR -name *.$FILE_TYPE_DOT"
echo "excute shell cmd >>>>> $TMP_CMD"
RESULT=$(${TMP_CMD})
echo "$RESULT" >&3
exec 3>&-
echo "start compress code............."
# 先将所有dot文件压缩成Dot.tar.gz，再将其解压到$project_res/dot下
TAR_CMD="tar -T $TMP_FILE -zcvf $TARGET_FILE"
${TAR_CMD}
echo "Compress code end .............leave file $TARGET_FILE"
`rm -rf $TMP_FILE`
pwd
cd dot
tar -zxvf Dot.tar.gz
find $path/dot$DIR -name  "*.dot" | xargs -i cp {} $path/dot/

# 删除无用信息
rm -rf Dot.tar.gz

# 记录结束时间
end_time=$(date +%s)

# 计算执行时间
execution_time=$((end_time - start_time))

# 打印执行时间
echo "脚本执行时间为：$execution_time 秒"
