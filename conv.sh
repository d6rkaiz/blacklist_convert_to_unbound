#!/bin/bash -e

ZONEFILE="blacklist-zone.conf"
TMPZONEFILE=$ZONEFILE.tmp
WORKFILE="blacklist-zone.work"

wget -N https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn/hosts -O stevenblack.txt
tail +30 stevenblack.txt | grep -v '^\s*#.*$' | grep -v '^#' | awk '{print $2}' | tr -s '\n' > $WORKFILE

wget -N http://www.malwaredomainlist.com/hostslist/hosts.txt -O malwaredomainlist.txt
tail +7 malwaredomainlist.txt | grep -v '^#' | awk '{print $2}' | tr -d '\r' | tr -s '\n' >> $WORKFILE

wget -N http://someonewhocares.org/hosts/hosts -O someonewhocares.txt
tail +80 someonewhocares.txt| grep -v '^\s*#.*$' | grep -v '^#' | awk '{print $2}' | tr -s '\n' >> $WORKFILE

wget -N https://zerodot1.gitlab.io/CoinBlockerLists/hosts -O coinblockerlist.txt
tail +7 coinblockerlist.txt | grep -v '^#' | awk '{print $2}' | tr -d '\r' | tr -s '\n' >> $WORKFILE

cat whitelist.txt | while read LINE || [ -n "${LINE}" ]; do
  sed -i "s/^${LINE}$//" $WORKFILE
done

echo '# Converted Blacklist from https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn/hosts' >> $TMPZONEFILE
echo '# Converted Blacklist from http://www.malwaredomainlist.com/hostslist/hosts.txt' >> $TMPZONEFILE
echo '# Converted Blacklist from http://someonewhocares.org/hosts/hosts' >> $TMPZONEFILE
echo '# Converted Blacklist from https://gitlab.com/ZeroDot1/CoinBlockerLists' >> $TMPZONEFILE
echo '' >> $TMPZONEFILE
cat $WORKFILE | grep -v '^\s*$' | tr A-Z a-z | rev | sort -n | uniq | rev | sed -e 's/^\(.*\)$/local-data: \"\1 A 127.0.0.1\"/' >> $TMPZONEFILE

echo '# my blacklist' >> $TMPZONEFILE
# unbound wildcard
# local-zone: "example.com" redirect
# local-data: "example.com A 127.0.0.1"
[[ -f custom.txt ]] && cat custom.txt | sort -n | uniq | sed -e 's/^\(.*\)$/local-zone: \"\1\" redirect\nlocal-data: \"\1 A 127.0.0.1\"/' >> $TMPZONEFILE

mv $ZONEFILE{.tmp,}
rm $WORKFILE
