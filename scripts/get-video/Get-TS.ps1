param (
    [Parameter(Mandatory = $true)]
    [string]$Url,

    [Parameter(Mandatory = $true)]
    [string]$ResultFile
)

# Get parent directory of the playlist file
$basePath = $Url -replace '/[^/]*$', '/'

# Create secure temporary directory
$tmpdir = New-Item -ItemType Directory -Path ([System.IO.Path]::GetTempPath()) -Name ([System.IO.Path]::GetRandomFileName())

try {
    # Download the main playlist
    $mainPlaylist = Join-Path $tmpdir "main.m3u8"
    Invoke-WebRequest -Uri $Url -OutFile $mainPlaylist -UseBasicParsing

    # Count number of segments
    $lines = Get-Content $mainPlaylist
    $segmentUrls = $lines | Where-Object { $_ -match '\.ts' }
    $num = $segmentUrls.Count
    Write-Host "Total segments to download: $num"

    $startTime = Get-Date
    $count = 0

    foreach ($line in $segmentUrls) {
        $padded = "{0:D5}" -f $count
        $segmentPath = Join-Path $tmpdir "$padded.ts"

	if ($line -match '^https?:\/\/.*\.ts') {
	    $line_url = $line
	} else {
	    $line_url = $basePath.TrimEnd('/') + '/' + $line
	}

	Invoke-WebRequest -Uri $line_url -OutFile $segmentPath -UseBasicParsing

	$count++

	$percent = [math]::Round($count * 100 / $num)
        Write-Host "Downloaded: $count / $num ($percent%)"

        $elapsed = (Get-Date) - $startTime
        $elapsedStr = "{0:D2}h:{1:D2}m:{2:D2}s" -f $elapsed.Hours, $elapsed.Minutes, $elapsed.Seconds
        Write-Host "Elapsed: $elapsedStr"

        if ($count -gt 0) {
            $forecastSec = ($elapsed.TotalSeconds / $count) * ($num - $count)
            $forecast = [TimeSpan]::FromSeconds($forecastSec)
            $forecastStr = "{0:D2}h:{1:D2}m:{2:D2}s" -f $forecast.Hours, $forecast.Minutes, $forecast.Seconds
            Write-Host "Estimated time remaining: $forecastStr"
        }

        Write-Host ""

      }

	$tsFiles = Get-ChildItem -Path $tmpdir -Filter "*.ts" | Sort-Object Name

	# Open the destination file in append mode
	$stream = [System.IO.File]::Open($ResultFile, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)

	try {
	    foreach ($file in $tsFiles) {
       		 $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
        	$stream.Write($bytes, 0, $bytes.Length)
    		}
	}

	finally {
    		$stream.Close()
	}

    Write-Host "Download complete. Output saved to: $ResultFile"

    
}
finally {
    # Clean up
    Remove-Item -Recurse -Force $tmpdir

}
