import tkinter as tk
from tkinter import ttk, scrolledtext
import random
from playsound import playsound
from pydub import AudioSegment
import os

# Load Mapping.txt into a dictionary
Mapping = {}
with open("Mapping.txt", "r") as file:
    for line in file:
        key1, key2, key3, value = line.strip().split("\t")
        if key1 not in Mapping:
            Mapping[key1] = {}
        if key2 not in Mapping[key1]:
            Mapping[key1][key2] = {}
        Mapping[key1][key2][key3] = value

# Create the main window
root = tk.Tk()
root.title("Music Trainer")

# Dropdown for "Key"
key_label = tk.Label(root, text="Key:")
key_label.grid(row=0, column=0, padx=10, pady=5, sticky="w")
key_dropdown = ttk.Combobox(root, values=["C Major", "G Major"])
key_dropdown.grid(row=0, column=1, padx=10, pady=5)
key_dropdown.current(0)

# Dropdown for "Number of notes"
notes_label = tk.Label(root, text="Number of notes:")
notes_label.grid(row=1, column=0, padx=10, pady=5, sticky="w")
notes_dropdown = ttk.Combobox(root, values=[1, 2, 3, 4, 5, 6])
notes_dropdown.grid(row=1, column=1, padx=10, pady=5)
notes_dropdown.current(5)

# Dropdown for "Maximum distance between notes"
distance_label = tk.Label(root, text="Maximum distance between notes:")
distance_label.grid(row=2, column=0, padx=10, pady=5, sticky="w")
distance_dropdown = ttk.Combobox(root, values=[1, 2, 3, 4, 5, 6])
distance_dropdown.grid(row=2, column=1, padx=10, pady=5)
distance_dropdown.current(2)

# Checkboxes for "Notes"
notes_frame = tk.LabelFrame(root, text="Notes")
notes_frame.grid(row=3, column=0, columnspan=2, padx=10, pady=5, sticky="w")
note_vars = {}
notes = [
    "do0", "re0", "mi0", "fa0", "so0", "la0", "ti0",
    "do", "re", "mi", "fa", "so", "la", "ti",
    "do1", "re1", "mi1", "fa1", "so1", "la1", "ti1",
    "do2"
]

for i, note in enumerate(notes):
    note_vars[note] = tk.BooleanVar(value=note in ["do", "re", "mi", "fa", "so"])
    checkbox = tk.Checkbutton(notes_frame, text=note, variable=note_vars[note])
    checkbox.grid(row=i // 7, column=i % 7, padx=5, pady=5)

# Functionality
Melody = []

def play_tonic(instrument):
    key = key_dropdown.get()
    file_to_play = Mapping[key][instrument]["do"]
    playsound(file_to_play)

def generate_melody():

    # Clear previous melody and files
    instruments = ["Guitar", "Piano", "Solfege"]
    for instrument in instruments:
        combined_file = "C:\\Users\\pring\\Documents\\Ukulele\\solfege\\mp3_for_note_trainer\\combined_melody_"+instrument+".mp3"
        os.remove(combined_file) if os.path.exists(combined_file) else None


    global Melody
    num_notes = int(notes_dropdown.get())
    max_distance = int(distance_dropdown.get())
    available_notes = [note for note, var in note_vars.items() if var.get()]
    Melody = [random.choice(available_notes)]
    for _ in range(1, num_notes):
        current_index = available_notes.index(Melody[-1])
        start = max(0, current_index - max_distance)
        end = min(len(available_notes), current_index + max_distance + 1)
        next_note = random.choice(available_notes[start:end])
        while next_note == Melody[-1]:  # Ensure the next note is not the same as the last one
            next_note = random.choice(available_notes[start:end])
        Melody.append(next_note)

    # Combine MP3s for all instruments
    for instrument in instruments:
        combined = AudioSegment.empty()  # Start with an empty audio segment
        key = key_dropdown.get()
        for note in Melody:
            file_to_play = Mapping[key][instrument][note]
            audio = AudioSegment.from_file(file_to_play, format="mp3")  # Load the MP3 file
            combined += audio  # Concatenate the audio
        # Save the combined audio for the instrument
        combined_file = "C:\\Users\\pring\\Documents\\Ukulele\\solfege\\mp3_for_note_trainer\\combined_melody_"+instrument+".mp3"
        combined.export(combined_file, format="mp3")

def show_solfege():
    solfege_text.delete("1.0", tk.END)
    solfege_text.insert(tk.END, " ".join(Melody))

def play_melody(instrument):
    # Play the pre-generated combined MP3 for the selected instrument
    combined_file = "C:\\Users\\pring\\Documents\\Ukulele\\solfege\\mp3_for_note_trainer\\combined_melody_"+instrument+".mp3"
    playsound(combined_file)

# Text area for "Solfege"
solfege_label = tk.Label(root, text="Solfege:")
solfege_label.grid(row=5, column=0, padx=10, pady=5, sticky="w")
solfege_text = scrolledtext.ScrolledText(root, height=3, width=30)  # Make the text box smaller
solfege_text.grid(row=6, column=0, padx=10, pady=5, sticky="w")  # Position it below "Generate melody"

# Create the "Generate melody" button and place it above "Solfege"
generate_button = tk.Button(root, text="Generate melody", command=generate_melody, font=("Arial", 12, "bold"))
generate_button.grid(row=4, column=0, columnspan=2, pady=10)

# Buttons for "Show Solfege" and tonic/melody playback
show_solfege_button = tk.Button(root, text="Show Solfege", command=show_solfege)
show_solfege_button.grid(row=6, column=1, padx=10, pady=5)

# Row for "Play Tonic" buttons
play_guitar_tonic_button = tk.Button(root, text="Play Guitar Tonic", command=lambda: play_tonic("Guitar"))
play_guitar_tonic_button.grid(row=7, column=0, padx=5, pady=5)

play_piano_tonic_button = tk.Button(root, text="Play Piano Tonic", command=lambda: play_tonic("Piano"))
play_piano_tonic_button.grid(row=7, column=1, padx=5, pady=5)

play_solfege_tonic_button = tk.Button(root, text="Play Solfege Tonic", command=lambda: play_tonic("Solfege"))
play_solfege_tonic_button.grid(row=7, column=2, padx=5, pady=5)

# Row for "Play Melody" buttons
play_guitar_melody_button = tk.Button(root, text="Play Guitar Melody", command=lambda: play_melody("Guitar"))
play_guitar_melody_button.grid(row=8, column=0, padx=5, pady=5)

play_piano_melody_button = tk.Button(root, text="Play Piano Melody", command=lambda: play_melody("Piano"))
play_piano_melody_button.grid(row=8, column=1, padx=5, pady=5)

play_solfege_melody_button = tk.Button(root, text="Play Solfege Melody", command=lambda: play_melody("Solfege"))
play_solfege_melody_button.grid(row=8, column=2, padx=5, pady=5)

# Run the application
root.mainloop()