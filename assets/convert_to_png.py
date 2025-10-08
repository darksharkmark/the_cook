import os
from PIL import Image

def convert_jpg_to_png(root_folder):
    for root, _, files in os.walk(root_folder):
        for file in files:
            if file.lower().endswith(('.jpg', '.jpeg')):
                jpg_path = os.path.join(root, file)
                png_path = os.path.splitext(jpg_path)[0] + '.png'

                try:
                    with Image.open(jpg_path) as img:
                        img.convert('RGBA').save(png_path, 'PNG')
                    print(f"✅ Converted: {jpg_path} → {png_path}")
                except Exception as e:
                    print(f"❌ Failed to convert {jpg_path}: {e}")

if __name__ == "__main__":
    folder = input("Enter the path to your image folder: ").strip()
    if os.path.isdir(folder):
        convert_jpg_to_png(folder)
        print("\nAll conversions complete ✅")
    else:
        print("⚠️ Invalid folder path.")
