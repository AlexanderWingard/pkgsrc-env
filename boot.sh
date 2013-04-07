#!/bin/sh

export TARGET=`pwd`/target
export SH=/bin/bash #shell must be BSD-compatible

curl -OL http://ftp.netbsd.org/pub/pkgsrc/current/pkgsrc.tar.gz
tar xzvf pkgsrc.tar.gz
rm pkgsrc.tar.gz

#TARGET is the main dir where packages will be installed 
./pkgsrc/bootstrap/bootstrap --unprivileged --prefix=$TARGET/pkg --pkgdbdir=$TARGET/db/pkg --sysconfdir=$TARGET/etc --varbase=$TARGET/var

target/pkg/sbin/pkg_admin -K target/db/pkg fetch-pkg-vulnerabilities

#Generate initial setup that can be sourced
SETUP=`pwd`/setup.sh
echo "#!/bin/bash
pushd . > /dev/null
TARGET=\"${BASH_SOURCE[0]}/target\";
  while([ -h \"${SCRIPT_PATH}\" ]) do 
    cd \"`dirname \"${SCRIPT_PATH}\"`\"
    TARGET=\"$(readlink \"`basename \"${SCRIPT_PATH}\"`\")/target\"; 
  done
cd \"`dirname \"${SCRIPT_PATH}\"`\" > /dev/null
TARGET=\"`pwd`/target\";
popd  > /dev/null

TARGET_BIN=$TARGET/pkg/bin
TARGET_SBIN=$TARGET/pkg/sbin

export PATH=$TARGET_BIN:$TARGET_SBIN:$PATH" > $SETUP
