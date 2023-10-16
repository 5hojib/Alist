set -e
DIR_TMP="$(mktemp -d)"

# Install spark
wget -O - https://github.com/5hojib/Spark/releases/latest/download/spark-heroku.tar.gz | tar -zxf - -C ${DIR_TMP}
install -m 755 ${DIR_TMP}/Spark /usr/bin/

rm -rf ${DIR_TMP}
