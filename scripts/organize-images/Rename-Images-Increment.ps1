# Get all PNG files in the current directory, sorted by name
$pngFiles = Get-ChildItem -Path . -Filter *.png | Sort-Object Name

# Determine zero-padding width
$fileCount = $pngFiles.Count
$padWidth = if ($fileCount -gt 9) { 2 } else { 1 }

# Rename with padded numbers
for ($i = 0; $i -lt $pngFiles.Count; $i++) {
    $newName = "{0:D$padWidth}.png" -f ($i + 1)
    Rename-Item -Path $pngFiles[$i].FullName -NewName $newName
}