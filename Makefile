DATADIR?=/usr/share
LIBDIR?=/usr/lib
LIBEXECDIR?=/usr/lib/
SYSCONFDIR?=/etc
PIPARGS?= # use --user for local install

install:
	@pip3 install ${PIPARGS} fuzzywuzzy

	@install -Dm 0755 gnome-pass-search-provider.py "${LIBEXECDIR}"/gnome-pass-search-provider/gnome-pass-search-provider.py

	@install -Dm 0644 conf/org.gnome.Pass.SearchProvider.ini "${DATADIR}"/gnome-shell/search-providers/org.gnome.Pass.SearchProvider.ini

	@install -Dm 0644 conf/org.gnome.Pass.SearchProvider.desktop "${DATADIR}"/applications/org.gnome.Pass.SearchProvider.desktop

	@install -Dm 0644 conf/org.gnome.Pass.SearchProvider.service.dbus "${DATADIR}"/dbus-1/services/org.gnome.Pass.SearchProvider.service
	@install -Dm 0644 conf/org.gnome.Pass.SearchProvider.service.systemd "${LIBDIR}"/systemd/user/org.gnome.Pass.SearchProvider.service
