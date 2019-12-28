#!/bin/sh

# yo try dealing with directory creation and symlink management in make(1) someday
#           it'll be fun
#                                                       --some fool, 2016

if [ $# -ne 2 ];then
    printf '%s <host triplet> <output directory>\n' "$0"
    exit 1
fi

SRCDIR=$(dirname $(readlink -f ${0}))
CHOST="${1}"; shift
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
    printf '%s' "${1}" | grep -q "^[0-9]*" && dir_perm="${1}" && shift
    for dir in "${@}";do
        if [ ! -d "${IMAGE}"/"${dir}" ];then
            edo mkdir "${IMAGE}"/"${dir}"
            edo touch -amc "${IMAGE}"/"${dir}"
        fi 
        [ "${dir_perm}" ] && [ $(stat -c '%a' "${IMAGE}"/"${dir}") = "${dir_perm#0*}" ] || edo chmod "${dir_perm}" "${IMAGE}"/"${dir}"
    done
}

file() {
    file_mkdir=false
    [ "$1" = --mkdir ] && file_mkdir=true && shift

    printf '%s' "${1}" | grep -q "^[0-9]*" && file_perm="${1}" && shift
    for file in "${@}";do
        if [ ! -f "${IMAGE}"/"${file}" ];then
            [ -d "${IMAGE}"/"${1%/*}" ] || edo mkdir "${IMAGE}"/"${1%/*}"
            edo cp -dp "${SRCDIR}"/"${file}" "${IMAGE}"/"${file}"
            edo touch -amc "${IMAGE}"/"${file}"
        fi
        [ "${file_perm}" ] && [ $(stat -c '%a' "${IMAGE}"/"${file}") = "${file_perm#0*}" ] || edo chmod "${file_perm}" "${IMAGE}"/"${file}"
    done
}

dir 0755 /
dir 0755 /boot
dir 0755 /dev
dir 0755 /etc
dir 0755 /home
dir 0755 /local
dir 0755 /local/share
dir 0755 /mnt
dir 0755 /proc
dir 0755 /run
dir 0755 /run/tmp
dir 0755 /share
dir 0755 /src
dir 0755 /sys
dir 0755 /var
dir 0755 /var/cache
dir 0755 /var/log
dir 0755 /var/lib
dir 0755 /var/spool
dir 0755 /var/tmp
dir 0755 /${CHOST}
symlink_dir ${CHOST} /host
dir 0755 /${CHOST}/bin
symlink_dir bin /${CHOST}/sbin
dir 0755 /${CHOST}/include
dir 0755 /${CHOST}/lib
dir 0755 /${CHOST}/local
dir 0755 /${CHOST}/local/bin
symlink_dir bin /${CHOST}/local/sbin
dir 0755 /${CHOST}/local/include
dir 0755 /${CHOST}/local/lib

case "${CHOST}" in
    x86_64-*)
        symlink_dir host/lib /lib64
        symlink_dir lib /${CHOST}/lib64
        symlink_dir lib /${CHOST}/local/lib64
    ;;
esac

symlink_dir host/bin /bin
symlink_dir host/include /include
symlink_dir host/lib /lib
symlink_dir ../host/local/bin /local/bin
symlink_dir ../host/local/include /local/include
symlink_dir ../host/local/lib /local/lib
symlink_dir ../host/local/sbin /local/sbin
symlink_dir mnt /media
symlink_dir host/sbin /sbin
symlink_dir run/tmp /tmp
symlink_dir . /usr
symlink_dir ../run /var/run

file 0644   \
    /etc/fstab      \
    /etc/group      \
    /etc/hostname   \
    /etc/hosts      \
    /etc/issue      \
    /etc/passwd     \
    /etc/profile    \
    /etc/protocols  \
    /etc/services   \
    /etc/shells
file 0600 /etc/shadow

