import os
import re

# Define the directory containing the image files
image_dir = "./"

# Define a regular expression pattern to extract the desired parts of the filename
pattern = r"(Tyler|Emma)[^_]*_([^\.]*)\."

# Iterate over the files in the directory
for filename in os.listdir(image_dir):
    # Check if the file is a .webp image file
    if filename.endswith(".webp"):
        # Extract the character name and expression from the filename using regex
        match = re.search(pattern, filename)
        if match:
            character_name = match.group(1)
            expression = match.group(2)
            # Construct the new filename format
            new_filename = f"{character_name} _{expression}.webp"
            # Construct the full paths for the old and new filenames
            old_path = os.path.join(image_dir, filename)
            new_path = os.path.join(image_dir, new_filename)
            # Rename the file
            os.rename(old_path, new_path)
            print(f"Renamed '{filename}' to '{new_filename}'")
        else:
            # If the filename does not match the expected pattern, skip it
            print(f"Filename '{filename}' does not match the expected pattern. Skipping...")

