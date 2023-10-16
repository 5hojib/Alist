set -e
DIR_TMP="$(mktemp -d)"

# Install spark
wget -O - https://github.com/alist-org/alist/releases/latest/download/alist-linux-musl-amd64.tar.gz | tar -zxf - -C ${DIR_TMP}
install -m 755 ${DIR_TMP}/alist /usr/bin/

rm -rf ${DIR_TMP}
