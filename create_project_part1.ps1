# Teil 1: Verzeichnisstruktur erstellen
# ---------------------------------------
# Speichern Sie dieses Skript als "create_project_part1.ps1"

# Definieren Sie den Projektpfad (aktuelles Verzeichnis, wenn nicht anders angegeben)
$projectPath = Get-Location

Write-Host "Erstelle Projektstruktur in: $projectPath" -ForegroundColor Green

# Erstelle Hauptverzeichnisse
$directories = @(
    "src",
    "src\can",
    "src\data",
    "include",
    "lib",
    "lib\Display\src",
    "lib\Display\include",
    "build",
    ".vscode"
)

foreach ($dir in $directories) {
    $path = Join-Path -Path $projectPath -ChildPath $dir
    if (-not (Test-Path -Path $path)) {
        New-Item -ItemType Directory -Path $path | Out-Null
        Write-Host "Verzeichnis erstellt: $dir" -ForegroundColor Cyan
    } else {
        Write-Host "Verzeichnis existiert bereits: $dir" -ForegroundColor Yellow
    }
}

Write-Host "Verzeichnisstruktur erfolgreich erstellt!" -ForegroundColor Green
