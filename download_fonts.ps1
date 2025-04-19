$fonts = @(
    @{
        name = "NotoSans-Regular"
        url = "https://fonts.google.com/download?family=Noto%20Sans"
    },
    @{
        name = "NotoSans-Bold"
        url = "https://fonts.google.com/download?family=Noto%20Sans"
    },
    @{
        name = "NotoSans-Italic"
        url = "https://fonts.google.com/download?family=Noto%20Sans"
    },
    @{
        name = "NotoSans-BoldItalic"
        url = "https://fonts.google.com/download?family=Noto%20Sans"
    }
)

foreach ($font in $fonts) {
    $outputPath = "assets/fonts/$($font.name).ttf"
    Invoke-WebRequest -Uri $font.url -OutFile $outputPath
    Write-Host "Downloaded $($font.name) to $outputPath"
}
