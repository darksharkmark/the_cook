import os

def delete_small_pngs(root_folder):
    deleted = 0
    for root, _, files in os.walk(root_folder):
        for file in files:
            if file.lower().endswith('_small.png'):
                file_path = os.path.join(root, file)
                try:
                    os.remove(file_path)
                    deleted += 1
                    print(f"🗑️ Deleted: {file_path}")
                except Exception as e:
                    print(f"❌ Failed to delete {file_path}: {e}")
    print(f"\n✅ Done! Deleted {deleted} files ending with '_small.png'.")

if __name__ == "__main__":
    folder = input("Enter the path to your folder: ").strip()
    if os.path.isdir(folder):
        confirm = input(f"Are you sure you want to delete all '*_small.png' files in '{folder}'? (y/N): ").lower()
        if confirm == 'y':
            delete_small_pngs(folder)
        else:
            print("❎ Deletion cancelled.")
    else:
        print("⚠️ Invalid folder path.")
