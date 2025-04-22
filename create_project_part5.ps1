# Teil 5: VS Code-Konfigurationsdateien erstellen
# ---------------------------------------------
# Speichern Sie dieses Skript als "create_project_part5.ps1"

# Definieren Sie den Projektpfad (aktuelles Verzeichnis, wenn nicht anders angegeben)
$projectPath = Get-Location

Write-Host "Erstelle VS Code-Konfigurationsdateien in: $projectPath" -ForegroundColor Green

# Erstelle tasks.json
$tasksPath = Join-Path -Path $projectPath -ChildPath ".vscode\tasks.json"
$tasksContent = @'
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "build",
            "type": "shell",
            "command": "make",
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "problemMatcher": ["$gcc"]
        },
        {
            "label": "clean",
            "type": "shell",
            "command": "make clean"
        },
        {
            "label": "deploy",
            "type": "shell",
            "command": "scp emu_display pi@raspberrypi.local:~/",
            "dependsOn": ["build"]
        },
        {
            "label": "build with script",
            "type": "shell",
            "command": "bash ./build.sh",
            "problemMatcher": ["$gcc"]
        }
    ]
}
'@
Set-Content -Path $tasksPath -Value $tasksContent
Write-Host "Datei erstellt: .vscode\tasks.json" -ForegroundColor Cyan

# Erstelle c_cpp_properties.json
$cppPropsPath = Join-Path -Path $projectPath -ChildPath ".vscode\c_cpp_properties.json"
$cppPropsContent = @'
{
    "configurations": [
        {
            "name": "Linux",
            "includePath": [
                "${workspaceFolder}/**",
                "${workspaceFolder}/include",
                "${workspaceFolder}/lib/Display/include"
            ],
            "defines": [],
            "compilerPath": "/usr/bin/gcc",
            "cStandard": "c11",
            "cppStandard": "c++14",
            "intelliSenseMode": "linux-gcc-arm"
        }
    ],
    "version": 4
}
'@
Set-Content -Path $cppPropsPath -Value $cppPropsContent
Write-Host "Datei erstellt: .vscode\c_cpp_properties.json" -ForegroundColor Cyan

# Erstelle launch.json
$launchPath = Join-Path -Path $projectPath -ChildPath ".vscode\launch.json"
$launchContent = @'
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Remote Debug",
            "type": "cppdbg",
            "request": "launch",
            "program": "/home/pi/emu_display",
            "args": [],
            "stopAtEntry": false,
            "cwd": "/home/pi",
            "environment": [],
            "externalConsole": false,
            "MIMode": "gdb",
            "miDebuggerPath": "/usr/bin/gdb",
            "miDebuggerServerAddress": "raspberrypi.local:2000",
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ]
        }
    ]
}
'@
Set-Content -Path $launchPath -Value $launchContent
Write-Host "Datei erstellt: .vscode\launch.json" -ForegroundColor Cyan

Write-Host "VS Code-Konfigurationsdateien erfolgreich erstellt!" -ForegroundColor Green
