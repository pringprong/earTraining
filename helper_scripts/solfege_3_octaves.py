import os
from pydub import AudioSegment

# Define the folder containing the samples
folder_path = r"C:\Users\pring\Documents\Ukulele\solfege\solfege_wav_for_note_trainer"

# Define the "Sotorrio" solfege note names
solfege_notes = ["do", "ga", "re", "nu", "mi", "fa", "jur", "so", "ki", "la", "pe", "ti"]

# Function to change pitch
def change_pitch(audio, semitones):
    return audio._spawn(audio.raw_data, overrides={
        "frame_rate": int(audio.frame_rate * (2 ** (semitones / 12.0)))
    }).set_frame_rate(audio.frame_rate)

# Step 1: Open the folder and list all files
files = [f for f in os.listdir(folder_path) if f.endswith(".wav")]

# Step 2: Rename the files
for file in files:
    # Extract the note number and solfege syllable
    note_number, note_name = file.split("-")
    note_number = int(note_number.replace("note", ""))
    
    # Rename based on the note number range
    if 48 <= note_number <= 59:
        new_name = f"C-{note_name.replace('.wav', '0.wav')}"
    elif 60 <= note_number <= 71:
        new_name = f"C-{note_name}"
    elif 72 <= note_number <= 83:
        new_name = f"C-{note_name.replace('.wav', '1.wav')}"
    else:
        continue  # Skip files outside the specified ranges
    
    # Rename the file
    os.rename(os.path.join(folder_path, file), os.path.join(folder_path, new_name))

# Step 3: Pitch-shift "C-do1.wav" up by one octave and save as "C-do2.wav"
source_file = os.path.join(folder_path, "C-do1.wav")
if os.path.exists(source_file):
    audio = AudioSegment.from_file(source_file)
    upshifted_audio = change_pitch(audio, 12)  # Pitch-shift up by one octave
    upshifted_audio.export(os.path.join(folder_path, "C-do2.wav"), format="wav")

print("Processing complete.")