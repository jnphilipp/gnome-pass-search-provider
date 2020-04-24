SHELL=/bin/bash

DATA_DIR?=/usr/share
DOC_DIR?=/usr/share/doc
LIB_DIR?=/usr/lib

ifdef VERBOSE
  Q :=
else
  Q := @
endif

clean:
	@$(Q)rm -rf ./build

deb: build/package/DEBIAN/control
	$(Q)fakeroot dpkg-deb -b build/package build/gnome-pass-search-provider.deb
	$(Q)lintian -Ivi build/gnome-pass-search-provider.deb

install: build/copyright build/changelog.Debian.gz
	$(Q)apt install python3-fuzzywuzzy

	$(Q)install -Dm 0644 conf/org.gnome.Pass.SearchProvider.desktop "${DATA_DIR}"/applications/org.gnome.Pass.SearchProvider.desktop
	$(Q)install -Dm 0644 conf/org.gnome.Pass.SearchProvider.service.dbus "${DATA_DIR}"/dbus-1/services/org.gnome.Pass.SearchProvider.service
	$(Q)install -Dm 0644 conf/org.gnome.Pass.SearchProvider.ini "${DATA_DIR}"/gnome-shell/search-providers/org.gnome.Pass.SearchProvider.ini

	$(Q)mkdir -m 0755 -p "${DOC_DIR}"/gnome-pass-search-provider
	$(Q)install -m 0755 build/copyright "${DOC_DIR}"/gnome-pass-search-provider/copyright

	$(Q)mkdir -m 0755 -p "${LIB_DIR}"/gnome-pass-search-provider
	$(Q)install -Dm 0755 gnome-pass-search-provider.py "${LIB_DIR}"/gnome-pass-search-provider/gnome-pass-search-provider.py
	$(Q)install -Dm 0644 conf/org.gnome.Pass.SearchProvider.service.systemd "${LIB_DIR}"/systemd/user/org.gnome.Pass.SearchProvider.service

	$(Q)echo "gnome-pass-search-provider install completed."

uninstall:
	$(Q)apt remove python3-fuzzywuzzy
	$(Q)rm -r "${DOC_DIR}"/gnome-pass-search-provider
	$(Q)rm -r "${LIB_DIR}"/gnome-pass-search-provider

	$(Q)rm "${DATA_DIR}"/applications/org.gnome.Pass.SearchProvider.desktop
	$(Q)rm "${DATA_DIR}"/dbus-1/services/org.gnome.Pass.SearchProvider.service
	$(Q)rm "${DATA_DIR}"/gnome-shell/search-providers/org.gnome.Pass.SearchProvider.ini

	$(Q)rm "${LIB_DIR}"/systemd/user/org.gnome.Pass.SearchProvider.service

	$(Q)echo "gnome-pass-search-provider uninstall completed."

build:
	$(Q)mkdir build

build/copyright: build
	$(Q)echo "Upstream-Name: gnome-pass-search-provider" > build/copyright
	$(Q)echo "Source: https://github.com/jnphilipp/gnome-pass-search-provider" >> build/copyright
	$(Q)echo "" >> build/copyright
	$(Q)echo "Files: *" >> build/copyright
	$(Q)echo "Copyright: Copyright 2017-2019 Jonathan Lestrelin (jle64) <jonathan.lestrelin@gmail.com>, J. Nathanael Philipp (jnphilipp) <nathanael@philipp.land>" >> build/copyright
	$(Q)echo "License: GPL-3+" >> build/copyright
	$(Q)echo " This program is free software; you can redistribute it" >> build/copyright
	$(Q)echo " and/or modify it under the terms of the GNU General Public" >> build/copyright
	$(Q)echo " License as published by the Free Software Foundation; either" >> build/copyright
	$(Q)echo " version 3 of the License, or (at your option) any later" >> build/copyright
	$(Q)echo " version." >> build/copyright
	$(Q)echo "" >> build/copyright
	$(Q)echo " This program is distributed in the hope that it will be" >> build/copyright
	$(Q)echo " useful, but WITHOUT ANY WARRANTY; without even the implied" >> build/copyright
	$(Q)echo " warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR" >> build/copyright
	$(Q)echo " PURPOSE.  See the GNU General Public License for more" >> build/copyright
	$(Q)echo " details." >> build/copyright
	$(Q)echo "" >> build/copyright
	$(Q)echo " You should have received a copy of the GNU General Public" >> build/copyright
	$(Q)echo " License along with this package; if not, write to the Free" >> build/copyright
	$(Q)echo " Software Foundation, Inc., 51 Franklin St, Fifth Floor," >> build/copyright
	$(Q)echo " Boston, MA  02110-1301 USA" >> build/copyright
	$(Q)echo " On Debian systems, the full text of the GNU General Public" >> build/copyright
	$(Q)echo " License version 3 can be found in the file" >> build/copyright
	$(Q)echo " '/usr/share/common-licenses/GPL-3'." >> build/copyright

build/copyright.h2m: build
	$(Q)echo "[COPYRIGHT]" > build/copyright.h2m
	$(Q)echo "This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version." >> build/copyright.h2m
	$(Q)echo "" >> build/copyright.h2m
	$(Q)echo "This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details." >> build/copyright.h2m
	$(Q)echo "" >> build/copyright.h2m
	$(Q)echo "You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/." >> build/copyright.h2m

build/changelog: build
	$(Q)declare TAGS=(`git tag`); for ((i=$${#TAGS[@]};i>=0;i--)); do if [ $$i -eq 0 ]; then git log $${TAGS[$$i]} --no-merges --format="gpgmail ($${TAGS[$$i]}-%h) unstable; urgency=medium%n%n  * %s%n    %b%n -- %an <%ae>  %aD%n" | sed "/^\s*$$/d" >> build/changelog; elif [ $$i -eq $${#TAGS[@]} ]; then git log $${TAGS[$$i-1]}..HEAD --no-merges --format="gpgmail ($${TAGS[$$i-1]}-%h) unstable; urgency=medium%n%n  * %s%n    %b%n -- %an <%ae>  %aD%n" | sed "/^\s*$$/d" >> build/changelog; else git log $${TAGS[$$i-1]}..$${TAGS[$$i]} --no-merges --format="gpgmail ($${TAGS[$$i]}-%h) unstable; urgency=medium%n%n  * %s%n    %b%n -- %an <%ae>  %aD%n" | sed "/^\s*$$/d" >> build/changelog; fi; done

build/changelog.Debian.gz: build/changelog
	$(Q)cat build/changelog | gzip -n9 > build/changelog.Debian.gz

build/package/DEBIAN: build
	$(Q)mkdir -p build/package/DEBIAN

build/package/DEBIAN/md5sums: gnome-pass-search-provider.py conf/org.gnome.Pass.SearchProvider.ini conf/org.gnome.Pass.SearchProvider.desktop conf/org.gnome.Pass.SearchProvider.service.dbus conf/org.gnome.Pass.SearchProvider.service.systemd build/copyright build/changelog.Debian.gz build/package/DEBIAN
	$(Q)install -Dm 0644 conf/org.gnome.Pass.SearchProvider.ini build/package"${DATA_DIR}"/gnome-shell/search-providers/org.gnome.Pass.SearchProvider.ini
	$(Q)install -Dm 0644 conf/org.gnome.Pass.SearchProvider.desktop build/package"${DATA_DIR}"/applications/org.gnome.Pass.SearchProvider.desktop
	$(Q)install -Dm 0644 conf/org.gnome.Pass.SearchProvider.service.dbus build/package"${DATA_DIR}"/dbus-1/services/org.gnome.Pass.SearchProvider.service

	$(Q)install -Dm 0755 gnome-pass-search-provider.py build/package"${LIB_DIR}"/gnome-pass-search-provider/gnome-pass-search-provider.py
	$(Q)install -Dm 0644 conf/org.gnome.Pass.SearchProvider.service.systemd build/package"${LIB_DIR}"/systemd/user/org.gnome.Pass.SearchProvider.service

	$(Q)install -Dm 0644 build/changelog.Debian.gz build/package"${DOC_DIR}"/gnome-pass-search-provider/changelog.Debian.gz
	$(Q)install -Dm 0644 build/copyright build/package"${DOC_DIR}"/gnome-pass-search-provider/copyright

	$(Q)mkdir -p build/package/DEBIAN
	$(Q)md5sum `find build/package -type f -not -path "*DEBIAN*"` > build/md5sums
	$(Q)sed -e "s/build\/package\///" build/md5sums > build/package/DEBIAN/md5sums
	$(Q)chmod 644 build/package/DEBIAN/md5sums

build/package/DEBIAN/control: build/package/DEBIAN/md5sums
	$(Q)echo "Package: gnome-pass-search-provider" > build/package/DEBIAN/control
	$(Q)echo "Version: `git describe --tags`-`git log --format=%h -1`" >> build/package/DEBIAN/control
	$(Q)echo "Section: gnome" >> build/package/DEBIAN/control
	$(Q)echo "Priority: optional" >> build/package/DEBIAN/control
	$(Q)echo "Architecture: all" >> build/package/DEBIAN/control
	$(Q)echo "Depends: python3 (>= 3.6), python3-fuzzywuzzy, hicolor-icon-theme, pass" >> build/package/DEBIAN/control
	$(Q)echo "Recommends: gpaste" >> build/package/DEBIAN/control
	$(Q)echo "Installed-Size: `du -sk build/package/usr | grep -oE "[0-9]+"`" >> build/package/DEBIAN/control
	$(Q)echo "Maintainer: J. Nathanael Philipp <nathanael@philipp.land>" >> build/package/DEBIAN/control
	$(Q)echo "Homepage: https://github.com/jnphilipp/gnome-pass-search-provider" >> build/package/DEBIAN/control
	$(Q)echo "Description: zx2c4/pass search provider for GNOME Shell" >> build/package/DEBIAN/control
	$(Q)echo " Extends GNOME Shell search results to include zx2c4/pass passwords." >> build/package/DEBIAN/control
	$(Q)echo " Names of passwords will show up in GNOME Shell searches, choosing one will" >> build/package/DEBIAN/control
	$(Q)echo " copy the corresponding content to the clipboard. Supports pass-otp extension." >> build/package/DEBIAN/control
