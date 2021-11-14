import tables, std/strformat
from os import getHomeDir, paramStr, paramCount
from terminal import setForegroundColor, resetAttributes, ForegroundColor

let
    TRASH_PATH*: string = getHomeDir() & ".local/share/Trash/"
    TRASH_INFO_PATH*: string = TRASH_PATH & "info/"
    TRASH_FILES_PATH*: string = TRASH_PATH & "files/"

# will set flags if any passed in
proc checkFlags*(FLAGS: Table[string, tuple[selected: bool, desc: string]]): Table[string, tuple[selected: bool, desc: string]] =
    var tbl: Table[string, tuple[selected: bool, desc: string]] = FLAGS

    if paramCount() > 0:
        for count in 1 .. paramCount():
            if tbl.hasKey(paramStr(count)):
                tbl[paramStr(count)].selected = true
            else:
                echo "Invalid flag '", paramStr(count), "' provided."
                quit()

    return tbl

proc displayHelp*(name: string, desc: string, FLAGS: Table[string, tuple[selected: bool, desc: string]]) =
    setForegroundColor(ForegroundColor.fgWhite)

    echo &"{name} -> {desc}"
    for flag in FLAGS.keys:
        echo &"\t{flag}\t->\t{FLAGS[flag].desc}"

    stdout.resetAttributes() # reset terminal colors & stuff

func `*`*(str: string, num: int): string =
    if num <= 0:
        return ""
    for item in 0 .. num:
        result &= str