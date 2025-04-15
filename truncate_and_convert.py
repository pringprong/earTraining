from pydub import AudioSegment
import os

# Folder containing the .wav files
#folder_path = r"C:\Users\pring\Documents\Ukulele\solfege\SpanishClassicalGuitar-SFZ-20190618\samples"
#folder_path = r"C:\Users\pring\Documents\Ukulele\solfege\wav_for_note_trainer"
#folder_path = r"C:\Users\pring\Documents\Ukulele\solfege\solfege_wav_for_note_trainer"
folder_path = r"C:\Users\pring\Documents\Ukulele\solfege\guitar_samples_wav_extra"

# Iterate through all files in the folder
for filename in os.listdir(folder_path):
    if filename.endswith(".wav"):
        file_path = os.path.join(folder_path, filename)
        
        # Load the .wav file
        audio = AudioSegment.from_wav(file_path)
        
        # Truncate to 1 second
        truncated_audio = audio[:1000]  # 1000 ms = 1 second
        
        # Convert to .mp3
        mp3_filename = os.path.splitext(filename)[0] + ".mp3"
        mp3_path = os.path.join(folder_path, mp3_filename)
        truncated_audio.export(mp3_path, format="mp3")
        
        print(f"Processed and saved: {mp3_filename}")

print("All files processed.")