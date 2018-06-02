V=20180531

PREFIX = /usr/local

BINPROGS = \
	checkpkg \
	archbuild \
	lddd \
	finddeps \
	find-libdeps \
	arch-nspawn \
	mkarchroot \
	makechrootpkg \
	signpkg \
	signpkgs

CONFIGFILES = \
	makepkg-i686.conf \
	makepkg-x86_64.conf \
	pacman-default.conf \
	pacman-mirrors-stable.conf \
	pacman-mirrors-testing.conf \
	pacman-mirrors-unstable.conf \
	pacman-multilib.conf

MANJAROBUILD_LINKS = \
	stable-i686-build \
	stable-x86_64-build \
	stable-multilib-build \
	testing-i686-build \
	testing-x86_64-build \
	testing-multilib-build \
	unstable-i686-build \
	unstable-x86_64-build \
	unstable-multilib-build


all: $(BINPROGS) bash_completion zsh_completion

edit = sed -e "s|@pkgdatadir[@]|$(DESTDIR)$(PREFIX)/share/devtools|g"

%: %.in Makefile lib/common.sh
	@echo "GEN $@"
	@$(RM) "$@"
	@{ echo -n 'm4_changequote([[[,]]])'; cat $@.in; } | m4 -P | $(edit) >$@
	@chmod a-w "$@"
	@chmod +x "$@"
	@bash -O extglob -n "$@"

clean:
	rm -f $(BINPROGS) bash_completion zsh_completion

install:
	install -dm0755 $(DESTDIR)$(PREFIX)/bin
	install -dm0755 $(DESTDIR)$(PREFIX)/share/devtools
	install -m0755 ${BINPROGS} $(DESTDIR)$(PREFIX)/bin
	install -m0644 ${CONFIGFILES} $(DESTDIR)$(PREFIX)/share/devtools
	for l in ${MANJAROBUILD_LINKS}; do ln -sf archbuild $(DESTDIR)$(PREFIX)/bin/$$l; done
	ln -sf find-libdeps $(DESTDIR)$(PREFIX)/bin/find-libprovides
	install -Dm0644 bash_completion $(DESTDIR)/usr/share/bash-completion/completions/devtools
	install -Dm0644 zsh_completion $(DESTDIR)$(PREFIX)/share/zsh/site-functions/_devtools
	ln -sf archbuild $(DESTDIR)$(PREFIX)/bin/manjarobuild
	ln -sf arch-nspawn $(DESTDIR)$(PREFIX)/bin/manjaro-nspawn
	ln -sf mkarchroot $(DESTDIR)$(PREFIX)/bin/mkmanjaroroot

uninstall:
	for f in ${BINPROGS}; do rm -f $(DESTDIR)$(PREFIX)/bin/$$f; done
	for f in ${CONFIGFILES}; do rm -f $(DESTDIR)$(PREFIX)/share/devtools/$$f; done
	for l in ${MANJAROBUILD_LINKS}; do rm -f $(DESTDIR)$(PREFIX)/bin/$$l; done
	rm $(DESTDIR)/usr/share/bash-completion/completions/devtools
	rm $(DESTDIR)$(PREFIX)/share/zsh/site-functions/_devtools
	rm -f $(DESTDIR)$(PREFIX)/bin/find-libprovides
	rm -f $(DESTDIR)$(PREFIX)/bin/manjarobuild
	rm -f $(DESTDIR)$(PREFIX)/bin/manjaro-nspawn
	rm -f $(DESTDIR)$(PREFIX)/bin/mkmanjaroroot

dist:
	git archive --format=tar --prefix=devtools-$(V)/ $(V) | gzip -9 > devtools-$(V).tar.gz
	gpg --detach-sign --use-agent devtools-$(V).tar.gz

check: $(BINPROGS) bash_completion makepkg-x86_64.conf PKGBUILD.proto
	shellcheck $^

.PHONY: all clean install uninstall dist
.DELETE_ON_ERROR:
