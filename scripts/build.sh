#!/bin/bash

cd `dirname $0`
cd ..

PROJECT_DIR=$(pwd)
echo "PROJECT_DIR=${PROJECT_DIR}"
OUT_BIN=${PROJECT_DIR}/out

mkdir -p ${OUT_BIN}

export GOPROXY=https://goproxy.cn
echo "GOPROXY=$GOPROXY"

export CGO_CFLAGS="-I${PROJECT_DIR}/3rd/cxx/x64-centos7/include"
export CGO_LDFLAGS="-L${PROJECT_DIR}/3rd/cxx/x64-centos7/lib -lm -lstdc++ -ldl"
echo "CGO_CFLAGS=$CGO_CFLAGS"
echo "CGO_LDFLAGS=$CGO_LDFLAGS"

VersionSHA=$(git rev-parse --short HEAD)
BuildTime=$(date '+%Y.%m.%d %H:%M:%S')
BuildHost=$(hostname)
BuildType="default"
Flavor="S"

[ -z "$VersionSHA" ] && VersionSHA="unknown"
VersionSHA="${VersionSHA// /_}"
BuildTime="${BuildTime// /_}"
BuildHost="${BuildHost// /_}"

CP_OS="unknown"
if [[ -f "/etc/os-release" ]]; then
  if grep -q 'CentOS Linux 7' /etc/os-release; then
      CP_OS=cp_centos7
  elif grep -q 'openEuler' /etc/os-release; then
      CP_OS=cp_openeuler
  else
      echo "unsupported os"
  fi
fi

while read target
do
    [[ -z "$target" ]] && continue
    [[ "$target" == "#"* ]] && continue

    if [[ "$target" == "${CP_OS}"* ]]; then
      src_dir=`echo "$target" | cut -d ' ' -f 2`
      dst_dir_name=`echo "$target" | cut -d ' ' -f 3`
      [[ -d "${src_dir}" ]] && cp -a ${src_dir}  ${OUT_BIN}/${dst_dir_name}
    elif [[ "$target" == "cp"* ]]; then
      echo skip $target
    else
      build_dir=`echo "$target" | cut -d ' ' -f 1`
      out_name=`echo "$target" | cut -d ' ' -f 2`

      echo go build  -ldflags "-X main.VersionSHA=${VersionSHA} -X main.BuildTime=${BuildTime} -X main.BuildType=${BuildType} -X main.BuildHost=${BuildHost} -X main.Flavor=${Flavor}" -o "${OUT_BIN}/${out_name}" $build_dir
      go build -ldflags "-X main.VersionSHA=${VersionSHA} -X main.BuildTime=${BuildTime} -X main.BuildType=${BuildType} -X main.BuildHost=${BuildHost} -X main.Flavor=${Flavor}" -o "${OUT_BIN}/${out_name}" $build_dir
    fi
done < scripts/targets
