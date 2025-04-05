from pydub import AudioSegment
import os

# Folder containing the .wav files
folder_path = r"C:\Users\pring\Documents\Ukulele\solfege\solfege_wav_for_note_trainer"

# Function to change pitch
def change_pitch(audio, semitones):
    return audio._spawn(audio.raw_data, overrides={
        "frame_rate": int(audio.frame_rate * (2 ** (semitones / 12.0)))
    }).set_frame_rate(audio.frame_rate)

# Process each .wav file in the folder
for filename in os.listdir(folder_path):
    if filename.endswith(".wav"):
        file_path = os.path.join(folder_path, filename)
        audio = AudioSegment.from_file(file_path)

        # Change pitch downward by 5 semitones
        down_audio = change_pitch(audio, -5)

        # Generate new filename with "G_" appended to the beginning
        new_filename = f"G_{filename}"
        new_path = os.path.join(folder_path, new_filename)

        # Save the new file
        down_audio.export(new_path, format="wav")

        print(f"Processed: {filename} -> {new_filename}")

print("All files processed.")