from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parent
W, H = 1600, 900


def radial_glow(size, center, radii, colors):
    layer = Image.new("RGBA", size, (0, 0, 0, 0))
    for radius, color in zip(radii, colors):
        spot = Image.new("RGBA", size, (0, 0, 0, 0))
        draw = ImageDraw.Draw(spot)
        x, y = center
        draw.ellipse((x - radius, y - radius, x + radius, y + radius), fill=color)
        blur = max(2, radius // 2)
        spot = spot.filter(ImageFilter.GaussianBlur(blur))
        layer = Image.alpha_composite(layer, spot)
    return layer


canvas = Image.new("RGBA", (W, H), (0, 0, 0, 0))

# Coordinates match the lamp faces in the generated 1600 x 900 opening image.
for center in ((865, 671), (1324, 671)):
    bloom = radial_glow(
        (W, H),
        center,
        (125, 68, 27, 10),
        (
            (70, 185, 255, 52),
            (135, 220, 255, 105),
            (220, 245, 255, 205),
            (255, 255, 255, 245),
        ),
    )
    canvas = Image.alpha_composite(canvas, bloom)

# Crisp LED streaks keep the lamps visibly illuminated after video compression.
leds = Image.new("RGBA", (W, H), (0, 0, 0, 0))
draw = ImageDraw.Draw(leds)
for x, y in ((865, 671), (1324, 671)):
    draw.rounded_rectangle((x - 27, y - 5, x + 27, y + 5), radius=5, fill=(235, 250, 255, 235))
    draw.rounded_rectangle((x - 5, y - 34, x + 5, y + 34), radius=5, fill=(170, 230, 255, 135))
leds = leds.filter(ImageFilter.GaussianBlur(2.2))
canvas = Image.alpha_composite(canvas, leds)

# Restrained reflected beams on wet asphalt.
beam = Image.new("RGBA", (W, H), (0, 0, 0, 0))
draw = ImageDraw.Draw(beam)
draw.polygon(((865, 684), (700, 900), (965, 900), (895, 684)), fill=(90, 205, 255, 54))
draw.polygon(((1324, 684), (1190, 900), (1515, 900), (1354, 684)), fill=(90, 205, 255, 54))
beam = beam.filter(ImageFilter.GaussianBlur(30))
canvas = Image.alpha_composite(canvas, beam)

canvas.save(ROOT / "headlight-glow-v3.png")
print(ROOT / "headlight-glow-v3.png")
