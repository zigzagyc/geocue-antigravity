import os
from PIL import Image

# Configuration
MASTER_ICON_PATH = 'docs/app_icon_master.png'
ANDROID_RES_DIR = 'android/app/src/main/res'
IOS_ICONSET_DIR = 'ios/Runner/Assets.xcassets/AppIcon.appiconset'

def generate_android_icons(img):
    print("Generating Android icons...")
    # Map folder name to size (px)
    android_sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192
    }

    for folder, size in android_sizes.items():
        target_dir = os.path.join(ANDROID_RES_DIR, folder)
        if not os.path.exists(target_dir):
            os.makedirs(target_dir)
        
        resized_img = img.resize((size, size), Image.Resampling.LANCZOS)
        target_path = os.path.join(target_dir, 'ic_launcher.png')
        resized_img.save(target_path)
        print(f"Saved {target_path} ({size}x{size})")

def generate_ios_icons(img):
    print("Generating iOS icons...")
    # Based on Contents.json
    # (size, scale, filename)
    ios_specs = [
        (20, 2, "Icon-App-20x20@2x.png"),
        (20, 3, "Icon-App-20x20@3x.png"),
        (29, 1, "Icon-App-29x29@1x.png"),
        (29, 2, "Icon-App-29x29@2x.png"),
        (29, 3, "Icon-App-29x29@3x.png"),
        (40, 2, "Icon-App-40x40@2x.png"),
        (40, 3, "Icon-App-40x40@3x.png"),
        (60, 2, "Icon-App-60x60@2x.png"),
        (60, 3, "Icon-App-60x60@3x.png"),
        (20, 1, "Icon-App-20x20@1x.png"), # iPad
        (20, 2, "Icon-App-20x20@2x.png"), # iPad (Duplicate filename, will be overwritten which is fine as size/scale match)
        (29, 1, "Icon-App-29x29@1x.png"), # iPad
        (29, 2, "Icon-App-29x29@2x.png"), # iPad
        (40, 1, "Icon-App-40x40@1x.png"), # iPad
        (40, 2, "Icon-App-40x40@2x.png"), # iPad
        (76, 1, "Icon-App-76x76@1x.png"),
        (76, 2, "Icon-App-76x76@2x.png"),
        (83.5, 2, "Icon-App-83.5x83.5@2x.png"),
        (1024, 1, "Icon-App-1024x1024@1x.png")
    ]

    for size_pt, scale, filename in ios_specs:
        size_px = int(size_pt * scale)
        target_path = os.path.join(IOS_ICONSET_DIR, filename)
        
        resized_img = img.resize((size_px, size_px), Image.Resampling.LANCZOS)
        resized_img.save(target_path)
        print(f"Saved {target_path} ({size_px}x{size_px})")

def main():
    if not os.path.exists(MASTER_ICON_PATH):
        print(f"Error: Master icon not found at {MASTER_ICON_PATH}")
        return

    try:
        img = Image.open(MASTER_ICON_PATH)
        generate_android_icons(img)
        generate_ios_icons(img)
        print("Icon generation complete.")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    main()
