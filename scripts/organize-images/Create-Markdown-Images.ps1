# Get current directory name
$CurrentDir = Get-Item -Path "." | Select-Object -ExpandProperty Name

# Get all PNG or JPG files in current directory, sorted alphabetically
$ImgFiles = Get-ChildItem | Where-Object { $_.Extension -ieq ".png" -or $_.Extension -ieq ".jpg" }  | Sort-Object Name

# Output file path
$MarkdownFile = "images.md"

# Initialize the markdown content
$Lines = @()
$LinesChildDir = @()
$LinesChildDir += "Markdown code to embed images stored in the child directory (e.g. /images/)  "
$LinesCurrDir = @()
$LinesCurrDir += "Markdown code to embed images stored in the current directory  "

foreach ($File in $ImgFiles) {
    $LineChildDir = "![{0}](./{1}/{2}) {0}" -f $File.BaseName, $CurrentDir, $File.Name
    $LinesChildDir += $LineChildDir
    $LineCurrDir = "![{0}]({2}) {0}" -f $File.BaseName, $CurrentDir, $File.Name
    $LinesCurrDir += $LineCurrDir
}

$Lines = $LinesCurrDir + $LinesChildDir

# Write all lines to the markdown file
$Lines | Set-Content -Path $MarkdownFile -Encoding UTF8

Write-Output "Markdown file '$MarkdownFile' generated with $($PngFiles.Count) images."