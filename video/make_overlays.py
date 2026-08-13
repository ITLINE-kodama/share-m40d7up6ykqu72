from pathlib import Path
from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parent
ASSETS = ROOT.parent / "images"
W, H = 1920, 1080

FONT_ARIAL = r"C:\Windows\Fonts\arial.ttf"
FONT_ARIAL_BOLD = r"C:\Windows\Fonts\arialbd.ttf"
FONT_BAHN = r"C:\Windows\Fonts\bahnschrift.ttf"
FONT_JP = r"C:\Windows\Fonts\NotoSansJP-VF.ttf"


def font(path: str, size: int):
    return ImageFont.truetype(path, size=size)


def draw_text(draw, xy, text, face, fill, anchor=None):
    draw.text(xy, text, font=face, fill=fill, anchor=anchor)


def white_logo(width=255):
    logo = Image.open(ASSETS / "logo-seikou.png").convert("RGBA")
    height = round(logo.height * width / logo.width)
    logo = logo.resize((width, height), Image.Resampling.LANCZOS)
    alpha = logo.getchannel("A")
    result = Image.new("RGBA", logo.size, (255, 255, 255, 0))
    result.putalpha(alpha)
    return result


def make_chrome():
    image = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)

    # Fine border used by design B.
    draw.rectangle((32, 32, W - 32, H - 32), outline=(255, 255, 255, 72), width=1)

    logo = white_logo()
    image.alpha_composite(logo, (64, 34))

    draw_text(draw, (338, 60), "Corporate Site", font(FONT_ARIAL, 17), (152, 163, 179, 255), "lm")
    draw_text(
        draw,
        (505, 60),
        "私たちについて　　強み・安全　　事業　　採用",
        font(FONT_JP, 18),
        (255, 255, 255, 255),
        "lm",
    )

    # Contact button and menu.
    draw.rectangle((1465, 32, 1735, 102), fill=(62, 123, 232, 246))
    draw_text(draw, (1502, 67), "お問い合わせ", font(FONT_JP, 19), (255, 255, 255, 255), "lm")
    draw.line((1665, 67, 1699, 67), fill=(255, 255, 255, 235), width=1)
    draw_text(draw, (1707, 66), ">", font(FONT_ARIAL_BOLD, 21), (255, 255, 255, 255), "mm")
    draw.line((1792, 49, 1827, 49), fill=(255, 255, 255, 240), width=2)
    draw.line((1804, 60, 1827, 60), fill=(255, 255, 255, 240), width=2)
    draw_text(draw, (1808, 80), "MENU", font(FONT_ARIAL_BOLD, 13), (255, 255, 255, 255), "mm")

    # Mid-screen metadata tags.
    tag_font = font(FONT_ARIAL_BOLD, 17)
    tags = [
        (80, "SINCE 1964", (62, 123, 232, 255), "la"),
        (W // 2, "SAFETY BY AI", (199, 227, 107, 255), "ma"),
        (W - 80, "OKAYAMA - KANTO", (255, 255, 255, 255), "ra"),
    ]
    for x, label, color, anchor in tags:
        if anchor == "la":
            draw.ellipse((x, 516, x + 5, 521), fill=color)
            draw_text(draw, (x + 14, 515), label, tag_font, color)
        elif anchor == "ma":
            box = draw.textbbox((0, 0), label, font=tag_font)
            width = box[2] - box[0]
            start = x - width // 2
            draw.ellipse((start - 14, 516, start - 9, 521), fill=color)
            draw_text(draw, (x, 515), label, tag_font, color, "ma")
        else:
            box = draw.textbbox((0, 0), label, font=tag_font)
            width = box[2] - box[0]
            start = x - width
            draw.ellipse((start - 14, 516, start - 9, 521), fill=color)
            draw_text(draw, (x, 515), label, tag_font, color, "ra")

    # Scroll indicator.
    scroll = Image.new("RGBA", (200, 22), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(scroll)
    draw_text(sdraw, (0, 11), "S  C  R  O  L  L", font(FONT_ARIAL_BOLD, 12), (255, 255, 255, 220), "lm")
    scroll = scroll.rotate(90, expand=True, resample=Image.Resampling.BICUBIC)
    image.alpha_composite(scroll, (1816, 835))
    draw.line((1848, 934, 1848, 1006), fill=(255, 255, 255, 78), width=1)
    draw.line((1848, 934, 1848, 961), fill=(62, 123, 232, 245), width=2)

    image.save(ROOT / "overlay_chrome.png")


def make_copy():
    image = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)

    title = font(FONT_BAHN, 145)
    draw_text(draw, (82, 670), "ROAD TO", title, (255, 255, 255, 255))
    draw_text(draw, (82, 810), "TRUST", title, (62, 123, 232, 255))

    jp = font(FONT_JP, 25)
    draw_text(draw, (86, 1007), "走り続ける、", jp, (255, 255, 255, 255), "lm")
    draw.line((270, 1007, 415, 1007), fill=(255, 255, 255, 115), width=1)
    draw_text(draw, (445, 1007), "信頼のために。", jp, (255, 255, 255, 255), "lm")

    image.save(ROOT / "overlay_copy.png")


if __name__ == "__main__":
    make_chrome()
    make_copy()
    print(ROOT / "overlay_chrome.png")
    print(ROOT / "overlay_copy.png")
