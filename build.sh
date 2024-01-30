#!/usr/bin/env bash

####### Build Script #######

show_errmsg() {
    printf "\e[1;31m%s \e[0m\n" "${1}"
    exit 1
}

version_split() {
    tag_full_ver="${1}" # "8.2.080" 或 "8.2.180"
    tag_pre_ver=${tag_full_ver:0:3}

    ver1=${tag_full_ver:4:2}
    ver1=${ver1#0} # 移除前导零，以确保数字被解释为十进制

    php_ver="${tag_pre_ver}.${ver1}"

    printf "
TAG FULL: %s
TAG PRE VER: %s
PHP VERSION: %s
" "$tag_full_ver" "$tag_pre_ver" "$php_ver"
}

# docker buildx
docker_buildx() {
    printf "
TAGS:
  %snginx-php:%s
  %snginx-php:%s  
" "$prefix" "$tag_full_ver" "$prefix" "$tag_pre_ver"

    docker login ghcr.io

    if [[ "$tag_pre_ver" = "8.2" ]]; then
        # docker buildx build --platform linux/amd64,linux/arm64 \
        docker buildx build --platform "${D_PLATFORM}" \
            --output "type=image,push=${D_PUSH}" \
            --tag "${prefix}nginx-php:${tag_full_ver}" \
            --tag "${prefix}nginx-php:${tag_pre_ver}" \
            --tag "${prefix}nginx-php:latest" \
            --build-arg PHP_VERSION="${php_ver}" \
            --build-arg NGINX_VERSION="${NGINX_VERSION}" \
            --build-arg GH_MIRROR_URL="${GH_MIRROR_URL}" \
            --file ./Dockerfile \
            --progress plain \
            .

        # ghcr
        GH_CR_PRE="ghcr.io/${prefix}nginx-php:tag_pre_ver"
        GH_CR_LATEST="ghcr.io/${prefix}nginx-php:latest"
        docker tag "${prefix}nginx-php:tag_pre_ver" "$GH_CR_PRE"
        docker tag "${prefix}nginx-php:latest" "$GH_CR_LATEST"
        docker push --platform "${D_PLATFORM}" "$GH_CR_PRE"
        docker push --platform "${D_PLATFORM}" "$GH_CR_LATEST"
    else
        # docker buildx build --platform linux/amd64,linux/arm64 \
        docker buildx build --platform "${D_PLATFORM}" \
            --output "type=image,push=${D_PUSH}" \
            --tag "${prefix}nginx-php:${tag_full_ver}" \
            --tag "${prefix}nginx-php:${tag_pre_ver}" \
            --build-arg PHP_VERSION="${php_ver}" \
            --build-arg NGINX_VERSION="${NGINX_VERSION}" \
            --build-arg GH_MIRROR_URL="${GH_MIRROR_URL}" \
            --file ./Dockerfile \
            --progress plain \
            .

        # ghcr
        GH_CR_PRE="ghcr.io/${prefix}nginx-php:tag_pre_ver"
        docker tag "${prefix}nginx-php:tag_pre_ver" "$GH_CR_PRE"
        docker push --platform "${D_PLATFORM}" "$GH_CR_PRE"
    fi
}

# 只当前构架，不使用 QEMU
docker_build() {
    # 构建
    docker_tag

    # 推送
    if [[ "${D_PUSH}" = "true" ]]; then
        docker_push
    fi
}

# 构建与生成 TAG
docker_tag() {
    docker build --build-arg PHP_VERSION="${php_ver}" \
        --build-arg NGINX_VERSION="${NGINX_VERSION}" \
        --build-arg GH_MIRROR_URL="${GH_MIRROR_URL}" \
        -t "${prefix}"nginx-php:"${tag_full_ver}" \
        -f ./Dockerfile . ||
        show_errmsg "docker build failed"

    image_id=$(docker images | grep "${prefix}"nginx-php | grep "${tag_full_ver}" | awk '{print $3}')

    docker tag "${image_id}" "${prefix}"nginx-php:"${tag_pre_ver}" || show_errmsg "docker tag failed"

    if [[ "${tag_pre_ver}" = "8.3" ]]; then
        docker tag "${image_id}" "${prefix}"nginx-php:latest
    fi
}

# 推送
docker_push() {
    docker push "${prefix}"nginx-php:"${tag_full_ver}"
    docker push "${prefix}"nginx-php:"${tag_pre_ver}"

    if [[ "${tag_pre_ver}" = "8.3" ]]; then
        docker push "${prefix}"nginx-php:latest
    fi
}

build() {
    version_split "${1}"

    rm -rf ./logoutput.log
    if [ -z "$BUILDX_ENABLE" ]; then
        # 不使用 buildx，只编译 amd64
        echo "build"
        docker_build 2>&1 | tee ./logoutput.log
    else
        # 使用 docker buildx
        echo "buildx"
        docker_buildx 2>&1 | tee ./logoutput.log
    fi

    # https://github.com/dutchcoders/transfer.sh/
    #curl --upload-file ./logoutput.log https://transfer.sh/logoutput.log
}

main() {
    set -e

    if [ -z "${1}" ]; then
        prefix="jetsung/"
    else
        prefix="${1}/"
    fi

    if [ -z "${D_PUSH}" ]; then
        D_PUSH="false" # 是否推送
    fi

    if [ -z "${D_PLATFORM}" ]; then
        D_PLATFORM="linux/amd64,linux/arm64" # 构建环境
    fi

    # locale env
    if [[ "${2}" = "env" ]] && [ -f ".env" ]; then
        # shellcheck disable=SC1091
        source .env
    fi

    # 架构大于 1 则使用 buildx
    if echo "$D_PLATFORM" | grep -q ','; then
        BUILDX_ENABLE="yes"
    fi

    build_time=$(date "+%F %T")
    _PUSH=$(echo "${D_PUSH}" | tr '[:lower:]' '[:upper:]')
    _PLAT_FORM=$(echo "${D_PLATFORM}" | tr '[:lower:]' '[:upper:]')
    printf "
****** [ BUILD START ] ******
build time: %s
docker push: %s
build platform: %s
php version: %s
prefix: %s
gh_proxy: %s
" "$build_time" "$_PUSH" "$_PLAT_FORM" "$IMAGE_VERSION" "$prefix" "$GH_MIRROR_URL"

    string="$IMAGE_VERSION"
    array=${string//,/ }

    # shellcheck disable=SC2068
    for var in ${array[@]}; do
        #    echo "${var}"
        build "$var"
    done

}

main "$@" || exit 1

# ./build.sh jetsung env
