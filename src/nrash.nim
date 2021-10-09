import os, times

from strutils import find, replace

let TRASH_PATH: string = getHomeDir() & ".local/share/Trash/"

proc writeTrashInfo(originalFileName, trashFileName: string) =
    let filePath = originalFileName.replace(" ", "%20")
    var time: string = $getTime()
    time = time[0 ..< time.find("+")]
    writeFile(TRASH_PATH & "info/" & trashFileName & ".trashinfo", "[Trash Info]\nPath=" & filePath & "\nDeletionDate=" & time & "\n")


proc generateFileTrashName(file: string, isFile: bool): string =
    var
        fileNum: int = 1
        notified: bool = false
        trashFileName: string
        exists: bool

    if isFile:
        trashFileName = splitFile(file)[1] & splitFile(file)[2]
        exists = fileExists(TRASH_PATH & trashFileName)
    else:
        trashFileName = file
        exists = dirExists(TRASH_PATH & trashFileName)

    while exists:
        fileNum += 1

        if isFile:
            trashFileName = splitFile(file)[1] & "." & $fileNum & splitFile(file)[2]
            exists = fileExists(TRASH_PATH & "files/" & trashFileName)
        else:
            trashFileName = file & "." & $fileNum
            exists = dirExists(TRASH_PATH & "files/" & trashFileName)

        if fileNum >= 10000 and not notified:
            echo "You have more than 10000 files with the same name in your recycle bin."
            echo "Moving files to trash might become slow if you do not delete them!"
            notified = true
            sleep(5000)
        
    return trashFileName

if paramCount() > 0:
    for parameter in 1 .. paramCount():
        let selectedFile: string = getCurrentDir() & "/" & paramStr(parameter)

        # make sure the file/folder exists
        if dirExists(selectedFile):
            let trashFileName = generateFileTrashName(paramStr(parameter), false)
            # NB! You MUST write the trash info BEFORE you move the file
            # https://specifications.freedesktop.org/trash-spec/trashspec-latest.html
            writeTrashInfo(selectedFile, trashFileName)
            selectedFile.moveDir(TRASH_PATH & "files/" & trashFileName)
        elif fileExists(selectedFile):
            let trashFileName = generateFileTrashName(paramStr(parameter), true)
            writeTrashInfo(selectedFile, trashFileName)
            selectedFile.moveFile(TRASH_PATH & "files/" & trashFileName)
        else:
            echo "Invlid file name or file does not exist."
            quit()

        echo "Moved to trash."
