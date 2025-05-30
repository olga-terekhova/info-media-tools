# Define the output file path
$outputFile = Join-Path -Path (Get-Location) -ChildPath "AlbumMetadataConfig.csv"

# Define the headers
$headers = "Album","Album artist","Year","Genre"

# Create an empty object with the specified headers
$emptyRow = [PSCustomObject]@{
    "Album"        = $null
    "Album artist" = $null
    "Year"         = $null
    "Genre"        = $null
}

# Export just the headers (no data)
$emptyRow | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8

Write-Host "CSV file with headers created at: $outputFile"