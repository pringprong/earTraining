import tkinter as tk
from tkinter import ttk, scrolledtext
import random
from playsound import playsound
from pydub import AudioSegment
import os
import threading
import sys
import tempfile  # Import the tempfile module

# Determine the base path (for both development and PyInstaller executable)
if getattr(sys, 'frozen', False):  # Check if running as a PyInstaller executable
    base_path = sys._MEIPASS
else:
    base_path = os.path.dirname(os.path.abspath(__file__))

# Load Mapping.txt into a dictionary
mapping_file_path = os.path.join(base_path, "mapping", "Mapping.txt")
Mapping = {}
with open(mapping_file_path, "r") as file:
    for line in file:
        key1, key2, key3, value = line.strip().split("\t")
        if key1 not in Mapping:
            Mapping[key1] = {}
        if key2 not in Mapping[key1]:
            Mapping[key1][key2] = {}
        Mapping[key1][key2][key3] = value

# Create the main window
root = tk.Tk()
root.title("Melody Ear Trainer")

# Define a global font and colors
FONT = ("Arial", 14, "bold")
BIGFONT = ("Arial", 18, "bold")
BG_COLOR = "#e1eaf7"  # Light blue background
BUTTON_COLOR = "#82aaf4"  # Sky blue for buttons
TEXT_COLOR = "#0c1d43"  # Navy text color

# Apply background color to the root window
root.configure(background=BG_COLOR)

# Dropdown for "Key"
key_label = tk.Label(root, text="Key of melody:", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
key_label.grid(row=0, column=0, padx=10, pady=10, sticky="w")
key_dropdown = ttk.Combobox(root, values=list(Mapping.keys()), font=FONT, state="readonly", takefocus=True)
key_dropdown.grid(row=0, column=1, padx=10, pady=10)
key_dropdown.current(0)

# Dropdown for "Number of notes"
notes_label = tk.Label(root, text="Number of notes:", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
notes_label.grid(row=1, column=0, padx=10, pady=10, sticky="w")
notes_dropdown = ttk.Combobox(root, values=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10], font=FONT, state="readonly", takefocus=True)
notes_dropdown.grid(row=1, column=1, padx=10, pady=10)
notes_dropdown.current(4)

# Dropdown for "Maximum distance between notes"
distance_label = tk.Label(root, text="Max distance between neighbouring notes:", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
distance_label.grid(row=2, column=0, padx=10, pady=10, sticky="w")
distance_dropdown = ttk.Combobox(root, values=[1, 2, 3, 4, 5, 6, 7], font=FONT, state="readonly", takefocus=True)
distance_dropdown.grid(row=2, column=1, padx=10, pady=10)
distance_dropdown.current(2)

# Set initial focus
key_dropdown.focus_set()

# Define BooleanVars for checkboxes
start_with_do_var = tk.BooleanVar(value=True)  # Checked by default
end_with_do_var = tk.BooleanVar(value=True)  # Checked by default

# Checkboxes for "Start with do" and "End with do"
start_with_do_checkbox = tk.Checkbutton(root, text="Start with do", variable=start_with_do_var, font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
start_with_do_checkbox.grid(row=3, column=0, padx=10, pady=10, sticky="w")

end_with_do_checkbox = tk.Checkbutton(root, text="End with do", variable=end_with_do_var, font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
end_with_do_checkbox.grid(row=3, column=1, padx=10, pady=10, sticky="w")

# Checkboxes for "Notes"
note_vars = {}
notes = [
    "do0", "re0", "mi0", "fa0", "so0", "la0", "ti0",
    "do", "re", "mi", "fa", "so", "la", "ti",
    "do1", "re1", "mi1", "fa1", "so1", "la1", "ti1",
    "do2"
]

for i, note in enumerate(notes):
    note_vars[note] = tk.BooleanVar(value=note in ["do", "re", "mi", "fa", "so"])

# Checkboxes for "Notes"
notes_frame = tk.LabelFrame(root, text="Notes", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
notes_frame.grid(row=4, column=0, columnspan=2, padx=10, pady=10, sticky="w")
for i, note in enumerate(notes):
    checkbox = tk.Checkbutton(notes_frame, text=note, variable=note_vars[note], font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
    checkbox.grid(row=i // 7, column=i % 7, padx=10, pady=10)

# Text area for "Solfege"
solfege_text = tk.Text(root, height=1, width=40, font=FONT, bg="white", fg=TEXT_COLOR, takefocus=False, state="disabled")
solfege_text.grid(row=6, column=1, padx=10, pady=10, sticky="w")

# Functionality
Melody = []

def play_tonic(instrument):
    key = key_dropdown.get()
    file_to_play = Mapping[key][instrument]["do"]
    
    # Split file_to_play into folder and filename
    folder, filename = os.path.split(file_to_play)
    
    # Reassemble the path using base_path
    full_path = os.path.join(base_path, folder, filename)
    
    # Play the file
    play = threading.Thread(target=playsound, args=(full_path,))
    play.start()

def generate_melody():
    # Clear previous melody and files
    solfege_text.config(state="normal")  # Enable editing temporarily
    solfege_text.delete("1.0", tk.END)  # Clear the text box
    solfege_text.config(state="disabled")  # Disable editing again  
    instruments = ["Guitar", "Piano", "Solfege"]
    
    # Create a temporary directory for combined files
    temp_dir = tempfile.gettempdir()  # Get the system's temporary directory
    for instrument in instruments:
        combined_file = os.path.join(temp_dir, f"combined_melody_{instrument}.mp3")
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

    # Replace the first note with "do" if "Start with do" is checked
    if start_with_do_var.get():
        Melody[0] = "do"

    # Replace the last note with "do" if "End with do" is checked
    if end_with_do_var.get():
        Melody[-1] = "do"

    # Combine MP3s for all instruments
    for instrument in instruments:
        combined = AudioSegment.empty()  # Start with an empty audio segment
        key = key_dropdown.get()
        for note in Melody:
            file_to_play = Mapping[key][instrument][note]
            # Split file_to_play into folder and filename
            folder, filename = os.path.split(file_to_play)  
            # Reassemble the path using base_path
            full_path = os.path.join(base_path, folder, filename)
            audio = AudioSegment.from_file(full_path, format="mp3")  # Load the MP3 file
            combined += audio  # Concatenate the audio
        # Save the combined audio for the instrument
        combined_file = os.path.join(temp_dir, f"combined_melody_{instrument}.mp3")
        combined.export(combined_file, format="mp3")     

def show_solfege():
    solfege_text.config(state="normal")  # Enable editing temporarily
    solfege_text.delete("1.0", tk.END)  # Clear the text box
    solfege_text.insert(tk.END, " ".join(Melody))  # Insert the melody
    solfege_text.config(state="disabled")  # Disable editing again    

def play_melody(instrument):
    # Get the system's temporary directory
    temp_dir = tempfile.gettempdir()
    
    # Path to the pre-generated combined MP3 for the selected instrument
    combined_file = os.path.join(temp_dir, f"combined_melody_{instrument}.mp3")
    
    # Play the file
    play = threading.Thread(target=playsound, args=(combined_file,))
    play.start()

# Buttons
generate_button = tk.Button(root, text="Generate melody", command=generate_melody, font=BIGFONT, bg=BUTTON_COLOR, fg=TEXT_COLOR, underline=0)
generate_button.grid(row=5, column=1, columnspan=2, padx=10, pady=10, sticky="w")
root.bind("g", lambda event: generate_melody())

show_solfege_button = tk.Button(root, text="Show Solfege", command=show_solfege, font=FONT, bg=BUTTON_COLOR, fg=TEXT_COLOR, underline=0)
show_solfege_button.grid(row=6, column=0, padx=10, pady=10, sticky="w")
root.bind("s", lambda event: show_solfege())

play_guitar_tonic_button = tk.Button(root, text="Play Guitar Tonic", command=lambda: play_tonic("Guitar"), font=FONT, bg=BUTTON_COLOR, fg=TEXT_COLOR)
play_guitar_tonic_button.grid(row=7, column=0, padx=10, pady=10, sticky="w")

play_piano_tonic_button = tk.Button(root, text="Play Piano Tonic", command=lambda: play_tonic("Piano"), font=FONT, bg=BUTTON_COLOR, fg=TEXT_COLOR)
play_piano_tonic_button.grid(row=7, column=1, padx=10, pady=10, sticky="w")

play_solfege_tonic_button = tk.Button(root, text="Play Solfege Tonic", command=lambda: play_tonic("Solfege"), font=FONT, bg=BUTTON_COLOR, fg=TEXT_COLOR)
play_solfege_tonic_button.grid(row=7, column=2, padx=10, pady=10, sticky="w")

play_guitar_melody_button = tk.Button(root, text="Play Guitar Melody", command=lambda: play_melody("Guitar"), font=FONT, bg=BUTTON_COLOR, fg=TEXT_COLOR, underline=16)
play_guitar_melody_button.grid(row=8, column=0, padx=10, pady=10, sticky="w")
root.bind("d", lambda event: play_melody("Guitar"))

play_piano_melody_button = tk.Button(root, text="Play Piano Melody", command=lambda: play_melody("Piano"), font=FONT, bg=BUTTON_COLOR, fg=TEXT_COLOR, underline=2)
play_piano_melody_button.grid(row=8, column=1, padx=10, pady=10, sticky="w")
root.bind("a", lambda event: play_melody("Piano"))

play_solfege_melody_button = tk.Button(root, text="Play Solfege Melody", command=lambda: play_melody("Solfege"), font=FONT, bg=BUTTON_COLOR, fg=TEXT_COLOR, underline=8)
play_solfege_melody_button.grid(row=8, column=2, padx=10, pady=10, sticky="w")
root.bind("f", lambda event: play_melody("Solfege"))

# Run the application
root.mainloop()