$ErrorActionPreference = 'Stop'

$deliverables = Split-Path -Parent $PSScriptRoot
$assets = Join-Path $deliverables 'images'
$output = Join-Path $PSScriptRoot 'seikou_design-b_mv-concept.mp4'

$hero = Join-Path $assets 'hero-design-b-night.jpg'
$yard = Join-Path $assets 'seikou-trucks-yard.jpg'
$warehouse = Join-Path $assets 'seikou-warehouse-work.jpg'
$maintenance = Join-Path $assets 'seikou-under-maintenance.jpg'
$chrome = Join-Path $PSScriptRoot 'overlay_chrome.png'
$copy = Join-Path $PSScriptRoot 'overlay_copy.png'

Push-Location $PSScriptRoot

$filter = @'
[0:v]fps=30,scale=2304:1286,crop=1920:1080:x='(iw-ow)*t/4':y='(ih-oh)/2',setsar=1,eq=brightness=-0.07:contrast=1.12:saturation=0.88,trim=duration=4,setpts=PTS-STARTPTS[v0];
[1:v]fps=30,scale=2304:-2,crop=1920:1080:x='(iw-ow)*0.48':y='(ih-oh)*(0.12+0.32*t/2.4)',setsar=1,eq=brightness=-0.20:contrast=1.16:saturation=0.78,trim=duration=2.4,setpts=PTS-STARTPTS[v1];
[2:v]fps=30,scale=2160:-2,crop=1920:1080:x='(iw-ow)*(0.15+0.55*t/2.4)':y='(ih-oh)*0.33',setsar=1,eq=brightness=-0.22:contrast=1.15:saturation=0.76,trim=duration=2.4,setpts=PTS-STARTPTS[v2];
[3:v]fps=30,scale=-2:1200,crop=1920:1080:x='(iw-ow)*(0.88-0.55*t/2.4)':y=60,setsar=1,eq=brightness=-0.20:contrast=1.16:saturation=0.74,trim=duration=2.4,setpts=PTS-STARTPTS[v3];
[4:v]fps=30,scale=2304:1286,crop=1920:1080:x='(iw-ow)*(1-t/3.4)':y='(ih-oh)/2',setsar=1,eq=brightness=-0.07:contrast=1.12:saturation=0.88,trim=duration=3.4,setpts=PTS-STARTPTS[v4];
[v0][v1]xfade=transition=fade:duration=0.65:offset=3.35[x1];
[x1][v2]xfade=transition=fade:duration=0.65:offset=5.10[x2];
[x2][v3]xfade=transition=fade:duration=0.65:offset=6.85[x3];
[x3][v4]xfade=transition=fade:duration=0.65:offset=8.60[x4];
[x4]drawbox=x=0:y=0:w=iw:h=ih:color=black@0.28:t=fill,
drawbox=x=0:y=0:w=iw:h=150:color=black@0.18:t=fill,
drawbox=x=0:y=600:w=iw:h=480:color=black@0.18:t=fill,
format=yuv420p[base];
[5:v]format=rgba,fade=t=in:st=0.20:d=0.55:alpha=1,fade=t=out:st=11.55:d=0.45:alpha=1[chrome];
[6:v]format=rgba,fade=t=in:st=0.55:d=0.85:alpha=1,fade=t=out:st=11.55:d=0.45:alpha=1[copy];
[base][chrome]overlay=x=0:y=0:format=auto[ui0];
[ui0][copy]overlay=x=0:y=0:format=auto,fade=t=in:st=0:d=0.45,fade=t=out:st=11.55:d=0.45,format=yuv420p[outv]
'@

$arguments = @(
    '-y',
    '-loop', '1', '-t', '4.0', '-i', $hero,
    '-loop', '1', '-t', '2.4', '-i', $yard,
    '-loop', '1', '-t', '2.4', '-i', $warehouse,
    '-loop', '1', '-t', '2.4', '-i', $maintenance,
    '-loop', '1', '-t', '3.4', '-i', $hero,
    '-loop', '1', '-t', '12.0', '-i', $chrome,
    '-loop', '1', '-t', '12.0', '-i', $copy,
    '-filter_complex', $filter,
    '-map', '[outv]',
    '-an',
    '-r', '30',
    '-t', '12',
    '-c:v', 'libx264',
    '-preset', 'medium',
    '-crf', '18',
    '-movflags', '+faststart',
    $output
)

& ffmpeg @arguments
if ($LASTEXITCODE -ne 0) {
    throw "ffmpeg failed with exit code $LASTEXITCODE"
}

Write-Output $output

Pop-Location
