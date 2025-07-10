# Get the folder where this script is located (e.g., ...\scripts)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Go up two levels to the main directory (e.g., ...\youtube playlist downloader)
$baseDir = Split-Path (Split-Path $scriptDir)

# Define source (downloads) and destination (music_files) folders
$sourceFolder = Join-Path $baseDir "downloads"
$targetFolder = Join-Path $baseDir "music_files"

# Flag file path to indicate duplicates were found and deleted
$flagFile = Join-Path $scriptDir "duplicates_found.flag"

# Remove previous flag file if exists
if (Test-Path $flagFile) {
    Remove-Item $flagFile -Force
}

# === 1. Move MP3s from downloads to music_files ===
Write-Host "`n--------------------------------------------------" -ForegroundColor Cyan -BackgroundColor Black
Write-Host "Moving MP3 files from downloads to music_files..." -ForegroundColor Cyan -BackgroundColor Black
Write-Host "--------------------------------------------------`n" -ForegroundColor Cyan -BackgroundColor Black

if (Test-Path $sourceFolder) {
    $mp3Files = Get-ChildItem -Path $sourceFolder -Filter *.mp3 -File -ErrorAction SilentlyContinue

    if ($mp3Files.Count -gt 0) {
        if (-not (Test-Path $targetFolder)) {
            New-Item -Path $targetFolder -ItemType Directory | Out-Null
        }

        foreach ($file in $mp3Files) {
            try {
                $destination = Join-Path -Path $targetFolder -ChildPath $file.Name
                Copy-Item -Path $file.FullName -Destination $destination -Force
                Remove-Item -Path $file.FullName -Force
                Write-Host "Moved: $($file.Name)" -ForegroundColor Green -BackgroundColor Black
            } catch {
                Write-Host "Failed to move $($file.Name): $_" -ForegroundColor Red -BackgroundColor Black
            }
        }
    } else {
        Write-Host "No MP3 files found in 'downloads' folder." -ForegroundColor DarkGray -BackgroundColor Black
    }
} else {
    Write-Host "'downloads' folder not found." -ForegroundColor Red -BackgroundColor Black
}

# === 2. Scan for duplicates in music_files ===
Write-Host "`n--------------------------------------------------" -ForegroundColor Cyan -BackgroundColor Black
Write-Host "Scanning for duplicate MP3s by title metadata..." -ForegroundColor Cyan -BackgroundColor Black
Write-Host "--------------------------------------------------`n" -ForegroundColor Cyan -BackgroundColor Black

$shell = New-Object -ComObject Shell.Application
$folder = $shell.Namespace($targetFolder)

$tracks = Get-ChildItem -Path $targetFolder -Filter *.mp3 | ForEach-Object {
    $file = $_
    $item = $folder.ParseName($file.Name)
    $title = $folder.GetDetailsOf($item, 21)  # Title

    [PSCustomObject]@{
        Path  = $file.FullName
        Title = $title.Trim()
    }
}

# Group by Title and find duplicates
$duplicates = $tracks | Where-Object { $_.Title -ne "" } |
              Group-Object -Property Title | Where-Object { $_.Count -gt 1 }

if ($duplicates.Count -gt 0) {
    foreach ($group in $duplicates) {
        Write-Host "`nDuplicate Title: $($group.Name)" -ForegroundColor Yellow -BackgroundColor Black

        $group.Group | Select-Object -Skip 1 | ForEach-Object {
            Write-Host "Deleting duplicate file: $($_.Path)" -ForegroundColor Red -BackgroundColor Black
            Remove-Item $_.Path -Force
        }
    }
    # Create flag file to notify duplicates were found
    New-Item -Path $flagFile -ItemType File -Force | Out-Null
} else {
    Write-Host "No duplicates found." -ForegroundColor Green -BackgroundColor Black
}

# Find files to rename (numeric base names with length < 5)
$filesToRename = Get-ChildItem -Path $targetFolder -Filter *.mp3 | Where-Object {
    $_.BaseName -match '^\d+$' -and ($_.BaseName.Length -lt 5)
}

if ($filesToRename.Count -gt 0) {
    Write-Host "`n--------------------------------------------------" -ForegroundColor Cyan -BackgroundColor Black
    Write-Host "Renaming MP3 files to 5-digit zero-padded filenames..." -ForegroundColor Cyan -BackgroundColor Black
    Write-Host "--------------------------------------------------`n" -ForegroundColor Cyan -BackgroundColor Black

    # Step 1: Temporary rename by adding 1,000,000 offset
    foreach ($file in $filesToRename) {
        $num = [int]$file.BaseName
        $tempNum = $num + 1000000
        $tempName = "{0}.mp3" -f $tempNum
        try {
            Rename-Item -Path $file.FullName -NewName $tempName -Force
            Write-Host "Temporarily renamed $($file.Name) to $tempName" -ForegroundColor DarkYellow -BackgroundColor Black
        } catch {
            Write-Host "Failed temporary rename $($file.Name): $_" -ForegroundColor Red -BackgroundColor Black
        }
    }

    # Step 2: Rename temp files back to 5-digit padded names
    Get-ChildItem -Path $targetFolder -Filter '1??????.mp3' | ForEach-Object {
        if ($_.BaseName -match '^1(\d+)$') {
            $tempNum = [int]$matches[1]
            $newName = "{0:D5}.mp3" -f $tempNum
            $newPath = Join-Path -Path $targetFolder -ChildPath $newName

            if (-not (Test-Path $newPath)) {
                try {
                    Rename-Item -Path $_.FullName -NewName $newName -Force
                    Write-Host "Renamed $($_.Name) to $newName" -ForegroundColor Cyan -BackgroundColor Black
                } catch {
                    Write-Host "Failed final rename $($_.Name): $_" -ForegroundColor Red -BackgroundColor Black
                }
            } 
        }
    }
} else {
    Write-Host "`nNo MP3 files to rename." -ForegroundColor DarkGray -BackgroundColor Black
}

Write-Host "`nDuplicate cleanup and renaming done!" -ForegroundColor Cyan -BackgroundColor Black
