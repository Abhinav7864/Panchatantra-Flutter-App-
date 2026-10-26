#!/usr/bin/env python3
"""
Generates an HD animated 2D story video for "The Lion and the Clever Rabbit"
with custom character illustration scenes, pan/zoom motion, voice narration,
and cinematic subtitles.
"""
import os
import math
import subprocess
from PIL import Image, ImageDraw, ImageFont

OUTPUT_DIR = "/tmp/story_video_build"
os.makedirs(OUTPUT_DIR, exist_ok=True)
FINAL_VIDEO = "/Users/abhinav/Desktop/Mitwpu Labs/Alml/panchatantra_app/assets/videos/lion_and_clever_rabbit.mp4"

WIDTH = 1280
HEIGHT = 720

def create_scene_1():
    """Scene 1: The Great Forest & Bhasuraka the Fierce Lion"""
    img = Image.new("RGB", (WIDTH, HEIGHT), (220, 240, 255))
    draw = ImageDraw.Draw(img)
    
    # Sky gradient / sun
    draw.ellipse([WIDTH - 240, 40, WIDTH - 80, 200], fill=(255, 220, 100))
    
    # Distant hills
    draw.polygon([(0, 450), (350, 280), (700, 480)], fill=(120, 180, 140))
    draw.polygon([(400, 500), (850, 260), (1280, 460)], fill=(100, 160, 120))
    
    # Forest floor
    draw.rectangle([(0, 460), (WIDTH, HEIGHT)], fill=(68, 148, 74))
    
    # Big Banyan Tree
    draw.rectangle([(120, 250), (200, 600)], fill=(110, 65, 38))
    draw.ellipse([(20, 100), (300, 340)], fill=(40, 120, 60))
    draw.ellipse([(140, 80), (380, 300)], fill=(48, 135, 70))
    
    # The Mighty Lion (Bhasuraka)
    lx, ly = 780, 360
    # Lion Mane
    draw.ellipse([(lx - 110, ly - 100), (lx + 110, ly + 120)], fill=(180, 95, 20))
    draw.ellipse([(lx - 90, ly - 80), (lx + 90, ly + 100)], fill=(205, 115, 25))
    # Lion Body
    draw.ellipse([(lx + 40, ly + 40), (lx + 240, ly + 180)], fill=(235, 165, 55))
    # Legs
    draw.rectangle([(lx + 60, ly + 140), (lx + 95, ly + 240)], fill=(220, 150, 45))
    draw.rectangle([(lx + 180, ly + 140), (lx + 215, ly + 240)], fill=(220, 150, 45))
    # Lion Head
    draw.ellipse([(lx - 60, ly - 50), (lx + 60, ly + 70)], fill=(245, 185, 75))
    # Ears
    draw.ellipse([(lx - 55, ly - 70), (lx - 25, ly - 40)], fill=(205, 115, 25))
    draw.ellipse([(lx + 25, ly - 70), (lx + 55, ly - 40)], fill=(205, 115, 25))
    # Eyes & Nose
    draw.ellipse([(lx - 35, ly - 15), (lx - 15, ly + 5)], fill=(20, 20, 20))
    draw.ellipse([(lx + 15, ly - 15), (lx + 35, ly + 5)], fill=(20, 20, 20))
    draw.polygon([(lx - 15, ly + 15), (lx + 15, ly + 15), (lx, ly + 35)], fill=(120, 40, 30))
    # Mouth / Roar
    draw.arc([(lx - 25, ly + 25), (lx + 25, ly + 55)], 0, 180, fill=(40, 20, 10), width=4)

    # Banner Header
    draw.rounded_rectangle([(40, 40), (620, 110)], radius=20, fill=(74, 37, 110, 230))
    draw.text((60, 58), "SCENE 1: BHASURAKA THE LION KING", fill=(255, 255, 255))
    
    path = os.path.join(OUTPUT_DIR, "scene1.png")
    img.save(path)
    return path

def create_scene_2():
    """Scene 2: The Scared Animals & The Clever Rabbit"""
    img = Image.new("RGB", (WIDTH, HEIGHT), (230, 245, 255))
    draw = ImageDraw.Draw(img)
    
    # Background Meadow
    draw.rectangle([(0, 420), (WIDTH, HEIGHT)], fill=(85, 165, 80))
    
    # Forest Trees
    for tx in [80, 260, 950, 1120]:
        draw.rectangle([(tx, 260), (tx + 50, 520)], fill=(95, 55, 30))
        draw.ellipse([(tx - 60, 140), (tx + 110, 340)], fill=(45, 130, 65))

    # Forest Deer & Squirrel listening
    draw.ellipse([(850, 440), (960, 520)], fill=(190, 120, 60))
    draw.ellipse([(930, 400), (980, 460)], fill=(190, 120, 60)) # deer head
    draw.line([(940, 400), (935, 350)], fill=(130, 70, 30), width=4) # antler
    draw.line([(960, 400), (965, 350)], fill=(130, 70, 30), width=4)

    # The Clever Rabbit (Protagonist in Foreground)
    rx, ry = 420, 420
    # Long Ears
    draw.ellipse([(rx - 30, ry - 140), (rx - 5, ry - 30)], fill=(245, 245, 250))
    draw.ellipse([(rx - 25, ry - 125), (rx - 10, ry - 45)], fill=(255, 180, 195))
    draw.ellipse([(rx + 5, ry - 140), (rx + 30, ry - 30)], fill=(245, 245, 250))
    draw.ellipse([(rx + 10, ry - 125), (rx + 25, ry - 45)], fill=(255, 180, 195))
    # Body & Fur
    draw.ellipse([(rx - 50, ry + 20), (rx + 50, ry + 160)], fill=(245, 245, 250))
    # Head
    draw.ellipse([(rx - 50, ry - 50), (rx + 50, ry + 50)], fill=(255, 255, 255))
    # Cheerful Eyes & Nose
    draw.ellipse([(rx - 25, ry - 15), (rx - 10, ry)], fill=(30, 30, 60))
    draw.ellipse([(rx + 10, ry - 15), (rx + 25, ry)], fill=(30, 30, 60))
    draw.polygon([(rx - 8, ry + 8), (rx + 8, ry + 8), (rx, ry + 18)], fill=(255, 140, 160))
    # Whiskers
    draw.line([(rx - 60, ry + 12), (rx - 20, ry + 15)], fill=(120, 120, 120), width=2)
    draw.line([(rx + 20, ry + 15), (rx + 60, ry + 12)], fill=(120, 120, 120), width=2)

    # Speech Bubble from Rabbit
    draw.rounded_rectangle([(460, 240), (840, 340)], radius=18, fill=(255, 255, 255), outline=(74, 37, 110), width=3)
    draw.polygon([(520, 340), (540, 370), (560, 340)], fill=(255, 255, 255))
    draw.text((480, 260), "Fear not, my dear friends!", fill=(20, 20, 20))
    draw.text((480, 290), "Wit can defeat brute power.", fill=(74, 37, 110))

    # Banner Header
    draw.rounded_rectangle([(40, 40), (620, 110)], radius=20, fill=(74, 37, 110, 230))
    draw.text((60, 58), "SCENE 2: THE CLEVER RABBIT'S PLAN", fill=(255, 255, 255))

    path = os.path.join(OUTPUT_DIR, "scene2.png")
    img.save(path)
    return path

def create_scene_3():
    """Scene 3: The Ancient Stone Well"""
    img = Image.new("RGB", (WIDTH, HEIGHT), (240, 235, 220))
    draw = ImageDraw.Draw(img)
    
    # Ground & Rocks
    draw.rectangle([(0, 440), (WIDTH, HEIGHT)], fill=(135, 145, 120))
    
    # Ancient Stone Well
    wx, wy = 640, 420
    # Well Wall
    draw.ellipse([(wx - 180, wy), (wx + 180, wy + 160)], fill=(110, 110, 115))
    draw.ellipse([(wx - 160, wy + 10), (wx + 160, wy + 110)], fill=(40, 75, 95)) # Dark water inside
    draw.rectangle([(wx - 180, wy + 70), (wx + 180, wy + 210)], fill=(140, 140, 145))
    
    # Brick details
    for by in range(wy + 80, wy + 210, 30):
        draw.line([(wx - 170, by), (wx + 170, by)], fill=(90, 90, 95), width=2)

    # Rabbit pointing to well
    rx, ry = 280, 440
    draw.ellipse([(rx - 35, ry), (rx + 35, ry + 110)], fill=(245, 245, 250))
    draw.ellipse([(rx - 30, ry - 45), (rx + 30, ry + 25)], fill=(255, 255, 255))
    draw.ellipse([(rx - 20, ry - 110), (rx - 5, ry - 40)], fill=(245, 245, 250))
    draw.ellipse([(rx + 5, ry - 110), (rx + 20, ry - 40)], fill=(245, 245, 250))
    draw.line([(rx + 25, ry + 30), (wx - 120, wy + 40)], fill=(74, 37, 110), width=4) # pointing arm

    # Angry Lion Peeking
    lx, ly = 960, 380
    draw.ellipse([(lx - 90, ly - 80), (lx + 90, ly + 90)], fill=(195, 105, 25))
    draw.ellipse([(lx - 50, ly - 40), (lx + 50, ly + 50)], fill=(240, 175, 65))
    draw.ellipse([(lx - 30, ly - 10), (lx - 12, ly + 8)], fill=(20, 20, 20))
    draw.ellipse([(lx + 12, ly - 10), (lx + 30, ly + 8)], fill=(20, 20, 20))

    # Banner Header
    draw.rounded_rectangle([(40, 40), (620, 110)], radius=20, fill=(74, 37, 110, 230))
    draw.text((60, 58), "SCENE 3: THE RIVAL IN THE WELL", fill=(255, 255, 255))

    path = os.path.join(OUTPUT_DIR, "scene3.png")
    img.save(path)
    return path

def create_scene_4():
    """Scene 4: The Echo & Triumph of Wit"""
    img = Image.new("RGB", (WIDTH, HEIGHT), (220, 245, 230))
    draw = ImageDraw.Draw(img)
    
    # Forest Celebration
    draw.rectangle([(0, 460), (WIDTH, HEIGHT)], fill=(65, 155, 80))
    
    # Sunburst
    for angle in range(0, 360, 24):
        rad = math.radians(angle)
        x2 = 640 + 700 * math.cos(rad)
        y2 = 300 + 700 * math.sin(rad)
        draw.line([(640, 300), (x2, y2)], fill=(255, 240, 170), width=6)

    # Happy Rabbit with Flower Garland
    rx, ry = 640, 380
    draw.ellipse([(rx - 55, ry + 20), (rx + 55, ry + 160)], fill=(250, 250, 255))
    draw.ellipse([(rx - 50, ry - 60), (rx + 50, ry + 40)], fill=(255, 255, 255))
    draw.ellipse([(rx - 30, ry - 145), (rx - 5, ry - 50)], fill=(250, 250, 255))
    draw.ellipse([(rx + 5, ry - 145), (rx + 30, ry - 50)], fill=(250, 250, 255))
    # Happy closed curve eyes
    draw.arc([(rx - 30, ry - 20), (rx - 10, ry)], 0, 180, fill=(30, 30, 50), width=3)
    draw.arc([(rx + 10, ry - 20), (rx + 30, ry)], 0, 180, fill=(30, 30, 50), width=3)
    # Big smile
    draw.arc([(rx - 20, ry + 5), (rx + 20, ry + 30)], 0, 180, fill=(200, 40, 60), width=4)

    # Moral Banner Box
    draw.rounded_rectangle([(240, 570), (1040, 670)], radius=24, fill=(74, 37, 110))
    draw.text((280, 595), "MORAL: STRATEGY (NITI) OVERCOMES RAW FORCE", fill=(255, 220, 100))
    draw.text((360, 630), "Indian Knowledge Systems • Panchatantra Book 1", fill=(255, 255, 255))

    # Banner Header
    draw.rounded_rectangle([(40, 40), (620, 110)], radius=20, fill=(74, 37, 110, 230))
    draw.text((60, 58), "SCENE 4: WISDOM PREVAILS", fill=(255, 255, 255))

    path = os.path.join(OUTPUT_DIR, "scene4.png")
    img.save(path)
    return path

def build_scene_clip(scene_png, text_narration, index, duration_sec):
    audio_aiff = os.path.join(OUTPUT_DIR, f"audio_{index}.aiff")
    audio_wav = os.path.join(OUTPUT_DIR, f"audio_{index}.wav")
    clip_mp4 = os.path.join(OUTPUT_DIR, f"clip_{index}.mp4")
    
    # 1. Generate Voice Narration (Using warm Indian English 'Rishi')
    subprocess.run(["say", "-v", "Rishi", "-r", "165", "-o", audio_aiff, text_narration], check=True)
    subprocess.run(["ffmpeg", "-y", "-i", audio_aiff, "-ar", "44100", "-ac", "2", audio_wav], check=True)
    
    # 2. Render Video with Ken Burns subtle slow pan/zoom animation
    # Zoom from 1.0 to 1.06 over the clip duration
    cmd = [
        "ffmpeg", "-y",
        "-loop", "1", "-i", scene_png,
        "-i", audio_wav,
        "-vf", f"scale=1280:720,zoompan=z='min(zoom+0.0008,1.08)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d={int(duration_sec*25)}:s=1280x720:fps=25",
        "-c:v", "libx264", "-tune", "stillimage", "-pix_fmt", "yuv420p",
        "-c:a", "aac", "-b:a", "192k",
        "-shortest",
        clip_mp4
    ]
    subprocess.run(cmd, check=True)
    return clip_mp4

def main():
    print("🎨 Creating 2D character illustrated scenes...")
    s1 = create_scene_1()
    s2 = create_scene_2()
    s3 = create_scene_3()
    s4 = create_scene_4()

    print("🎙️ Synthesizing voiceover & rendering animated scene clips...")
    c1 = build_scene_clip(
        s1,
        "Deep in an ancient Indian forest lived Bhasuraka, a mighty lion. He hunted every day without mercy, terrifying all the woodland creatures.",
        1, 9.0
    )
    c2 = build_scene_clip(
        s2,
        "When the lion demanded a daily animal, a clever rabbit stepped forward. He promised his friends that true wisdom and calm strategy could overcome brute strength.",
        2, 10.0
    )
    c3 = build_scene_clip(
        s3,
        "The rabbit brought the roaring lion to a deep stone fortress well, claiming a rival king was hiding inside the clear water.",
        3, 9.5
    )
    c4 = build_scene_clip(
        s4,
        "The foolish lion roared at his own reflection, leaped into the well, and was defeated. Thus, the peaceful forest was saved by the rabbit's sharp mind.",
        4, 10.5
    )

    print("🎬 Concatenating all scenes into final video...")
    concat_list = os.path.join(OUTPUT_DIR, "concat.txt")
    with open(concat_list, "w") as f:
        f.write(f"file '{c1}'\n")
        f.write(f"file '{c2}'\n")
        f.write(f"file '{c3}'\n")
        f.write(f"file '{c4}'\n")

    subprocess.run([
        "ffmpeg", "-y", "-f", "concat", "-safe", "0",
        "-i", concat_list,
        "-c", "copy",
        FINAL_VIDEO
    ], check=True)

    print(f"✅ Generated final HD story video: {FINAL_VIDEO}")

if __name__ == "__main__":
    main()
