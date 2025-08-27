#!/bin/bash

# Simple Dropbox symlink setup
# Creates symlinks from home folders to Dropbox folders

DROPBOX_DIR="$HOME/Dropbox"

# Get all folders from Dropbox
FOLDERS=()
for folder in "$DROPBOX_DIR"/*/; do
    if [[ -d "$folder" ]]; then
        folder_name=$(basename "$folder")
        FOLDERS+=("$folder_name")
    fi
done

echo "Setting up Dropbox symlinks..."

for folder in "${FOLDERS[@]}"; do
    home_folder="$HOME/$folder"
    dropbox_folder="$DROPBOX_DIR/$folder"
    
    # Skip if Dropbox folder doesn't exist
    if [[ ! -d "$dropbox_folder" ]]; then
        echo "Skipping $folder (not in Dropbox)"
        continue
    fi
    
    # Remove existing home folder if it exists and isn't a symlink
    if [[ -d "$home_folder" ]] && [[ ! -L "$home_folder" ]]; then
        rm -rf "$home_folder"
        echo "Removed existing $folder"
    fi
    
    # Create symlink
    ln -sf "$dropbox_folder" "$home_folder"
    echo "Linked $folder -> Dropbox/$folder"
done

echo "Done!"
