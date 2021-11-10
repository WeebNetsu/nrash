import os, tables, terminal

from std/strutils import parseInt, toLowerAscii
from system import quit

import common

let FLAGS: Table[string, bool] = checkFlags({ "--all": false, "--col": false }.toTable())

var
    fileCount: int = 0
    filesAndNumbers: seq[tuple[number: int, filePath: string, kind: PathComponent]]
    no_flags = false

proc displayFiles(kind: PathComponent, path: string) =
    if kind == pcFile:
        setForegroundColor(ForegroundColor.fgCyan)
        echo("File: ", splitPath(path).tail)
    elif kind == pcDir:
        setForegroundColor(ForegroundColor.fgBlue)
        echo("Folder: ", splitPath(path).tail)
    else:
        setForegroundColor(ForegroundColor.fgWhite)
        echo("Link: ", splitPath(path).tail)

    stdout.resetAttributes() # reset terminal colors & stuff

for kind, path in walkDir(TRASH_FILES_PATH):
    fileCount += 1

    if FLAGS["--all"]:
        displayFiles(kind, path)
    else:
        filesAndNumbers.add((fileCount, path, kind))
        noFlags = true

        if fileCount >= 200:
            echo "Limit of viewable files is 200."
            break

if noFlags:
    var fileNum = 0

    for fileAndNumber in filesAndNumbers:

        displayFiles(fileAndNumber.kind, fileAndNumber.filePath)
        fileNum += 1

        if (fileNum mod 10 == 0) or (fileNum == filesAndNumbers.len()):
            echo "Controls:\n\tn - next\t\tp - previous\n\tq - Quit\t\t1 - show details of first item"
            let choice: string = readLine(stdin)
            try:
                let item: int = choice.parseInt()
                echo "Chosen File: ", item
            except ValueError: # if user entered a string
                if choice.toLowerAscii() == "p":
                    fileNum -= 10 # todo: check that it can subtract by 10
                elif choice.toLowerAscii() == "q":
                    quit()


if FLAGS["--all"]:
    echo "Total of ", fileCount, " files/folders"

stdout.resetAttributes() # reset terminal colors & stuff once program exists