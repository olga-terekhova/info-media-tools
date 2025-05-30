# Convert all .ts video files in the current directory to .mp3 audio files using ffmpeg

Get-ChildItem -Filter *.ts | ForEach-Object {
    $inputFile = $_.Name
    $baseName = $_.Basename
    $outputFile = "$baseName.mp3"

    Write-Host "Converting '$inputFile' to '$outputFile'..."
    ffmpeg -i "$inputFile" -vn -acodec libmp3lame -q:a 2 "$outputFile"
}