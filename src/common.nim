from os import getHomeDir

let 
    TRASH_PATH*: string = getHomeDir() & ".local/share/Trash/"
    TRASH_INFO_PATH*: string = TRASH_PATH & "info/"
    TRASH_FILES_PATH*: string = TRASH_PATH & "files/"