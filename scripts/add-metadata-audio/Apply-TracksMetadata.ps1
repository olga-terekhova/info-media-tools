# Check if ffmpeg is available
if (-not (Get-Command "ffmpeg" -ErrorAction SilentlyContinue)) {
    Write-Error "ffmpeg is not found in PATH. Please install it or add it to the system PATH."
    exit 1
}

# Define paths
$configFile = Join-Path -Path (Get-Location) -ChildPath "TracksMetadataConfig.csv"
$coverFile = Join-Path -Path (Get-Location) -ChildPath "cover.jpg"

if (-not (Test-Path $configFile)) {
    Write-Error "TracksMetadataConfig.csv not found."
    exit 1
}
if (-not (Test-Path $coverFile)) {
    Write-Error "cover.jpg not found. It is required to embed album art."
    exit 1
}


# Read metadata
$trackMetadataList = Import-Csv -Path $configFile
$mp3Files = Get-ChildItem -Filter *.mp3 | Sort-Object Name


if ($trackMetadataList.Count -eq 0 -or $mp3Files.Count -lt $trackMetadataList.Count) {
    Write-Error "Mismatch: fewer MP3s than metadata rows or no data."
    exit 1
}


# Map CSV headers to ffmpeg metadata keys
$ffmpegMap = @{
    "Title"                = "title"
    "Year"                 = "date"
    "Album"                = "album"
    "Contributing artists"= "artist"
    "Album artist"         = "album_artist"
    "Genre"                = "genre"
    "#"                    = "track"
}

# Process each MP3 file
for ($i = 0; $i -lt $trackMetadataList.Count; $i++) {
    $file = $mp3Files[$i]
    $metadata = $trackMetadataList[$i]

    Write-Host "`nProcessing [$($i + 1)]: $($file.Name)"

    # Prepare ffmpeg metadata args
    $metaArgs = @()
    foreach ($key in $metadata.PSObject.Properties.Name) {
        if ($ffmpegMap.ContainsKey($key) -and $ffmpegMap[$key]) {
            $value = $metadata.$key
            if ($value) {
		$ffmpegKey = $ffmpegMap[$key]
                $metaArgs += "-metadata"
                $metaArgs += "$ffmpegKey=$value"
            }
        }
    }

    # Define temporary output
    $tempOutput = [IO.Path]::ChangeExtension($file.FullName, ".temp.mp3")

    # Build and execute ffmpeg command
    $ffmpegArgs = @(
        "-y",                         # overwrite
        "-i", "`"$($file.FullName)`"",
        "-i", "`"$coverFile`"",
        "-map", "0", "-map", "1",
	"-c:a", "copy",
        "-id3v2_version", "3",
        "-metadata:s:v", "title=Album cover",
        "-metadata:s:v", "comment=Cover (front)"
    ) + $metaArgs + "`"$outputFile`""

    & ffmpeg @ffmpegArgs | Out-Null

    # Replace original file with updated one
    Move-Item -Force -Path "$tempOutput" -Destination "$($file.FullName)"
}

Write-Host "`nAll metadata applied successfully via ffmpeg."
