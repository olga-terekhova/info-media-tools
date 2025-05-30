# Remove timestamps from text files in current directory
# Usage: .\Remove-Timestamps.ps1
# Processes all .txt files in the current directory

$OutputSuffix = "-txtonly"

# Get all .txt files in the current directory
$files = Get-ChildItem -Path "*.txt" -File

if ($files.Count -eq 0) {
    Write-Host "No files found matching the specified path." -ForegroundColor Red
    exit
}

foreach ($file in $files) {
    Write-Host "Processing: $($file.Name)" -ForegroundColor Green
    
    try {
        # Read all lines from the file, preserving original encoding
        $content = Get-Content -Path $file.FullName -Encoding UTF8
        
        # Remove timestamp pattern from the beginning of each line
        # Pattern matches: [HH:MM:SS.SSS --> HH:MM:SS.SSS] or [MM:SS.SSS --> MM:SS.SSS] at the start of a line
        $cleanedContent = $content | ForEach-Object {
            $_ -replace '^\[\d{1,2}:\d{2}:\d{2}\.\d{3} --> \d{1,2}:\d{2}:\d{2}\.\d{3}\]\s*', '' -replace '^\[\d{2}:\d{2}\.\d{3} --> \d{2}:\d{2}\.\d{3}\]\s*', ''
        }
        
        # Create output file path with suffix
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        $extension = $file.Extension
        $outputPath = "$baseName$OutputSuffix$extension"
        
        # Write cleaned content to output file, preserving encoding
        $cleanedContent | Set-Content -Path $outputPath -Encoding UTF8
        
        Write-Host "Cleaned file saved as: $outputPath" -ForegroundColor Cyan
        
        # Show statistics
        $originalLines = $content.Count
        $cleanedLines = ($cleanedContent | Where-Object { $_.Trim() -ne "" }).Count
        $removedTimestamps = ($content | Where-Object { $_ -match '^\[\d{1,2}:\d{2}:\d{2}\.\d{3} --> \d{1,2}:\d{2}:\d{2}\.\d{3}\]|^\[\d{2}:\d{2}\.\d{3} --> \d{2}:\d{2}\.\d{3}\]' }).Count
        
        Write-Host "  - Original lines: $originalLines" -ForegroundColor Gray
        Write-Host "  - Timestamps removed: $removedTimestamps" -ForegroundColor Gray
        
    } catch {
        Write-Host "Error processing $($file.Name): $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`nProcessing complete!" -ForegroundColor Green