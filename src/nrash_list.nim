import os, tables, terminal

from std/strutils import parseInt, toLowerAscii
from system import quit

import common

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

proc main() =
    let FLAGS: Table[string, tuple[selected: bool, desc: string]] = checkFlags({
        "--all": (false, "Display all items in trash, do not wait for a command"), 
        # "--col": (false, "Display all items in trash (in columns)"), 
        "--help": (false, "Display help"), 
        }.toTable())

    var
        fileCount: int = 0
        allFileDetails: seq[tuple[number: int, filePath: string, kind: PathComponent]]
        no_flags = false

    for kind, path in walkDir(TRASH_FILES_PATH):
        fileCount += 1

        if FLAGS["--all"].selected: # we only handle ONE flag at a time
            displayFiles(kind, path, fileCount)
        elif FLAGS["--help"].selected:
            displayHelp("nrash-list", "List items in trash", FLAGS)
            break
        else:
            allFileDetails.add((fileCount, path, kind))
            noFlags = true

    if noFlags:
        var fileNum: int = 1

        while fileNum <= fileCount:
            var file = allFileDetails[fileNum]
            displayFiles(file.kind, file.filePath, fileNum)
            fileNum += 1

            if ((fileNum mod 10 == 0)) or (fileNum == fileCount - 1):
                echo "Controls:\n\tn - next\t\tp - previous\n\tq - Quit" # \t\t1 - show details of first item
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

    if FLAGS["--all"].selected:
        echo "Total of ", fileCount, " files/folders"

main()

stdout.resetAttributes() # reset terminal colors & stuff once program exists