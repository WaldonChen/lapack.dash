#!/bin/bash

URL=http://www.math.utah.edu/software/lapack/

# -e robots=off 不使用robots.txt
# -e, –execute=COMMAND (执行命令) execute a `.wgetrc’-style command. (执行不使用
# robots的命令)
# -r, –recursive（递归） specify recursive download.（指定递归下载）
# -k, –convert-links（转换链接） make links in downloaded HTML point to local
# files.（将下载的HTML页面中的链接转换为本地链接）
# -p, –page-requisites（页面必需元素） get all images, etc. needed to display HTML
# page.（下载所有的图片等页面显示所需的内容）
# -np, –no-parent（不追溯至父级）
wget -e robots=off -r -p -np -k $URL
if [ ! $? ]; then exit 1 fi

if [ -d 'www.math.utah.edu/software/lapack' ]
    mv www.math.utah.edu/software/lapack/ . && \
        rm -r www.math.utah.edu/software/
else
    exit 1
fi

sed -i .bak 's|http://www.math.utah.edu/software/lapack.html|#|g' lapack/*.html && rm lapack/*.bak
tar --exclude .DS_Store -zcf lapack.tar.gz lapack/
