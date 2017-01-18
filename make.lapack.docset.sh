#!/bin/bash
###############################################
# Usage:
#   ./make.lapack.docset.sh [version]
#
# e.g.
#   ./make.lapack.docset.sh
###############################################

CONTENTS_DIR=lapack.docset/Contents/
RES_DIR=${CONTENTS_DIR}/Resources/
DOC_DIR=${RES_DIR}/Documents/
HTML_FILE=lapack.tar.gz

#
# Uncompress document file
#
echo "Uncompress document file"
if [ -f "$HTML_FILE" ]; then
    mkdir -p ${DOC_DIR}
    tar xf ${HTML_FILE} -C $DOC_DIR --strip-components=1
    cp icon.png icon@2x.png ${CONTENTS_DIR}/../
else
    echo ${HTML_FILE} NOT exist!
    exit 1
fi

#
# Generate Info.plist file
#
echo "Generate Info.plist file"
tee ${CONTENTS_DIR}/Info.plist >/dev/null <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>dashIndexFilePath</key>
    <string>index.html</string>
    <key>CFBundleIdentifier</key>
    <string>lapack</string>
    <key>CFBundleName</key>
    <string>LAPACK</string>
    <key>DocSetPlatformFamily</key>
    <string>lapack</string>
    <key>isDashDocset</key>
    <true/>
</dict>
</plist>
EOF

#
# Generate index database
#
echo "Generate index database"
python <<EOF
#!/usr/bin/env python

import os
import sqlite3
from bs4 import BeautifulSoup

conn = sqlite3.connect('${RES_DIR}/docSet.dsidx')
cur = conn.cursor()

try:
    cur.execute('DROP TABLE searchIndex;')
except:
    pass

cur.execute('CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, '
            'type TEXT, path TEXT);')
cur.execute('CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path);')

docpath = '${DOC_DIR}'
index_pages = ['lapack-blas.html',
               'lapack-c.html',
               'lapack-d.html',
               'lapack-i.html',
               'lapack-l.html',
               'lapack-s.html',
               'lapack-x.html',
               'lapack-z.html']

for page in index_pages:
    with open(os.path.join(docpath, page)) as f:
        soup = BeautifulSoup(f.read(), 'lxml')
        for tag in soup.select('li > a'):
            name = tag.text.strip()
            path = tag.attrs['href'].strip()
            cur.execute('INSERT OR IGNORE INTO searchIndex(name, type, path)'
                        ' VALUES (?,?,?)', (name, 'func', path))
            # print 'name: %s, path: %s' % (name, path)

conn.commit()
conn.close()
EOF
