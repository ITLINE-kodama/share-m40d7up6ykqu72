$ErrorActionPreference = 'Stop'

$deliverables = Split-Path -Parent $PSScriptRoot
$assets = Join-Path $deliverables 'images'
$output = Join-Path $PSScriptRoot 'design-b-mv-background-v3.mp4'
$mobileOutput = Join-Path $PSScriptRoot 'design-b-mv-background-mobile-v3.mp4'
$posterOutput = Join-Path $assets 'design-b-start-v3.jpg'

$front = Join-Path $assets 'seikou-front-future-v2.png'
$future = Join-Path $assets 'seikou-future-logistics-v1.png'
$yard = Join-Path $assets 'seikou-trucks-yard.jpg'
$warehouse = Join-Path $assets 'seikou-warehouse-work.jpg'
$maintenance = Join-Path $assets 'seikou-under-maintenance.jpg'
$headlightGlow = Join-Path $PSScriptRoot 'headlight-glow-v3.png'

$filter = @'
[0:v]fps=30,scale=1600:900:flags=lanczos,setsar=1,eq=brightness=0.00:contrast=1.04:saturation=0.98,trim=duration=3.8,setpts=PTS-STARTPTS[v0];
[1:v]fps=30,scale=1800:-2,crop=1600:900:x='(iw-ow)*(0.18+0.64*t/2.8)':y='(ih-oh)*0.50',setsar=1,eq=brightness=0.00:contrast=1.05:saturation=0.95,trim=duration=2.8,setpts=PTS-STARTPTS[v1];
[2:v]fps=30,scale=1920:-2,crop=1600:900:x='(iw-ow)*0.50':y='(ih-oh)*(0.10+0.34*t/2.6)',setsar=1,eq=brightness=-0.01:contrast=1.07:saturation=0.94,trim=duration=2.6,setpts=PTS-STARTPTS[v2];
[3:v]fps=30,scale=1800:-2,crop=1600:900:x='(iw-ow)*(0.15+0.55*t/2.6)':y='(ih-oh)*0.33',setsar=1,eq=brightness=-0.01:contrast=1.07:saturation=0.94,trim=duration=2.6,setpts=PTS-STARTPTS[v3];
[4:v]fps=30,scale=-2:1000,crop=1600:900:x='(iw-ow)*(0.88-0.55*t/2.6)':y=50,setsar=1,eq=brightness=-0.01:contrast=1.07:saturation=0.92,trim=duration=2.6,setpts=PTS-STARTPTS[v4];
[5:v]fps=30,scale=1600:900:flags=lanczos,setsar=1,eq=brightness=0.00:contrast=1.04:saturation=0.98,trim=duration=3.0,setpts=PTS-STARTPTS[v5];
[6:v]fps=30,scale=1600:900,format=rgba,trim=duration=3.8,setpts=PTS-STARTPTS,fade=t=in:st=0.15:d=0.40:alpha=1,fade=t=out:st=1.20:d=0.85:alpha=1[glow];
[v0][glow]overlay=x=0:y=0:format=auto[v0light];
[v0light][v1]xfade=transition=fade:duration=0.7:offset=3.1[x1];
[x1][v2]xfade=transition=fade:duration=0.7:offset=5.2[x2];
[x2][v3]xfade=transition=fade:duration=0.7:offset=7.1[x3];
[x3][v4]xfade=transition=fade:duration=0.7:offset=9.0[x4];
[x4][v5]xfade=transition=fade:duration=0.7:offset=10.9,format=yuv420p[outv]
'@

$arguments = @(
    '-y',
    '-loop', '1', '-t', '3.8', '-i', $front,
    '-loop', '1', '-t', '2.8', '-i', $future,
    '-loop', '1', '-t', '2.6', '-i', $yard,
    '-loop', '1', '-t', '2.6', '-i', $warehouse,
    '-loop', '1', '-t', '2.6', '-i', $maintenance,
    '-loop', '1', '-t', '3.0', '-i', $front,
    '-loop', '1', '-t', '3.8', '-i', $headlightGlow,
    '-filter_complex', $filter,
    '-map', '[outv]',
    '-an',
    '-r', '30',
    '-t', '13.9',
    '-c:v', 'libx264',
    '-profile:v', 'high',
    '-level', '4.0',
    '-preset', 'medium',
    '-crf', '21',
    '-g', '60',
    '-keyint_min', '60',
    '-sc_threshold', '0',
    '-movflags', '+faststart',
    $output
)

& ffmpeg @arguments
if ($LASTEXITCODE -ne 0) {
    throw "ffmpeg failed with exit code $LASTEXITCODE"
}

& ffmpeg -y -i $output -vf 'scale=960:540' -an -c:v libx264 -profile:v high -level 3.1 -preset medium -crf 22 -g 60 -keyint_min 60 -sc_threshold 0 -movflags +faststart $mobileOutput
if ($LASTEXITCODE -ne 0) {
    throw "mobile ffmpeg failed with exit code $LASTEXITCODE"
}

& ffmpeg -y -ss 0 -i $output -frames:v 1 -q:v 2 -update 1 $posterOutput
if ($LASTEXITCODE -ne 0) {
    throw "poster ffmpeg failed with exit code $LASTEXITCODE"
}

Write-Output $output
Write-Output $mobileOutput
Write-Output $posterOutput
