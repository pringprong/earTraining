from pydub import AudioSegment
import os

# Folder containing the .wav files
folder_path = r"C:\Users\pring\Documents\Ukulele\solfege\wav_for_note_trainer"

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

        # Change pitch downward by a semitone
        down_audio = change_pitch(audio, -1)
        # Change pitch upward by a semitone
        up_audio = change_pitch(audio, 1)

        # Generate new filenames based on the rules
        if filename.startswith("A"):
            down_filename = filename.replace("A", "G#", 1)
            up_filename = filename.replace("A", "A#", 1)
        elif filename.startswith("C") and filename[1].isdigit():
            number = int(filename[1])
            down_filename = filename.replace(f"C{number}", f"B{number - 1}", 1)
            up_filename = filename.replace(f"C{number}", f"C#{number}", 1)
        elif filename.startswith("D#"):
            down_filename = filename.replace("D#", "D", 1)
            up_filename = filename.replace("D#", "E", 1)
        elif filename.startswith("F#"):
            down_filename = filename.replace("F#", "F", 1)
            up_filename = filename.replace("F#", "G", 1)
        else:
            continue  # Skip files that don't match the rules

        # Save the new files
        down_path = os.path.join(folder_path, down_filename)
        up_path = os.path.join(folder_path, up_filename)
        down_audio.export(down_path, format="wav")
        up_audio.export(up_path, format="wav")

        print(f"Processed: {filename} -> {down_filename}, {up_filename}")

print("All files processed.")