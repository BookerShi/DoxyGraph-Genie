#! /bin/bash

# 一定在sudo条件下运行脚本

CPU=$(echo "`cat /proc/cpuinfo | grep "physical id" | uniq | wc -l`H")
MEM=$(echo "$((`cat /proc/meminfo | grep MemTotal |awk '{print $2}'` / 1000000))G")
TIME=$(date)
VERSION=$(lsb_release -r --short)
OS=$(lsb_release -i --short)

echo "当前是${release_os}，系统为：${release_num}"
echo "     *****  检测到您的机器配置为：${CPU} ${MEM}   ***** "
echo "   //  当前时间：${TIME}  //"

# 检测linux版本是否小于20
if [ $VERSION -ge 20]; then
    echo "系统版本为${release_os}：${release_num}"
    sudo apt-get install qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools
    sudo apt install texlive-latex-extra
else
    sudo apt-get install qt5-default 
fi

#安装QT环境
sudo apt-get install cmake qtcreator
#依赖
sudo apt-get install flex
sudo apt-get install bison
sudo apt install gawk
sudo apt-get install texlive-full
sudo apt-get install texlive-xetex

sudo apt update
sudo apt upgrade

#确保已安装QT环境FFEF
cd doxygen
pwd
mkdir build
cd build
pwd

if [ $? -ne 0 ];then
    cmake -G "Unix Makefiles" ..
    make
fi

cmake -Dbuild_doc=YES .. 
make docs

cd ../..

# 安装doxygen的library
wget https://www.doxygen.nl/files/doxygen-1.9.6.linux.bin.tar.gz

gunzip doxygen-1.9.6.linux.bin.tar.gz
tar xf doxygen-1.9.6.linux.bin.tar doxygen-1.9.6/
cd doxygen-1.9.6/
sudo make install

#生成Doxyfile配置文件，配置文件只可以生成一次
doxygen -g