"""
Generate Nova Cabs app icon (1024x1024 PNG)
"""
from PIL import Image, ImageDraw, ImageFilter
import math, os

SIZE = 1024
img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# ── Background: deep indigo gradient circle ──────────────────────────────────
# Simulate gradient by layering circles
for r in range(SIZE // 2, 0, -1):
    t = r / (SIZE // 2)
    ri = int(26 + t * 10)
    gi = int(35 + t * 5)
    bi = int(126 + t * 20)
    x0 = SIZE // 2 - r
    y0 = SIZE // 2 - r
    x1 = SIZE // 2 + r
    y1 = SIZE // 2 + r
    draw.ellipse([x0, y0, x1, y1], fill=(ri, gi, bi, 255))

# ── Rounded square mask ──────────────────────────────────────────────────────
mask = Image.new("L", (SIZE, SIZE), 0)
mask_draw = ImageDraw.Draw(mask)
radius = 220
mask_draw.rounded_rectangle([0, 0, SIZE, SIZE], radius=radius, fill=255)
img.putalpha(mask)

# ── Draw car body (simplified top-view silhouette) ───────────────────────────
draw = ImageDraw.Draw(img)
cx, cy = SIZE // 2, SIZE // 2 + 60

# Car body - main rectangle
car_w, car_h = 380, 200
car_x = cx - car_w // 2
car_y = cy - car_h // 2

# Shadow/glow under car
for i in range(20, 0, -1):
    alpha = int(60 * (1 - i / 20))
    draw.rounded_rectangle(
        [car_x - i, car_y + car_h - 10 + i, car_x + car_w + i, car_y + car_h + 20 + i],
        radius=10, fill=(0, 0, 0, alpha)
    )

# Car body
draw.rounded_rectangle(
    [car_x, car_y, car_x + car_w, car_y + car_h],
    radius=30, fill=(255, 255, 255, 240)
)

# Car roof (trapezoid shape)
roof_pts = [
    (car_x + 80, car_y),
    (car_x + car_w - 80, car_y),
    (car_x + car_w - 120, car_y - 90),
    (car_x + 120, car_y - 90),
]
draw.polygon(roof_pts, fill=(230, 235, 255, 230))

# Windshield
wind_pts = [
    (car_x + 100, car_y - 2),
    (car_x + car_w - 100, car_y - 2),
    (car_x + car_w - 130, car_y - 80),
    (car_x + 130, car_y - 80),
]
draw.polygon(wind_pts, fill=(180, 200, 255, 180))

# Rear window
rear_pts = [
    (car_x + 85, car_y - 2),
    (car_x + 125, car_y - 80),
    (car_x + 135, car_y - 80),
    (car_x + 95, car_y - 2),
]
draw.polygon(rear_pts, fill=(160, 185, 255, 160))

# Windows (side)
draw.rounded_rectangle(
    [car_x + 160, car_y - 75, car_x + 260, car_y - 10],
    radius=6, fill=(160, 185, 255, 180)
)
draw.rounded_rectangle(
    [car_x + 270, car_y - 75, car_x + 340, car_y - 10],
    radius=6, fill=(160, 185, 255, 180)
)

# Wheels (4 circles)
wheel_color = (40, 40, 60, 255)
rim_color = (200, 210, 255, 255)
wheel_r = 42
wheel_positions = [
    (car_x + 85, car_y + car_h - 15),
    (car_x + car_w - 85, car_y + car_h - 15),
    (car_x + 85, car_y + 15),
    (car_x + car_w - 85, car_y + 15),
]
for wx, wy in wheel_positions:
    draw.ellipse([wx - wheel_r, wy - wheel_r, wx + wheel_r, wy + wheel_r], fill=wheel_color)
    draw.ellipse([wx - 22, wy - 22, wx + 22, wy + 22], fill=rim_color)
    draw.ellipse([wx - 8, wy - 8, wx + 8, wy + 8], fill=wheel_color)

# Headlights
draw.rounded_rectangle(
    [car_x + car_w - 20, car_y + 30, car_x + car_w + 5, car_y + 70],
    radius=5, fill=(255, 240, 150, 255)
)
draw.rounded_rectangle(
    [car_x + car_w - 20, car_y + 80, car_x + car_w + 5, car_y + 110],
    radius=5, fill=(255, 200, 100, 255)
)

# Taillights
draw.rounded_rectangle(
    [car_x - 5, car_y + 30, car_x + 20, car_y + 70],
    radius=5, fill=(255, 80, 80, 220)
)

# ── Shooting star / speed streak (amber/gold) ────────────────────────────────
# Main star streak
star_pts = [
    (cx - 60, cy - 200),
    (cx + 200, cy - 140),
    (cx + 190, cy - 120),
    (cx - 70, cy - 178),
]
draw.polygon(star_pts, fill=(255, 193, 7, 220))

# Thinner trailing streak
streak_pts = [
    (cx - 150, cy - 215),
    (cx + 200, cy - 148),
    (cx + 190, cy - 140),
    (cx - 155, cy - 205),
]
draw.polygon(streak_pts, fill=(255, 193, 7, 120))

# Star burst at tip
star_cx, star_cy = cx + 200, cy - 144
for angle in range(0, 360, 45):
    rad = math.radians(angle)
    x1 = star_cx + math.cos(rad) * 22
    y1 = star_cy + math.sin(rad) * 22
    x2 = star_cx + math.cos(rad + math.radians(22.5)) * 10
    y2 = star_cy + math.sin(rad + math.radians(22.5)) * 10
    draw.polygon([(star_cx, star_cy), (x1, y1), (x2, y2)], fill=(255, 230, 100, 240))

# ── Road line at bottom ───────────────────────────────────────────────────────
road_y = cy + car_h // 2 + 50
draw.rounded_rectangle(
    [cx - 200, road_y, cx + 200, road_y + 12],
    radius=6, fill=(255, 255, 255, 60)
)
# Dashes
for i in range(-3, 4):
    dx = i * 60
    draw.rounded_rectangle(
        [cx + dx - 18, road_y + 2, cx + dx + 18, road_y + 10],
        radius=3, fill=(255, 255, 255, 120)
    )

# ── Apply slight blur for polish ─────────────────────────────────────────────
img = img.filter(ImageFilter.SMOOTH)

# ── Save ─────────────────────────────────────────────────────────────────────
os.makedirs("assets/icons", exist_ok=True)
img.save("assets/icons/app_icon.png", "PNG")
print("Icon saved: assets/icons/app_icon.png")

# Also save a foreground version (for adaptive icon) - transparent bg
fg = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
fg_draw = ImageDraw.Draw(fg)
# Just the car + star on transparent
fg.paste(img, (0, 0), img)
fg.save("assets/icons/app_icon_foreground.png", "PNG")
print("Foreground saved: assets/icons/app_icon_foreground.png")
print("Done!")
