# Teil 6: README und Hauptskript erstellen
# ---------------------------------------
# Speichern Sie dieses Skript als "create_project_part6.ps1"

# Definieren Sie den Projektpfad (aktuelles Verzeichnis, wenn nicht anders angegeben)
$projectPath = Get-Location

Write-Host "Erstelle README und Hauptskript in: $projectPath" -ForegroundColor Green

# Erstelle README.md
$readmePath = Join-Path -Path $projectPath -ChildPath "README.md"
$readmeContent = @'
# EMU Black Display

Ein Projekt zur Anzeige von EMU Black ECU-Daten auf einem Display mit einem Raspberry Pi Zero 2 W.

## Projektstruktur

