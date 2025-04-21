#Requires AutoHotkey v2.0

; Usage & 'C:\Program Files\AutoHotkey\v2\AutoHotkey.exe' .\TeraAutoBPJS.ahk "frista" "3204320432043204"
; Usage .\autofrista.exe "frista" "3204320432043204"

Notify(text) {
    TrayTip(text, "TeraAutoBPJS Error")
}

; Function to read environment variables from a file
ReadEnvFile(filePath) {
    envVars := Map()
    try {
        envFile := FileOpen(filePath, "r")
        if !envFile {
            TrayTip("File could not be opened: " filePath)
            return {}
        }
        while !envFile.AtEOF {
            line := envFile.ReadLine()
            ; TrayTip("line: " line)
            if RegExMatch(line, "^\s*([^=]+)\s*=\s*(.*)\s*$", &matches) {
                ; TrayTip("Variable: " matches[1] " Value: " matches[2])
                envVars[Trim(matches[1])] := Trim(matches[2])
            }
        }
        envFile.Close()
        return envVars
    } catch as err {
        TrayTip("Error reading environment file: " err.Message)
        return {}
    }
}

; Path to the environment file
envFilePath := "TeraAutoBPJS.env.txt" ; Create this file in the same directory as the script

; Read environment variables
env := ReadEnvFile(envFilePath)

; Check if variables were loaded successfully
if !env {
    return ; Exit script if env file could not be loaded.
}

; Function to move mouse and click
ClickAt(x, y) {
    MouseMove(x, y, 0) ; Move mouse instantly
    Click()
}

; Function to input text
InputText(text) {
    loop StrLen(text) {
        SendInput("{Raw}" SubStr(text, A_Index, 1))
        Sleep(5) ; Delay between characters (adjust as needed)
    }
}

; Run
method := A_Args[1] ; example "frista"
keysearch := A_Args[2] ; example "3240324032043204"
switch method {
    case "frista":
        AutoFrista()
        return
    case "finger":
        AutoFinger()
        return
    default:
        Notify("Unknown method given!")
}

AutoFrista() {
    try {
        ; Path to the application executable
        appPath := env["appPath"]
        secWait := env["fristaWait"]
        milDelay := env["fristaDelay"]

        ; Login and Window Title of the Application
        loginTitle := env["loginTitle"]
        windowTitle := env["windowTitle"]

        ; Coordinates for username, password, and login button
        usernameX := env["usernameX"]
        usernameY := env["usernameY"]
        passwordX := env["passwordX"]
        passwordY := env["passwordY"]
        loginX := env["loginX"]
        loginY := env["loginY"]
        bpjsX := env["bpjsX"]
        bpjsY := env["bpjsY"]

        ; The Credentials
        username := env["username"]
        password := env["password"]

        Run(appPath)
        ; Wait for the window to become active
        WinWaitActive("ahk_exe " . loginTitle, "", secWait * 1) ; Wait up to 5 seconds

        ; Check if the window was found
        if !WinExist(loginTitle) {
            Notify("Login window not found within 5 seconds.")
            return
        }

        WinActivate(loginTitle)

        ClickAt(usernameX, usernameY)
        Sleep(100)
        InputText(username)
        Sleep(100)
        ClickAt(passwordX, passwordY)
        Sleep(100)
        InputText(password)
        Sleep(100)
        ClickAt(loginX, loginY)

        ; Wait for the window to become active
        WinWaitActive("ahk_exe " . windowTitle, "", 5) ; Wait up to 5 seconds

        ; Check if the window was found
        if !WinExist(windowTitle) {
            Notify("Application window not found within " . secWait . " seconds.")
            return
        }

        WinActivate(windowTitle)
        ClickAt(bpjsX, bpjsY)
        Sleep(100)
        InputText(keysearch)
        Sleep(100)

    } catch as e {
        Notify("An error occurred: `n" e.Stack)
    }
}

AutoFinger() {
    try {
        ; Path to the application executable
        appPath := env["appPathFinger"]
        secWait := env["fingerWait"]
        milDelay := env["fingerDelay"]

        ; Title of the Application
        appTitle := env["appTitle"]

        ; Coordinates for username, password, and login button
        usernameX := env["fpUsernameX"]
        usernameY := env["fpUsernameY"]
        passwordX := env["fpPasswordX"]
        passwordY := env["fpPasswordY"]
        loginX := env["fpLoginX"]
        loginY := env["fpLoginY"]

        ; The Credentials
        username := env["fpUsername"]
        password := env["fpPassword"]

        ; Coordinates for filling inputs
        nikX := env["fpNikX"]
        nikY := env["fpNikY"]
        inputX := env["fpInputX"]
        inputY := env["fpInputY"]

        Run(appPath)
        ; Wait for the window to become active
        WinWaitActive("ahk_exe " . appTitle, "", secWait * 1) ; Wait up to 5 seconds

        ; Check if the window was found
        if !WinExist(appTitle) {
            Notify("Login window not found within " . secWait . " seconds.")
            return
        }

        WinActivate(appTitle)

        ClickAt(usernameX, usernameY)
        Sleep(100)
        InputText(username)
        Sleep(100)
        ClickAt(passwordX, passwordY)
        Sleep(100)
        InputText(password)
        Sleep(100)
        ClickAt(loginX, loginY)

        Sleep(milDelay * 1) ; Delay between characters (adjust as needed)

        WinActivate(appTitle)
        ClickAt(nikX, nikY)
        Sleep(100)
        ClickAt(inputX, inputY)
        InputText(keysearch)
        Sleep(100)

    } catch as e {
        Notify("An error occurred: `n" e.Stack)
    }
}
