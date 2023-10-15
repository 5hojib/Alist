#!/bin/bash
appName="alist"
builtAt="$(date +'%F %T %z')"
goVersion=$(go version | sed 's/go version //')
gitAuthor="Xhofe <i@nn.ci>"
gitCommit=$(git log --pretty=format:"%h" -1)
version=$(git describe --abbrev=0 --tags)
webVersion=$(wget -qO- -t1 -T2 "https://api.github.com/repos/5hojib/Spark-web/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g')

echo "backend version: $version"
echo "frontend version: $webVersion"

ldflags="\
-w -s \
-X 'github.com/alist-org/alist/v3/internal/conf.BuiltAt=$builtAt' \
-X 'github.com/alist-org/alist/v3/internal/conf.GoVersion=$goVersion' \
-X 'github.com/alist-org/alist/v3/internal/conf.GitAuthor=$gitAuthor' \
-X 'github.com/alist-org/alist/v3/internal/conf.GitCommit=$gitCommit' \
-X 'github.com/alist-org/alist/v3/internal/conf.Version=$version' \
-X 'github.com/alist-org/alist/v3/internal/conf.WebVersion=$webVersion' \
"

FetchWebRelease() {
  curl -L https://github.com/5hojib/Spark-web/releases/latest/download/dist.tar.gz -o dist.tar.gz
  tar -zxvf dist.tar.gz
  rm -rf public/dist
  mv -f dist public
  rm -rf dist.tar.gz
}

BuildReleaseLinuxMusl() {
  rm -rf .git/
  mkdir -p "build"
  muslflags="--extldflags '-static -fpic' $ldflags"
  BASE="https://musl.nn.ci/"
  FILES=(x86_64-linux-musl-cross)
  i="${FILES[0]}"
  url="${BASE}${i}.tgz"
  curl -L -o "${i}.tgz" "${url}"
  sudo tar xf "${i}.tgz" --strip-components 1 -C /usr/local
  rm -f "${i}.tgz"
  os_arch="linux-musl-amd64"
  echo "building for $os_arch"
  export GOOS=${os_arch%%-*}
  export GOARCH=${os_arch##*-}
  export CC="x86_64-linux-musl-gcc"
  export CGO_ENABLED=1
  go build -o ./build/$appName-$os_arch -ldflags="$muslflags" -tags=jsoniter .
}

MakeRelease() {
  cd build
  mkdir compress
  for i in $(find . -type f -name "$appName-linux-*"); do
    cp "$i" alist
    tar -czvf compress/spark-heroku.tar.gz alist
    rm -f alist
  done
  cd compress
  find . -type f -print0 | xargs -0 md5sum >"$1"
  cat "$1"
  cd ../..
}

if [ "$1" = "release" ]; then
  FetchWebRelease
  if [ "$2" = "heroku" ]; then
    BuildReleaseLinuxMusl
    MakeRelease "md5-spark.txt"
  fi
fi
