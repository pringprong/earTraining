import os
from pydub import AudioSegment

# Define the folder containing the samples
folder_path = r"C:\Users\pring\Documents\Ukulele\solfege\solfege_wav_for_note_trainer"

# Define the keys and their pitch-shift values (in semitones)
keys_down = {"E": -8, "F": -7, "F#": -6, "G": -5, "G#": -4, "A": -3, "A#": -2, "B": -1}
keys_up = {"C#": 1, "D": 2, "D#": 3}

# Combine all keys into a single dictionary
keys = {**keys_down, **keys_up}

# Function to change pitch
def change_pitch(audio, semitones):
    return audio._spawn(audio.raw_data, overrides={
        "frame_rate": int(audio.frame_rate * (2 ** (semitones / 12.0)))
    }).set_frame_rate(audio.frame_rate)

# Step 1: Open the folder and list all files
files = [f for f in os.listdir(folder_path) if f.endswith(".wav")]

# Step 2: Process each file for all keys
for file in files:
    # Load the original audio file
    file_path = os.path.join(folder_path, file)
    audio = AudioSegment.from_file(file_path)
    
    # Extract the solfege syllable and replace the key prefix
    original_key = "C"
    solfege_name = file[1:]  # Remove the first letter (key prefix)
    
    # Generate pitch-shifted files for each key
    for key, semitones in keys.items():
        # Change the key prefix in the filename
        new_filename = f"{key}{solfege_name}"
        new_file_path = os.path.join(folder_path, new_filename)
        
        # Pitch-shift the audio
        shifted_audio = change_pitch(audio, semitones)
        
        # Export the pitch-shifted file
        shifted_audio.export(new_file_path, format="wav")
        print(f"Generated {new_filename}")

print("Processing complete.")