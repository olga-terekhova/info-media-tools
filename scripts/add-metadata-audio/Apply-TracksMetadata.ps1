# 1. Read TracksMetadataConfig.csv
$configFile = Join-Path -Path (Get-Location) -ChildPath "TracksMetadataConfig.csv"
if (-not (Test-Path $configFile)) {
    Write-Error "File 'TracksMetadataConfig.csv' not found in the current directory."
    exit 1
}

# 1.1 Create a collection of metadata objects from each data row
$trackMetadataList = Import-Csv -Path $configFile

if ($trackMetadataList.Count -eq 0) {
    Write-Error "No data rows found in TracksMetadataConfig.csv."
    exit 1
}

# 2. Get MP3 files sorted by name
$mp3Files = Get-ChildItem -Filter *.mp3 | Sort-Object Name
if ($mp3Files.Count -lt $trackMetadataList.Count) {
    Write-Error "There are fewer MP3 files than metadata rows. Check the directory."
    exit 1
}

# 3. Apply metadata to each file based on the corresponding CSV row
for ($i = 0; $i -lt $trackMetadataList.Count; $i++) {
    $file = $mp3Files[$i]
    $metadata = $trackMetadataList[$i]

    Write-Host "Processing file [$($i+1)]: $($file.Name)"

    # Example: just outputting what would be applied
    # In practice, you'd need an ID3 tagging library to write to files
    foreach ($key in $metadata.PSObject.Properties.Name) {
        $value = $metadata.$key
        Write-Host " - ${key}: ${value}"
    }

    # TODO: Apply metadata to $file (requires external tool/library)
}

Write-Host "`nDone. Metadata mapped and displayed."
