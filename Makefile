name = filesystem
version = 0

prefix ?= /usr/local
datarootdir ?= ${prefix}/share
datadir ?= ${datarootdir}
docdir ?= ${datadir}/doc/${name}
htmldir ?= ${docdir}

DESTDIR ?= /

ASCIIDOCTOR ?= asciidoctor

ASCIIDOCTOR_FLAGS += --failure-level=WARNING
ASCIIDOCTOR_FLAGS += -a manmanual="Mutineer's Guide"
ASCIIDOCTOR_FLAGS += -a mansource="Mutiny"

-include config.mk

FILES_644 = \
    etc/fstab \
    etc/group \
    etc/hostname \
    etc/hosts \
    etc/issue \
    etc/passwd \
    etc/profile \
    etc/shells \
    etc/ksh/profile \
    etc/sh/profile \
    lib/os-release \
    share/profile.d/00-xdg.sh \
    share/profile.d/01-path.sh

FILES_600 = \
    etc/shadow

MANS = \
    hier.7 \
    profile.7

HTMLS = ${MANS:=.html}

all: man

dev: all html README

clean: FRC
	rm -f ${HTMLS} ${MANS}

man: FRC ${MANS}
html: FRC ${HTMLS}

.SUFFIXES: .adoc .html
.adoc.html: footer.adoc
	${ASCIIDOCTOR} -b html5 ${ASCIIDOCTOR_FLAGS} -o $@ $<

.adoc: footer.adoc
	${ASCIIDOCTOR} -b manpage -d manpage ${ASCIIDOCTOR_FLAGS} -o $@ $<

.DELETE_ON_ERROR: README
README: hier.7
	man ./$< | col -bx > $@

install-html: FRC html
	install -d ${DESTDIR}${htmldir}
	for html in ${HTMLS}; do install -m0644 $${html} ${DESTDIR}${htmldir}; done

install: FRC all
	# Basic filesystem hierarchy. See hier(7).
	# Indent for each sub-directory, for readability.
	mkdir -p -m 0755 \
	    ${DESTDIR}/bin \
	    ${DESTDIR}/boot \
	    ${DESTDIR}/dev \
	    ${DESTDIR}/etc \
	    ${DESTDIR}/home \
	    ${DESTDIR}/include \
	    ${DESTDIR}/lib \
	    ${DESTDIR}/local \
	        ${DESTDIR}/local/bin \
	        ${DESTDIR}/local/include \
	        ${DESTDIR}/local/lib \
	        ${DESTDIR}/local/share \
	    ${DESTDIR}/mnt \
	    ${DESTDIR}/proc \
	    ${DESTDIR}/run \
	    ${DESTDIR}/share \
	    ${DESTDIR}/srv \
	    ${DESTDIR}/sys \
	    ${DESTDIR}/var \
	        ${DESTDIR}/var/cache \
	        ${DESTDIR}/var/lib \
	        ${DESTDIR}/var/log \
	        ${DESTDIR}/var/tmp

	# Create tmpdir with sticky bit set.
	mkdir -p -m 1777 ${DESTDIR}/run/tmp

	# Compatibility symlinks.
	# The tests on ${DESTDIR}/{usr,var/run} are used because since they're recursive symlinks,
	# `ln` will error out saying the file exists.
	{ [ -L ${DESTDIR}/usr ] && [ "$$(cd -P ${DESTDIR}/usr; pwd)" = ${DESTDIR} ]; } || \
	    ln -sf . ${DESTDIR}/usr
	{ [ -L ${DESTDIR}/var/run ] && [ "$$(cd -P ${DESTDIR}/var/run; pwd)" = ${DESTDIR}/run ]; } || \
	    ln -sf ../run ${DESTDIR}/var/run
	rm -f ${DESTDIR}/run/run
	ln -sf bin ${DESTDIR}/sbin
	ln -sf lib ${DESTDIR}/libexec
	ln -sf run/tmp ${DESTDIR}/tmp

	for file in ${FILES_644}; do \
	    mkdir -p ${DESTDIR}/$${file%/*}; \
	    install -m0644 $${file} ${DESTDIR}/$${file}; \
	done
	for file in ${FILES_600}; do \
	    mkdir -p ${DESTDIR}/$${file%/*}; \
	    install -m0600 $${file} ${DESTDIR}/$${file}; \
	done
	for file in ${MANS}; do \
	    install -m0644 $${file} ${DESTDIR}/share/man/man$${file##*.}/$${file}; \
	done

FRC:
