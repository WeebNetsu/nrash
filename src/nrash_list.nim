import os

import common

for kind, path in walkDir(TRASH_FILES_PATH):
    echo kind, ": ", splitPath(path).tail