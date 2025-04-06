import os
import subprocess
import zipfile

# Define paths
script_name = "melody_ear_trainer.py"
mapping_file = "./mapping/Mapping.txt"
mp3_folder = "mp3"
output_zip = "dist/melody_ear_trainer.zip"

# PyInstaller command to create the executable
command = [
    "pyinstaller",
    "--onefile",
    f"--add-data={mapping_file};mapping",  # Include Mapping.txt in the "mapping" folder
    f"--add-data={mp3_folder};mp3",       # Include mp3 folder
    script_name
]

# Run the PyInstaller command
subprocess.run(command)

# Path to the generated executable
dist_folder = "dist"
executable_path = os.path.join(dist_folder, "melody_ear_trainer.exe")

# Check if the executable exists
if os.path.exists(executable_path):
    # Create a zip file containing the executable
    with zipfile.ZipFile(output_zip, "w") as zipf:
        zipf.write(executable_path, arcname="melody_ear_trainer.exe")
    print(f"Executable zipped as {output_zip}")
else:
    print("Executable not found. Ensure PyInstaller ran successfully.")