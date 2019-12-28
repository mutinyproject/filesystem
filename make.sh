#!/bin/sh

if [ $# -ne 1 ];then
    printf '%s <output directory>\n' "$0"
    exit 1
fi

SRCDIR=$(dirname $(readlink -f ${0}))
IMAGE="${1}"; shift

export PATH="${SRCDIR}/scripts:${PATH}"

edo() {
    printf '%s\n' "$*" >&2
    "$@" || exit $?
}

symlink() {
    if [ ! -L "${IMAGE}"/"${2}" ];then
        edo ln -sn "${1}" "${IMAGE}"/"${2}"
    fi
}

symlink_dir() {
    if [ ! -L "${IMAGE}"/"${2}" ];then
        edo ln -snT "${1}" "${IMAGE}"/"${2}"
    fi
}

dir() {
    dir_perm="${1}"; shift
    for dir in "${@}";do
        if [ ! -d "${IMAGE}"/"${dir}" ];then
            edo mkdir "${IMAGE}"/"${dir}"
            edo touch -amc "${IMAGE}"/"${dir}"
        fi
        edo chmod "${dir_perm}" "${IMAGE}"/"${dir}"
    done
}

file() {
    file_mkdir=false
    [ "$1" = --mkdir ] && file_mkdir=true && shift

    file_perm="${1}"; shift
    for file in "${@}";do
        if [ ! -f "${IMAGE}"/"${file}" ];then
            [ -d "${IMAGE}"/"${1%/*}" ] || edo mkdir "${IMAGE}"/"${1%/*}"
            edo cp -dp "${SRCDIR}"/"${file}" "${IMAGE}"/"${file}"
            edo touch -amc "${IMAGE}"/"${file}"
        fi
        edo chmod "${file_perm}" "${IMAGE}"/"${file}"
    done
}

[ -d "${IMAGE}" ] || edo mkdir -p "${IMAGE}"

dir 0755 bin dev etc home include lib
dir 0755 local local/{bin,include,lib,share}
dir 0755 mnt proc run share srv sys
dir 0755 var var/{cache,lib,log,tmp}

symlink_dir bin sbin
symlink_dir run/tmp tmp
symlink_dir . usr
symlink_dir ../run var/run

file 0644   \
    /etc/fstab      \
    /etc/group      \
    /etc/hostname   \
    /etc/hosts      \
    /etc/issue      \
    /etc/passwd     \
    /etc/profile    \
    /etc/shells
file 0600 /etc/shadow

