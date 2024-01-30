#!/bin/bash

######## 合并多个扩展安装文件  ############

READ_LINK=$(readlink -f "$0")
TOOLS_DIR=$(dirname "$READ_LINK")

pushd "${TOOLS_DIR}" >/dev/null || exit

EXTS=$(ls ./*.sh)
echo >./extension.sh

for VAR in ${EXTS}; do
    if [[ "$VAR" != "merge.sh" ]] && [[ "$VAR" != "extension.sh" ]]; then
        cat "$VAR" >>./extension.sh
    fi
done

popd >/dev/null || exit
