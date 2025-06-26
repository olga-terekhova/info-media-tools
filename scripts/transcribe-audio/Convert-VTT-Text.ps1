# Remove timestamps from VTT files in current directory and saves as TXT
# Usage: .\Convert-VTT-Text.ps1
# Processes all .vtt files in the current directory

$OutputSuffix = "-txtonly"

# Get all .txt files in the current directory
$files = Get-ChildItem -Path "*.vtt" -File

if ($files.Count -eq 0) {
    Write-Host "No files found matching the specified path." -ForegroundColor Red
    exit
}

foreach ($file in $files) {
    Write-Host "Processing: $($file.Name)" -ForegroundColor Green
    try {
	


	# Read all lines
	$lines = Get-Content -Path $File

	# Prepare a list to store subtitle text
	$textOnly = @()

	foreach ($line in $lines) {
 	   $trimmed = $line.Trim()

 	   # Skip empty lines, timestamp lines, and metadata
 	   if ($trimmed -eq "") { continue }
 	   if ($trimmed -match "-->") { continue }
  	  if ($trimmed -match "^(WEBVTT|NOTE)") { continue }
  	  if ($trimmed -match "^\d+$") { continue }

 	   # Keep the line
  	  $textOnly += $trimmed
	}



	# Create output file path with suffix
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        $extension = ".txt"
        $outputPath = "$baseName$OutputSuffix$extension"
        
        # Write cleaned content to output file, preserving encoding
        $textOnly | Set-Content -Path $outputPath -Encoding UTF8
        
        Write-Host "Cleaned file saved as: $outputPath" -ForegroundColor Cyan
     }
     catch {
        Write-Host "Error processing $($file.Name): $($_.Exception.Message)" -ForegroundColor Red
     }
    
}

Write-Host "`nProcessing complete!" -ForegroundColor Green