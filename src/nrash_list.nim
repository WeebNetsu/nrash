import os, tables, terminal

from std/strutils import parseInt, toLowerAscii
from system import quit

import common

let FLAGS: Table[string, bool] = checkFlags({ "--all": false, "--col": false }.toTable())

var
    fileCount: int = 0
    allFileDetails: seq[tuple[number: int, filePath: string, kind: PathComponent]]
    no_flags = false

proc displayFiles(kind: PathComponent, path: string, number: int) =
    if kind == pcFile:
        setForegroundColor(ForegroundColor.fgCyan)
        echo("[", number ,"] File: ", splitPath(path).tail)
    elif kind == pcDir:
        setForegroundColor(ForegroundColor.fgBlue)
        echo("[", number ,"] Folder: ", splitPath(path).tail)
    else:
        setForegroundColor(ForegroundColor.fgWhite)
        echo("[", number ,"] Link: ", splitPath(path).tail)

    stdout.resetAttributes() # reset terminal colors & stuff

for kind, path in walkDir(TRASH_FILES_PATH):
    fileCount += 1

    if FLAGS["--all"]:
        displayFiles(kind, path, fileCount)
    else:
        allFileDetails.add((fileCount, path, kind))
        noFlags = true

        if fileCount >= 200:
            echo "Limit of viewable files is 200."
            break

if noFlags:
    var fileNum: int = 1
    while fileNum <= fileCount:
        var file = allFileDetails[fileNum]
        displayFiles(file.kind, file.filePath, fileNum)
        fileNum += 1

        if ((fileNum mod 10 == 0)) or (fileNum == fileCount - 1):
            echo "Controls:\n\tn - next\t\tp - previous\n\tq - Quit\t\t1 - show details of first item"
            let choice: string = readLine(stdin)
            try:
                let item: int = choice.parseInt()
                if item >= fileCount:
                    echo "No file with number ", item, " found."
                    fileNum -= 10 # for now will work, but change so it doesn't display the files again
                else:
                    echo "Chosen File: ", allFileDetails[item]
            except ValueError: # if user entered a string
                if choice.toLowerAscii() == "p":
                    if fileNum >= 20:
                        fileNum -= 20
                        echo "Going back"
                    else:
                        echo "Can't go back, you're already at the start!"
                elif choice.toLowerAscii() == "q":
                    quit()


if FLAGS["--all"]:
    echo "Total of ", fileCount, " files/folders"

stdout.resetAttributes() # reset terminal colors & stuff once program exists