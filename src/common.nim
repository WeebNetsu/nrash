import tables
from os import getHomeDir, paramStr, paramCount

let 
    TRASH_PATH*: string = getHomeDir() & ".local/share/Trash/"
    TRASH_INFO_PATH*: string = TRASH_PATH & "info/"
    TRASH_FILES_PATH*: string = TRASH_PATH & "files/"

proc checkFlags*(FLAGS: Table[string, bool]): Table[string, bool] =
    var tbl = FLAGS
    
    if paramCount() > 0:
        for count in 1 .. paramCount():
            if tbl.hasKey(paramStr(count)):
                tbl[paramStr(count)] = true
            else:
                echo "Invalid flag '", paramStr(count), "' provided."
                quit()
                
    return tbl