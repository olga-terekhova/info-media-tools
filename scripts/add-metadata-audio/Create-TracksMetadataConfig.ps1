# Load album-wide metadata from AlbumMetadataConfig.csv
$configFile = Join-Path -Path (Get-Location) -ChildPath "AlbumMetadataConfig.csv"
if (-not (Test-Path $configFile)) {
    Write-Error "File 'AlbumMetadataConfig.csv' not found in the current directory."
    exit 1
}

$configData = Import-Csv -Path $configFile
if ($configData.Count -eq 0) {
    Write-Error "The CSV file contains no data rows."
    exit 1
}

# Extract album-wide metadata from the first row
$row = $configData[0]
$album        = $row.'Album'
$album_artist = $row.'Album artist'
$year         = $row.'Year'
$genre        = $row.'Genre'

# Prepare Shell COM object to read MP3 metadata
$shell = New-Object -ComObject Shell.Application
$folder = $shell.Namespace((Get-Location).Path)
$folderItems = Get-ChildItem -Filter *.mp3 | Sort-Object Name | ForEach-Object { $folder.ParseName($_) }

# Property indices (some vary by system):
# 0 Name, 14 Album, 15 Year, 16 Genre, 21 Title, 26 Track #, 27 Length, 13 Contributing artists, 237 Album artist
$properties = 0,14,15,16,21,26,27,13,237
$i = 1

# Collect metadata for each file
$allMetadata = foreach ($item in $folderItems) {
    $fileMetadata = @{}
    foreach ($property in $properties) {
        $name = $folder.GetDetailsOf($folderItems, $property)
        $value = $folder.GetDetailsOf($item, $property)
        $fileMetadata[$name] = $value
    }

    # Add/override with album-wide metadata
    $fileMetadata["Album"]        = $album
    $fileMetadata["Album artist"] = $album_artist
    $fileMetadata["Contributing artists"] = $album_artist
    $fileMetadata["Year"]         = $year
    $fileMetadata["Genre"]        = $genre
    $fileMetadata["#"]        = $i
    $i++

	

    [PSCustomObject]$fileMetadata
}

# Export the metadata to CSV
$allMetadata | Export-Csv -Path "TracksMetadataConfig.csv" -NoTypeInformation -Encoding UTF8
