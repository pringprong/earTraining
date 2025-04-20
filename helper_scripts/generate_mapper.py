import os

# Define the output folder and file
output_folder = r"C:\Users\pring\earTraining\mapping"
output_file = os.path.join(output_folder, "Mappin.txt")

# Ensure the output folder exists
os.makedirs(output_folder, exist_ok=True)

# Define the data
keys = ["E", "F", "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D", "D#"]
instruments = ["Guitar", "Piano", "Solfege"]
solfege_syllables = [
    "do0", "ga0", "re0", "nu0", "mi0", "fa0", "jur0", "so0", "ki0", "la0", "pe0", "ti0",
    "do", "ga", "re", "nu", "mi", "fa", "jur", "so", "ki", "la", "pe", "ti",
    "do1", "ga1", "re1", "nu1", "mi1", "fa1", "jur1", "so1", "ki1", "la1", "pe1", "ti1",
    "do2"
]
notes = [
    "E2", "F2", "F#2", "G2", "G#2", "A2", "A#2", "B2",
    "C3", "C#3", "D3", "D#3", "E3", "F3", "F#3", "G3", "G#3", "A3", "A#3", "B3",
    "C4", "C#4", "D4", "D#4", "E4", "F4", "F#4", "G4", "G#4", "A4", "A#4", "B4",
    "C5", "C#5", "D5", "D#5", "E5", "F5", "F#5", "G5", "G#5", "A5", "A#5", "B5",
    "C6", "C#6", "D6", "D#6"
]

# Open the output file for writing
with open(output_file, "w") as f:
    # Cycle through each key
    for key_index, key in enumerate(keys):
        # Get the starting index for the notes based on the key
        start_index = key_index
        # Get the 37 notes for this key
        key_notes = notes[start_index:start_index + 37]

        # Cycle through each instrument
        for instrument in instruments:
            # Cycle through each solfege syllable
            for solfege_index, solfege in enumerate(solfege_syllables):
                # Determine the note for this solfege
                note = key_notes[solfege_index]

                # Determine the file location based on the instrument
                if instrument == "Guitar":
                    file_location = f"./mp3/{note}.mp3"
                elif instrument == "Piano":
                    file_location = f"./mp3/{note}v16.mp3"
                elif instrument == "Solfege":
                    file_location = f"./mp3/{key}-{solfege}.mp3"
                else:
                    continue

                # Write the row to the file
                f.write(f"{key}\t{instrument}\t{solfege}\t{file_location}\n")

print(f"Mapper.txt has been created at {output_file}")