#!/bin/zsh

if [ "$#" -eq 0 ]; then
    echo "No files selected."
    exit 1
fi

# 1. Setup Paths
# We go up one level ($1:a:h) so we can zip the folder itself, not just its contents
TARGET_DIR="${1:a:h}"
FIRST_ITEM="${1:t}"

# 2. Logic to handle "Folder" vs "File" naming
# If it's a directory, we use the full name. If it's a file, we strip the extension.
if [[ -d "$1" ]]; then
    FINAL_NAME="${FIRST_ITEM}.zip"
else
    FINAL_NAME="${FIRST_ITEM%.*}.zip"
fi

# 3. Enter the PARENT directory
cd "$TARGET_DIR" || exit

# 4. Prepare relative arguments
# We use the 'tail' to ensure we aren't pulling in /Users/dexter/...
relative_args=()
for arg in "$@"; do
    relative_args+=("${arg:t}")
done

echo -e "\033[0;34m[ Zipping to $FINAL_NAME... ]\033[0m"

# 5. Execute Zip
# This now includes the folder name in the zip because we are zipping from the parent dir
zip -r "$FINAL_NAME" "${relative_args[@]}" -x "*.DS_Store" -x "__MACOSX/*"

if [ $? -eq 0 ]; then
    echo -e "\n\033[0;32m[ ✔ ] Created $FINAL_NAME in $TARGET_DIR\033[0m"
else
    echo -e "\n\033[0;31m[ ✘ ] Zip failed\033[0m"
fi

echo -n -e "\n\033[0;90mPress any key\033[0m"
read -k 1 < /dev/tty