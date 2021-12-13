#! NOTE: This file requires Nim version 1.6.0

import tables, strformat
from os import getHomeDir, paramStr, paramCount, PathComponent, splitPath
from terminal import setForegroundColor, resetAttributes, ForegroundColor
from strutils import toLowerAscii, parseInt

let
    TRASH_PATH*: string = getHomeDir() & ".local/share/Trash/"
    TRASH_INFO_PATH*: string = TRASH_PATH & "info/"
    TRASH_FILES_PATH*: string = TRASH_PATH & "files/"

proc showError*(msg: string) =
    setForegroundColor(ForegroundColor.fgRed)
    echo "ERROR: ", msg
    stdout.resetAttributes() # reset terminal colors & stuff
    quit()

proc getUserInput*(): string =
    stdout.write("> ")
    return readLine(stdin)

# will set flags if any passed in
proc checkFlags*(FLAGS: Table[string, tuple[selected: bool, desc: string]]): Table[string, tuple[selected: bool, desc: string]] =
    var tbl: Table[string, tuple[selected: bool, desc: string]] = FLAGS

    if paramCount() > 0:
        for count in 1 .. paramCount():
            if tbl.hasKey(paramStr(count)):
                tbl[paramStr(count)].selected = true
            else:
                showError(&"Invalid flag '{paramStr(count)}' provided.")

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

func shortendFileName*(str: string, length: int = 15): string =
    if str.len() >= length: 
        return str[0 .. length - 3] & "..."
    else: 
        return str & " " * (length - str.len())

proc displayFiles*(kind: PathComponent, path: string, number: int, inCols: bool = false, colored: bool) =
    let endLineChar: char = if number mod 3 == 0: '\n' else: '\t'
    var output: string
    if inCols:
        output = shortendFileName(splitPath(path).tail) & endLineChar
    else:
        output = &"[{number}] File: {splitPath(path).tail}\n"

    if kind == pcFile:
        if colored:
            setForegroundColor(ForegroundColor.fgCyan)
        stdout.write(output)
    elif kind == pcDir:
        if colored:
            setForegroundColor(ForegroundColor.fgBlue)
        stdout.write(output)
    else:
        if colored:
            setForegroundColor(ForegroundColor.fgWhite)
        stdout.write(output)

    stdout.resetAttributes() # reset terminal colors & stuff

proc navigateList*(fileNum: int, fileCount: int, input: string, allFileDetails: seq[tuple[number: int, filePath: string, kind: PathComponent]]): tuple[navigate: bool, value: int] =
    result = (true, fileNum)
    try:
        let item: int = input.parseInt()
        if item >= fileCount:
            echo "No file with number ", item, " found."
            result.value -= 10 # for now will work, but change so it doesn't display the files again
        else:
            result = (false, item)
    except ValueError: # if user entered a string
        if input.toLowerAscii() == "p":
            if result.value >= 20:
                result.value -= 20
                if result.value < 1:
                    result.value += 1
                echo "Going back"
            else:
                echo "Can't go back, you're already at the start!"
        elif input.toLowerAscii() == "q":
            quit()