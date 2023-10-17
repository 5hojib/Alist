set -e
DIR_TMP="$(mktemp -d)"

# Install alist
wget -O - https://github.com/5hojib/alist/releases/latest/download/alist-heroku.tar.gz | tar -zxf - -C ${DIR_TMP}
install -m 755 ${DIR_TMP}/alist /usr/bin/

rm -rf ${DIR_TMP}
