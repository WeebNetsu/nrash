import os, times
from strutils import find, replace
from uri import encodeUrl

# my stuff
import common

# write data to .trashinfo file inside Trash/info/
proc writeTrashInfo(originalFileName, trashFileName: string) =
    # encodeUrl will remove all invalid characters from filename
    let filePath = encodeUrl(originalFileName, false).replace("%2F", "/") # "/" is for the file path, should not be encoded
    var time: string = $getTime() # get current time (time file was moved to trash)
    time = time[0 ..< time.find("+")] 
    try:
        # write info to .trashinfo file
        writeFile(TRASH_INFO_PATH & trashFileName & ".trashinfo", "[Trash Info]\nPath=" & filePath & "\nDeletionDate=" & time & "\n")
    except:
        echo "An error occured while trying to create .trashinfo file!"
        quit()

proc generateFileTrashName(file: string, isFile: bool): string =
    var
        fileNum: int = 1
        notified: bool = false
        trashFileName: string

    if isFile: # file names and folder names differ: folder.2 vs file.2.txt
        trashFileName = splitFile(file)[1] & splitFile(file)[2]
    else:
        trashFileName = file.replace("/", "") # "/" should not be allowed!!!
            

    while fileExists(TRASH_FILES_PATH & trashFileName) or dirExists(TRASH_FILES_PATH & trashFileName):
        fileNum += 1 # at the top, because file.1.txt is very unlikely to happen usually

        if isFile:
            trashFileName = splitFile(file)[1] & "." & $fileNum & splitFile(file)[2]
        else:
            trashFileName = file & "." & $fileNum

        if fileNum >= 10000 and not notified: # just so they know the dangers of not cleaning recycle bin!
            echo "You have more than 10000 files with the same name in your recycle bin."
            echo "Moving files to trash might become slow if you do not delete them!"
            notified = true
            sleep(5000)
        
    return trashFileName

proc main() =
    if paramCount() > 0: # if they have entered at leasat 1 parameter!
        for parameter in 1 .. paramCount(): # they can delete multiple files/folders
            let selectedFile: string = getCurrentDir() & "/" & paramStr(parameter)

            # make sure the file/folder exists
            if dirExists(selectedFile):
                let trashFileName = generateFileTrashName(paramStr(parameter), false)
                # NB! You MUST write the trash info BEFORE you move the file
                # https://specifications.freedesktop.org/trash-spec/trashspec-latest.html
                writeTrashInfo(selectedFile, trashFileName)
                try:
                    selectedFile.moveDir(TRASH_FILES_PATH & trashFileName)
                except:
                    echo "An error occured while trying to move folder to trash."
                    quit()
            elif fileExists(selectedFile):
                let trashFileName = generateFileTrashName(paramStr(parameter), true)
                writeTrashInfo(selectedFile, trashFileName)
                try:
                    selectedFile.moveFile(TRASH_FILES_PATH & trashFileName)
                except:
                    echo "An error occured while trying to move file to trash."
                    quit()
            else:
                echo "Invlid file name or file does not exist."
                quit()

            echo "Moved to trash."
    else: # otherwise, just display the help.
        echo "This is the help page! Just 'nrash filename.txt' and nrash will move it to trash."

main()