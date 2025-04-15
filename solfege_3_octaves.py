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
    # Extract the note name from the filename
    note_number, note_name = file.split("-")
    note_index = solfege_notes.index(note_name.split(".")[0]) + 1  # Get the index of the note
    new_name = f"C{note_index:02d}-{note_name}"  # Rename with "C" and padded index
    os.rename(os.path.join(folder_path, file), os.path.join(folder_path, new_name))

# Step 3: Pitch-shift files down by one octave and save with "0" suffix
# Step 4: Pitch-shift files up by one octave and save with "1" suffix
for file in os.listdir(folder_path):
    if file.endswith(".wav"):
        file_path = os.path.join(folder_path, file)
        audio = AudioSegment.from_file(file_path)

        # Pitch-shift down by one octave
        downshifted_audio = change_pitch(audio, -12)
        downshifted_file = file.replace(".wav", "0.wav")
        downshifted_audio.export(os.path.join(folder_path, downshifted_file), format="wav")

        # Pitch-shift up by one octave
        upshifted_audio = change_pitch(audio, 12)
        upshifted_file = file.replace(".wav", "1.wav")
        upshifted_audio.export(os.path.join(folder_path, upshifted_file), format="wav")

# Step 5: Pitch-shift "do" file up by 2 octaves and save as "C01-do2.wav"
do_file = os.path.join(folder_path, "C01-do.wav")
if os.path.exists(do_file):
    audio = AudioSegment.from_file(do_file)
    upshifted_audio_2_octaves = change_pitch(audio, 24)
    upshifted_audio_2_octaves.export(os.path.join(folder_path, "C01-do2.wav"), format="wav")

print("Processing complete.")