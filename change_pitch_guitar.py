import os
from pydub import AudioSegment

# Define the folder containing the samples
folder_path = r"C:\Users\pring\Documents\Ukulele\solfege\guitar_samples_wav_extra"

# Define the full range of notes
all_notes = [
    "G1", "G#1", "A1", "A#1", "B1",
    "C2", "C#2", "D2", "D#2", "E2", "F2", "F#2", "G2", "G#2", "A2", "A#2", "B2",
    "C3", "C#3", "D3", "D#3", "E3", "F3", "F#3", "G3", "G#3", "A3", "A#3", "B3",
    "C4", "C#4", "D4", "D#4", "E4", "F4", "F#4", "G4", "G#4", "A4", "A#4", "B4",
    "C5", "C#5", "D5", "D#5", "E5", "F5", "F#5", "G5", "G#5", "A5", "A#5", "B5",
    "C6", "C#6", "D6", "D#6"
]

# Function to change pitch
def change_pitch(audio, semitones):
    return audio._spawn(audio.raw_data, overrides={
        "frame_rate": int(audio.frame_rate * (2 ** (semitones / 12.0)))
    }).set_frame_rate(audio.frame_rate)

# Step 1: List all notes with sample files in the folder
existing_files = [f for f in os.listdir(folder_path) if f.endswith(".wav")]
existing_notes = [os.path.splitext(f)[0] for f in existing_files]

# Step 2: Identify missing notes
missing_notes = [note for note in all_notes if note not in existing_notes]

# Step 3: Generate missing notes using pitch-shifting
for missing_note in missing_notes:
    # Find the closest existing note to use as the source
    for i, note in enumerate(all_notes):
        if note == missing_note:
            # Look for the closest lower or higher note
            lower_note = next((n for n in reversed(all_notes[:i]) if n in existing_notes), None)
            higher_note = next((n for n in all_notes[i + 1:] if n in existing_notes), None)
            
            # Use the closest note for pitch-shifting
            if lower_note:
                source_note = lower_note
                semitones = all_notes.index(missing_note) - all_notes.index(lower_note)
            elif higher_note:
                source_note = higher_note
                semitones = all_notes.index(missing_note) - all_notes.index(higher_note)
            else:
                print(f"Cannot generate {missing_note}: No suitable source note found.")
                continue
            
            # Load the source audio file
            source_file = os.path.join(folder_path, f"{source_note}.wav")
            audio = AudioSegment.from_file(source_file)
            
            # Pitch-shift the audio
            shifted_audio = change_pitch(audio, semitones)
            
            # Save the generated file
            output_file = os.path.join(folder_path, f"{missing_note}.wav")
            shifted_audio.export(output_file, format="wav")
            print(f"Generated {missing_note} from {source_note}")
            break

print("Missing notes generated.")