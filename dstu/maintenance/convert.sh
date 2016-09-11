find $1 -name '*.html' -exec /usr/bin/iconv --verbose -f $2 -t $3 {} > {}.2 \;
