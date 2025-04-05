import os
import subprocess

# Define paths
script_name = "sound.py"
mapping_file = "Mapping.txt"
mp3_folder = "mp3"
tmp_mp3_folder = "tmp_mp3"

# PyInstaller command
command = [
    "pyinstaller",
    "--onefile",
    f"--add-data={mapping_file};.",
    f"--add-data={mp3_folder};mp3",
    f"--add-data={tmp_mp3_folder};tmp_mp3",
    script_name
]

# Run the command
subprocess.run(command)

print("Packaging complete. Check the 'dist' folder for the executable.")