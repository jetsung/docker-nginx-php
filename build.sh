#!/usr/bin/env bash

####### Build Script #######
#
# 版本规则:
#   docker tag: <x.y.z>.<N>
#     x.y.z : PHP 版本号, 取自 php-src (github.com/php/php-src) 的最新 tag
#     N     : nginx 变更序号。首次构建为 0; 之后 nginx 版本发生变更时递增
#   version.txt: 记录当前使用的 nginx 版本
#
# 流程:
#   1. 获取 nginx 最新版本 (nginx.org)
#   2. 获取 PHP 最新版本 (php-src tags)
#   3. 查询 ghcr.io 是否已存在 <x.y.z>.* 镜像
#      - 不存在            -> 全新构建 <x.y.z>.0
#      - 存在且 nginx 未变 -> 跳过
#      - 存在且 nginx 有变 -> 构建 <x.y.z>.<N+1>, 并更新 version.txt 后 git commit & push
#
# 用法:
#   ./build.sh [prefix] [env]
#   环境变量:
#     PHP_BRANCHES  参与构建的 PHP 分支, 默认 "8.5 8.4 8.3 8.2"
#     D_PUSH        是否推送镜像, 默认 false
#     D_PLATFORM    构建平台, 默认 linux/amd64,linux/arm64

show_errmsg() {
    printf "\e[1;31m%s \e[0m\n" "${1}"
    exit 1
}

# 读取 version.txt 中记录的 nginx 版本
read_nginx_version() {
    [ -f "${VERSION_FILE}" ] || show_errmsg "未找到 ${VERSION_FILE}"
    local ver
    ver=$(tr -d '[:space:]' < "${VERSION_FILE}")
    [[ "${ver}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || show_errmsg "${VERSION_FILE} 中的 nginx 版本格式错误: ${ver}"
    echo "${ver}"
}

# 获取 nginx 官网最新主线的版本号
fetch_latest_nginx() {
    local ver
    ver=$(curl -fsSL "https://nginx.org/en/download.html" |
        grep -oE 'nginx-[0-9]+\.[0-9]+\.[0-9]+\.tar\.gz' |
        head -n 1 |
        sed -e 's/^nginx-//' -e 's/\.tar\.gz$//')
    [[ "${ver}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || show_errmsg "获取 nginx 最新版本失败"
    echo "${ver}"
}

# 获取 php.net 官方 releases 接口中指定分支 (如 8.2) 的最新版本, 如 8.2.35
fetch_php_version() {
    local branch="${1}" ver
    ver=$(curl -fsSL --retry 3 "https://www.php.net/releases/active.php" |
        jq -r --arg br "${branch}" '.[($br | split(".") | first)][$br].version // empty')
    [[ "${ver}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || show_errmsg "获取 PHP ${branch} 最新版本失败"
    echo "${ver}"
}

# 查询 ghcr.io 仓库的全部 tag
ghcr_tags() {
    local repo="${1}" token
    token=$(curl -fsSL "https://ghcr.io/token?scope=repository:${repo}:pull" | jq -r '.token')
    curl -fsSL -H "Authorization: Bearer ${token}" "https://ghcr.io/v2/${repo}/tags/list" |
        jq -r '.tags[]?'
}

# 取某 PHP 版本已构建的最大 N, 未构建过则返回 -1
max_build_n() {
    local php_ver="${1}" repo="${2}" n
    n=$(ghcr_tags "${repo}" |
        grep -E "^${php_ver//./\\.}\.[0-9]+$" |
        awk -F'.' '{print $NF}' |
        sort -n | tail -n 1)
    echo "${n:-"-1"}"
}

# docker buildx 多平台构建并推送
docker_buildx() {
    local tag_branch="${1}" tag_full="${2}" nginx_ver="${3}" php_ver="${4}"
    local extra_tags=()
    extra_tags+=(--tag "${prefix}nginx-php:${tag_branch}")

    if [[ "${tag_branch}" = "${LATEST_BRANCH}" ]]; then
        extra_tags+=(--tag "${prefix}nginx-php:latest")
    fi

    # shellcheck disable=SC2086
    docker buildx build --platform "${D_PLATFORM}" \
        --output "type=image,push=${D_PUSH}" \
        --tag "${prefix}nginx-php:${tag_full}" \
        "${extra_tags[@]}" \
        --build-arg PHP_VERSION="${php_ver}" \
        --build-arg NGINX_VERSION="${nginx_ver}" \
        --file ./Dockerfile \
        --progress plain \
        . || show_errmsg "docker buildx build failed"
}

# 只构建当前架构, 不使用 QEMU
docker_build() {
    local tag_branch="${1}" tag_full="${2}" nginx_ver="${3}" php_ver="${4}"

    docker build \
        --build-arg PHP_VERSION="${php_ver}" \
        --build-arg NGINX_VERSION="${nginx_ver}" \
        -t "${prefix}nginx-php:${tag_full}" \
        -f ./Dockerfile . || show_errmsg "docker build failed"

    local image_id
    image_id=$(docker images --format '{{.ID}}' "${prefix}nginx-php:${tag_full}")

    docker tag "${image_id}" "${prefix}nginx-php:${tag_branch}" || show_errmsg "docker tag failed"

    if [[ "${tag_branch}" = "${LATEST_BRANCH}" ]]; then
        docker tag "${image_id}" "${prefix}nginx-php:latest"
    fi

    if [[ "${D_PUSH}" = "true" ]]; then
        docker push "${prefix}nginx-php:${tag_full}"
        docker push "${prefix}nginx-php:${tag_branch}"
        if [[ "${tag_branch}" = "${LATEST_BRANCH}" ]]; then
            docker push "${prefix}nginx-php:latest"
        fi
    fi
}

# 构建单个 PHP 版本
build() {
    local php_ver="${1}" nginx_ver="${2}" build_n="${3}"
    local tag_branch="${php_ver%.*}"
    local tag_full="${php_ver}.${build_n}"

    printf "\n===> 构建 %snginx-php:%s (php: %s, nginx: %s)\n" \
        "${prefix}" "${tag_full}" "${php_ver}" "${nginx_ver}"

    if echo "${D_PLATFORM}" | grep -q ','; then
        docker_buildx "${tag_branch}" "${tag_full}" "${nginx_ver}" "${php_ver}"
    else
        docker_build "${tag_branch}" "${tag_full}" "${nginx_ver}" "${php_ver}"
    fi
}

# nginx 版本变更后更新 version.txt 并提交
commit_nginx_version() {
    local new_ver="${1}"

    if [[ "${NGINX_CUR}" = "${new_ver}" ]]; then
        return
    fi

    echo "${new_ver}" > "${VERSION_FILE}"

    if git diff --quiet -- "${VERSION_FILE}" 2>/dev/null; then
        return
    fi

    git add "${VERSION_FILE}"
    git commit -m "build: nginx 升级至 ${new_ver}"
    git push
    NGINX_CUR="${new_ver}"
}

main() {
    set -e

    if [ -z "${1}" ]; then
        prefix="jetsung/"
    else
        prefix="${1}/"
    fi

    if [ -z "${D_PUSH}" ]; then
        D_PUSH="false"
    fi

    if [ -z "${D_PLATFORM}" ]; then
        D_PLATFORM="linux/amd64,linux/arm64"
    fi

    if [ -z "${PHP_BRANCHES}" ]; then
        PHP_BRANCHES="8.5 8.4 8.3 8.2"
    fi

    if [ -z "${VERSION_FILE}" ]; then
        VERSION_FILE="version.txt"
    fi

    # locale env
    if [[ "${2}" = "env" ]] && [ -f ".env" ]; then
        # shellcheck disable=SC1091
        source .env
    fi

    local repo="${prefix}nginx-php"
    local latest_branch=${PHP_BRANCHES%% *}

    printf "
****** [ BUILD START ] ******
build time: %s
docker push: %s
build platform: %s
prefix: %s
php branches: %s
" "$(date '+%F %T')" "${D_PUSH}" "${D_PLATFORM}" "${prefix}" "${PHP_BRANCHES}"

    NGINX_CUR=$(read_nginx_version)
    NGINX_LATEST=$(fetch_latest_nginx)
    LATEST_BRANCH="${latest_branch}"
    NGINX_CHANGED="false"

    if [[ "${NGINX_CUR}" != "${NGINX_LATEST}" ]]; then
        printf "nginx 有新版本: %s -> %s\n" "${NGINX_CUR}" "${NGINX_LATEST}"
        NGINX_CHANGED="true"
    fi

    local has_build="false"

    for branch in ${PHP_BRANCHES}; do
        local php_ver max_n build_n nginx_ver
        php_ver=$(fetch_php_version "${branch}")
        max_n=$(max_build_n "${php_ver}" "${repo}")

        if [ "${max_n}" -lt 0 ]; then
            # ghcr.io 上不存在该 PHP 版本, 全新构建 N=0
            build_n=0
            nginx_ver="${NGINX_LATEST}"
            printf "%s 未构建过, 全新构建 %s.0\n" "${php_ver}" "${php_ver}"
        elif [[ "${NGINX_CHANGED}" != "true" ]]; then
            printf "%s 已构建至 %s.%s 且 nginx (%s) 无变更, 跳过\n" \
                "${php_ver}" "${php_ver}" "${max_n}" "${NGINX_CUR}"
            continue
        else
            # nginx 变更, N 递增
            build_n=$((max_n + 1))
            nginx_ver="${NGINX_LATEST}"
            printf "%s 已构建至 %s.%s, nginx 变更, 重新构建 %s.%s\n" \
                "${php_ver}" "${php_ver}" "${max_n}" "${php_ver}" "${build_n}"
        fi

        build "${php_ver}" "${nginx_ver}" "${build_n}"
        has_build="true"
    done

    if [[ "${has_build}" = "true" ]] && [[ "${NGINX_CHANGED}" = "true" ]]; then
        commit_nginx_version "${NGINX_LATEST}"
    fi

    printf "\n****** [ BUILD DONE ] ******\n"
}

main "$@" || exit 1

# ./build.sh jetsung env
