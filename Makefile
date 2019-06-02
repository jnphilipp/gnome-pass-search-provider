DATADIR?=/usr/share
DOC_DIR?=/usr/share/doc
LIBDIR?=/usr/lib


clean:
	@rm -rf ./build


deb: build/package/DEBIAN/control
	fakeroot dpkg-deb -b build/package build/gnome-pass-search-provider.deb
	lintian -Ivi --suppress-tags debian-changelog-file-missing-or-wrong-name build/gnome-pass-search-provider.deb


install: build/copyright build/changelog
	@apt install python3-fuzzywuzzy

	@install -Dm 0644 conf/org.gnome.Pass.SearchProvider.desktop "${DATADIR}"/applications/org.gnome.Pass.SearchProvider.desktop
	@install -Dm 0644 conf/org.gnome.Pass.SearchProvider.service.dbus "${DATADIR}"/dbus-1/services/org.gnome.Pass.SearchProvider.service
	@install -Dm 0644 conf/org.gnome.Pass.SearchProvider.ini "${DATADIR}"/gnome-shell/search-providers/org.gnome.Pass.SearchProvider.ini

	@mkdir -m 0755 -p "${DOC_DIR}"/gnome-pass-search-provider
	@cat build/changelog | gzip -n9 > "${DOC_DIR}"/gnome-pass-search-provider/changelog.gz
	@install -m 0755 build/copyright "${DOC_DIR}"/gnome-pass-search-provider/copyright

	@mkdir -m 0755 -p "${LIBDIR}"/gnome-pass-search-provider
	@install -Dm 0755 gnome-pass-search-provider.py "${LIBDIR}"/gnome-pass-search-provider/gnome-pass-search-provider.py
	@install -Dm 0644 conf/org.gnome.Pass.SearchProvider.service.systemd "${LIBDIR}"/systemd/user/org.gnome.Pass.SearchProvider.service

	@echo "gnome-pass-search-provider install completed."


uninstall:
	@apt remove python3-fuzzywuzzy
	@rm -r "${DOC_DIR}"/gnome-pass-search-provider
	@rm -r "${LIBDIR}"/gnome-pass-search-provider

	@rm "${DATADIR}"/applications/org.gnome.Pass.SearchProvider.desktop
	@rm "${DATADIR}"/dbus-1/services/org.gnome.Pass.SearchProvider.service
	@rm "${DATADIR}"/gnome-shell/search-providers/org.gnome.Pass.SearchProvider.ini

	@rm "${LIBDIR}"/systemd/user/org.gnome.Pass.SearchProvider.service

	@echo "gnome-pass-search-provider uninstall completed."


build:
	@mkdir build


build/changelog: build
	@git log --oneline --no-merges --format="%h %d %ai%n    %an <%ae>%n    %s" > build/changelog


build/copyright: build
	@echo "Upstream-Name: gnome-pass-search-provider\nSource: https://github.com/jnphilipp/gnome-pass-search-provider\n\nFiles: *\nCopyright: Copyright 2017-2019 Jonathan Lestrelin (jle64) <jonathan.lestrelin@gmail.com>, Nathanael Philipp (jnphilipp) <nathanael@philipp.land>\nLicense: GPL-3+\n This program is free software; you can redistribute it\n and/or modify it under the terms of the GNU General Public\n License as published by the Free Software Foundation; either\n version 3 of the License, or (at your option) any later\n version.\n .\n This program is distributed in the hope that it will be\n useful, but WITHOUT ANY WARRANTY; without even the implied\n warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR\n PURPOSE.  See the GNU General Public License for more\n details.\n .\n You should have received a copy of the GNU General Public\n License along with this package; if not, write to the Free\n Software Foundation, Inc., 51 Franklin St, Fifth Floor,\n Boston, MA  02110-1301 USA\n .\n On Debian systems, the full text of the GNU General Public\n License version 3 can be found in the file\n '/usr/share/common-licenses/GPL-3'." > build/copyright


build/package/DEBIAN: build
	@mkdir -p build/package/DEBIAN


build/package/DEBIAN/control: build/package/DEBIAN/md5sums
	@echo "Package: gnome-pass-search-provider" > build/package/DEBIAN/control
	@echo "Version: 1.0.0-`git log --format=%h -1`" >> build/package/DEBIAN/control
	@echo "Section: gnome" >> build/package/DEBIAN/control
	@echo "Priority: optional" >> build/package/DEBIAN/control
	@echo "Architecture: all" >> build/package/DEBIAN/control
	@echo "Depends: python3 (>= 3), python3-fuzzywuzzy, hicolor-icon-theme, pass" >> build/package/DEBIAN/control
	@echo "Installed-Size: `du -csk build/package/usr | grep -oE "[0-9]+\stotal" | cut -f 1`" >> build/package/DEBIAN/control
	@echo "Maintainer: Nathanael Philipp <nathanael@philipp.land>" >> build/package/DEBIAN/control
	@echo "Homepage: https://github.com/jnphilipp/gnome-pass-search-provider" >> build/package/DEBIAN/control
	@echo "Description: zx2c4/pass search provider for GNOME Shell" >> build/package/DEBIAN/control
	@echo " Extends GNOME Shell search results to include zx2c4/pass passwords.\n Names of passwords will show up in GNOME Shell searches, choosing one will\n copy the corresponding content to the clipboard. Supports pass-otp extension." >> build/package/DEBIAN/control


build/package/DEBIAN/md5sums: gnome-pass-search-provider.py conf/org.gnome.Pass.SearchProvider.ini conf/org.gnome.Pass.SearchProvider.desktop conf/org.gnome.Pass.SearchProvider.service.dbus conf/org.gnome.Pass.SearchProvider.service.systemd build/copyright build/changelog build/package/DEBIAN

	@mkdir -m 755 -p build/package"${DATADIR}"/applications
	@mkdir -m 755 -p build/package"${DATADIR}"/dbus-1/services
	@mkdir -m 755 -p build/package"${DATADIR}"/gnome-shell/search-providers
	@mkdir -m 755 -p build/package"${DOC_DIR}"/gnome-pass-search-provider
	@mkdir -m 755 -p build/package"${LIBDIR}"/gnome-pass-search-provider
	@mkdir -m 755 -p build/package"${LIBDIR}"/systemd/user

	@cp conf/org.gnome.Pass.SearchProvider.ini build/package"${DATADIR}"/gnome-shell/search-providers/org.gnome.Pass.SearchProvider.ini
	@chmod 0644 build/package"${DATADIR}"/gnome-shell/search-providers/org.gnome.Pass.SearchProvider.ini

	@cp conf/org.gnome.Pass.SearchProvider.desktop build/package"${DATADIR}"/applications/org.gnome.Pass.SearchProvider.desktop
	@chmod 0644 build/package"${DATADIR}"/applications/org.gnome.Pass.SearchProvider.desktop

	@cp conf/org.gnome.Pass.SearchProvider.service.dbus build/package"${DATADIR}"/dbus-1/services/org.gnome.Pass.SearchProvider.service
	@chmod 0644 build/package"${DATADIR}"/dbus-1/services/org.gnome.Pass.SearchProvider.service

	@cp gnome-pass-search-provider.py build/package"${LIBDIR}"/gnome-pass-search-provider/gnome-pass-search-provider.py
	@chmod 0755 build/package"${LIBDIR}"/gnome-pass-search-provider/gnome-pass-search-provider.py

	@cp conf/org.gnome.Pass.SearchProvider.service.systemd build/package"${LIBDIR}"/systemd/user/org.gnome.Pass.SearchProvider.service
	@chmod 0644 build/package"${LIBDIR}"/systemd/user/org.gnome.Pass.SearchProvider.service

	@cat build/changelog | gzip -n9 > build/package"${DOC_DIR}"/gnome-pass-search-provider/changelog.gz
	@chmod 0644 build/package"${DOC_DIR}"/gnome-pass-search-provider/changelog.gz

	@cp build/copyright build/package"${DOC_DIR}"/gnome-pass-search-provider/copyright
	@chmod 644 build/package"${DOC_DIR}"/gnome-pass-search-provider/copyright

	@mkdir -p build/package/DEBIAN
	@md5sum `find build/package -type f -not -path "*DEBIAN*"` > build/md5sums
	@sed -e "s/build\/package\///" build/md5sums > build/package/DEBIAN/md5sums
	@chmod 644 build/package/DEBIAN/md5sums
