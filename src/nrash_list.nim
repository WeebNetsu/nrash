import os, tables, terminal

import common

proc main() =
    let 
        FLAGS: Table[string, tuple[selected: bool, desc: string]] = checkFlags({
            "--all": (false, "Display all items in trash, do not wait for a command"), 
            # there is so many features that can be added with the col feature, such as
            # column length and how many columns to display... We'll see about implementing
            # those later, maybe the amount of columns can be calculated by the terminal
            # width instead?
            "--col": (false, "Display all items in trash (in columns)"),
            "--help": (false, "Display help"),
            "--no-color": (false, "Remove the colors")
        }.toTable())

        colored: bool = not FLAGS["--no-color"].selected

    var
        fileCount: int = 0
        allFileDetails: seq[tuple[number: int, filePath: string, kind: PathComponent]]
        noFlags = false

    for kind, path in walkDir(TRASH_FILES_PATH):
        fileCount += 1

        if FLAGS["--all"].selected: # we only handle ONE flag at a time
            displayFiles(kind, path, fileCount, false, colored)
        elif FLAGS["--help"].selected:
            displayHelp("nrash-list", "List items in trash", FLAGS)
            break
        elif FLAGS["--col"].selected:
            displayFiles(kind, path, fileCount, true, colored)
        else:
            allFileDetails.add((fileCount, path, kind))
            noFlags = true

    if FLAGS["--col"].selected:
        echo "" # just to set the input at the correct location again

    if noFlags:
        var fileNum: int = 1

        while fileNum <= fileCount:
            var file = allFileDetails[fileNum]
            displayFiles(file.kind, file.filePath, fileNum, colored=(colored))
            fileNum += 1

            if ((fileNum mod 10 == 0)) or (fileNum == fileCount - 1):
                echo "Controls:\n\tn - next\t\tp - previous\n\tq - Quit\t\t1 - Show first item" # \t\t1 - show details of first item
                let choice: string = getUserInput()

                let action = navigateList(fileNum, fileCount, choice, allFileDetails)
                fileNum = action.value

                if not action.navigate:
                    discard getTrashFileInfo(allFileDetails[fileNum], true)
                    quit()

    if FLAGS["--all"].selected:
        echo "Total of ", fileCount, " files/folders"

    if fileCount == 0:
        echo "Trash is empty"

main()

stdout.resetAttributes() # reset terminal colors & stuff once program exists