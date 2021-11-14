import os, tables, terminal, std/strformat

from std/strutils import parseInt, toLowerAscii
from system import quit

import common

func shortendFileName(str: string, length: int = 15): string =
    if str.len() >= length: 
        return str[0 .. length - 3] & "..."
    else: 
        return str & " " * (length - str.len())

proc displayFiles(kind: PathComponent, path: string, number: int, inCols: bool = false) =
    let endLineChar: char = if number mod 3 == 0: '\n' else: '\t'
    var output: string

    if inCols:
        output = shortendFileName(splitPath(path).tail) & endLineChar
    else:
        output = &"[{number}] File: {splitPath(path).tail}\n"

    if kind == pcFile:
        setForegroundColor(ForegroundColor.fgCyan)
        stdout.write(output)
    elif kind == pcDir:
        setForegroundColor(ForegroundColor.fgBlue)
        stdout.write(output)
    else:
        setForegroundColor(ForegroundColor.fgWhite)
        stdout.write(output)

    stdout.resetAttributes() # reset terminal colors & stuff

proc main() =
    let FLAGS: Table[string, tuple[selected: bool, desc: string]] = checkFlags({
        "--all": (false, "Display all items in trash, do not wait for a command"), 
        # there is so many features that can be added with the col feature, such as
        # column length and how many columns to display... We'll see about implementing
        # those later, maybe the amount of columns can be calculated by the terminal
        # width instead?
        "--col": (false, "Display all items in trash (in columns)"),
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
        elif FLAGS["--col"].selected:
            displayFiles(kind, path, fileCount, true)
        else:
            allFileDetails.add((fileCount, path, kind))
            noFlags = true

    if FLAGS["--col"].selected:
        echo "" # just to set the input at the correct location again

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