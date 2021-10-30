import os, tables, terminal
# from strutils import parseInt

import common

let FLAGS: Table[string, bool] = checkFlags({ "--all": false, "--col": false }.toTable())

var 
    fileCount: int = 0
    filesAndNumber: seq[tuple[number: int, file: string, kind: string]]

for kind, path in walkDir(TRASH_FILES_PATH):
    fileCount += 1

    if FLAGS["--all"]:
        if kind == pcFile:
            setForegroundColor(ForegroundColor.fgCyan)
            echo("File: ", splitPath(path).tail)
        elif kind == pcDir:
            setForegroundColor(ForegroundColor.fgBlue)
            echo("Folder: ", splitPath(path).tail)
        else:
            setForegroundColor(ForegroundColor.fgWhite)
            echo("Link: ", splitPath(path).tail)
    else:
        filesAndNumber.add((fileCount, path, $kind))

        if fileCount >= 200:
            echo "Limit of viewable files is 200."
            break

    # if (fileCount mod 10 == 0) and not FLAGS["--all"]:
    #     echo "Controls:\n\tn - next\t\tp - previous\n\t1 - show details of first item"
    #     let choice: string = readLine(stdin)
    #     try:
    #         let item: int = choice.parseInt()
    #     except ValueError:
    #         continue

if FLAGS["--all"]:
    echo "Total of ", fileCount, " files/folders"

system.addQuitProc(resetAttributes) # reset terminal colors & stuff