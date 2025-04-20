import tkinter as tk
from tkinter import ttk, scrolledtext
import random
from playsound import playsound
from pydub import AudioSegment
import os
import threading
import sys
import tempfile  # Import the tempfile module
import tkinter.messagebox  # Import the messagebox module

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
FONTLIGHT = ("Arial", 12, "italic")
BIGFONT = ("Arial", 18, "bold")
BG_COLOR = "#e1eaf7"  # Light blue background
BUTTON_COLOR = "#82aaf4"  # Sky blue for buttons
TEXT_COLOR = "#0c1d43"  # Navy text color

# Apply background color to the root window
root.configure(background=BG_COLOR)

# Create a collapsible pane for settings
settings_pane = tk.LabelFrame(root, text="Settings", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
settings_pane.grid(row=1, column=0, columnspan=3, padx=10, pady=10, sticky="ew")

# Function to toggle the visibility of the settings pane
def toggle_settings():
    if settings_pane.winfo_ismapped():
        settings_pane.grid_remove()  # Hide the pane
        toggle_button.config(text="Settings")
    else:
        settings_pane.grid()  # Show the pane
        toggle_button.config(text="Hide Settings")

# Add a toggle button
toggle_button = tk.Button(root, text="Hide Settings", command=toggle_settings, font=FONT, bg=BUTTON_COLOR, fg=TEXT_COLOR)
toggle_button.grid(row=0, column=2, padx=10, pady=10, sticky="e")

# Dropdown for "Key"
key_label = tk.Label(settings_pane, text="Key of melody:", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
key_label.grid(row=0, column=0, columnspan=2, padx=10, pady=10, sticky="w")
mapping_keys = list(Mapping.keys())
mapping_keys.sort()  # Sort the keys for better readability
key_dropdown = ttk.Combobox(settings_pane, values=mapping_keys, font=FONT, state="readonly", takefocus=True)
key_dropdown.grid(row=0, column=2, padx=10, pady=10, sticky="w")
key_dropdown.current(3)

# Dropdown for "Number of notes"
notes_label = tk.Label(settings_pane, text="Number of notes in melody:", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
notes_label.grid(row=1, column=0, columnspan=2, padx=10, pady=10, sticky="w")
notes_dropdown = ttk.Combobox(settings_pane, values=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10], font=FONT, state="readonly", takefocus=True)
notes_dropdown.grid(row=1, column=2, padx=10, pady=10, sticky="w")
notes_dropdown.current(5)

# Dropdown for "Maximum distance between notes"
distance_label = tk.Label(settings_pane, text="Max distance between adjacent notes:", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
distance_label.grid(row=2, column=0, columnspan=2, padx=10, pady=10, sticky="w")
distance_dropdown = ttk.Combobox(settings_pane, values=[1, 2, 3, 4, 5, 6, 7], font=FONT, state="readonly", takefocus=True)
distance_dropdown.grid(row=2, column=2, padx=10, pady=10, sticky="w")
distance_dropdown.current(2)

# Set initial focus
key_dropdown.focus_set()

# Define BooleanVars for checkboxes
start_with_do_var = tk.BooleanVar(value=True)  # Checked by default
end_with_do_var = tk.BooleanVar(value=True)  # Checked by default
allow_repeated_notes_var = tk.BooleanVar(value=False)  # Unchecked by default

# Checkboxes for "Start with do" and "End with do"
start_with_do_label = tk.Label(settings_pane, text="Starting note (tonic):", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
start_with_do_label.grid(row=3, column=0, columnspan=1, padx=10, pady=10, sticky="w")
start_with_do_checkbox = tk.Checkbutton(settings_pane, text="Always start with", variable=start_with_do_var, font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
start_with_do_checkbox.grid(row=3, column=1, padx=10, pady=10, sticky="w")
start_with_do_dropdown = ttk.Combobox(settings_pane, values=["do0", "la0", "do", "la", "do1", "la1", "do2"], font=FONT, state="readonly", takefocus=True)
start_with_do_dropdown.grid(row=3, column=2, padx=10, pady=10, sticky="w")
start_with_do_dropdown.current(2)

end_with_do_label = tk.Label(settings_pane, text="Ending note:", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
end_with_do_label.grid(row=4, column=0, columnspan=1, padx=10, pady=10, sticky="w")
end_with_do_checkbox = tk.Checkbutton(settings_pane, text="Always end with", variable=end_with_do_var, font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
end_with_do_checkbox.grid(row=4, column=1, padx=10, pady=10, sticky="w")
end_with_do_dropdown = ttk.Combobox(settings_pane, values=["do0", "la0", "do", "la", "do1", "la1", "do2"], font=FONT, state="readonly", takefocus=True)
end_with_do_dropdown.grid(row=4, column=2, padx=10, pady=10, sticky="w")
end_with_do_dropdown.current(2)

allow_repeated_notes = tk.Label(settings_pane, text="Allow repeated notes:", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
allow_repeated_notes.grid(row=5, column=0, columnspan=1, padx=10, pady=10, sticky="w")
allow_repeated_notes_checkbox = tk.Checkbutton(settings_pane, text="Allow repeated notes", variable=allow_repeated_notes_var, font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
allow_repeated_notes_checkbox.grid(row=5, column=2, padx=10, pady=10, sticky="w")


# Checkboxes for "Notes"
note_vars = {}
notes = [
#    "do0", "re0", "mi0", "fa0", "so0", "la0", "ti0",
    "do0", "ga0", "re0", "nu0", "mi0", "fa0", "jur0", "so0", "ki0", "la0", "pe0", "ti0",
    "do", "ga", "re", "nu", "mi", "fa", "jur", "so", "ki", "la", "pe", "ti",
    "do1", "ga1", "re1", "nu1", "mi1", "fa1", "jur1", "so1", "ki1", "la1", "pe1", "ti1",
    "do2"
]

# Initialize note_vars with BooleanVar for each note
note_vars = {note: tk.BooleanVar(value=False) for note in notes}

#for i, note in enumerate(notes):
#    note_vars[note] = tk.BooleanVar(value=note in ["so0", "la0", "ti0", "do", "re", "mi", "fa", "so", "la"])

# Checkboxes for "Notes"
notes_frame = tk.LabelFrame(root, text="Include which notes in melody:", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
notes_frame.grid(row=7, column=0, columnspan=3, padx=10, pady=10, sticky="w")
for i, note in enumerate(notes):
#    checkbox = tk.Checkbutton(notes_frame, text=note, variable=note_vars[note], font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
#    checkbox.grid(row=i // 7, column=i % 7, padx=10, pady=10)
    if (note in ["ga0", "nu0", "jur0", "ki0", "pe0", "ga", "nu", "jur", "ki", "pe", "ga1", "nu1", "jur1", "ki1", "pe1"]):
        checkbox = tk.Checkbutton(notes_frame, text=note, variable=note_vars[note], font=FONTLIGHT, bg=BG_COLOR, fg=TEXT_COLOR)
    else:
        checkbox = tk.Checkbutton(notes_frame, text=note, variable=note_vars[note], font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
    checkbox.grid(row=i // 12, column=i % 12, padx=4, pady=10)

# Add "Note set" label and dropdown
note_set_label = tk.Label(settings_pane, text="Scale:", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
note_set_label.grid(row=6, column=0, columnspan=1, padx=10, pady=10, sticky="w")

note_set_dropdown = ttk.Combobox(settings_pane, values=["Default",
                                                "Diatonic major",
                                                "Diatonic major lower octave",
                                                "Diatonic major higher octave",
                                                "Natural minor",
                                                "Natural minor lower octave",
                                                "Natural minor higher octave",
                                                "Pentatonic major",
                                                "Pentatonic major lower octave",
                                                "Pentatonic major higher octave",
                                                "Pentatonic minor",
                                                "Pentatonic minor lower octave",
                                                "Pentatonic minor higher octave",                                                
                                                "Blues major",
                                                "Blues major lower octave",
                                                "Blues major higher octave",
                                                "Blues minor",
                                                "Blues minor lower octave",
                                                "Blues minor higher octave",                                                
                                                "Select all",
                                                "Select none",
                                                ], font=FONT, state="readonly", takefocus=True)
note_set_dropdown.grid(row=6, column=2, padx=10, pady=10, sticky="w")
note_set_dropdown.current(0)  # Set "Default" as the initial value

# Text area for "Solfege"
solfege_text = tk.Text(root, height=1, width=40, font=FONT, bg="white", fg=TEXT_COLOR, takefocus=False, state="disabled")
solfege_text.grid(row=9, column=1, columnspan=2, padx=10, pady=10, sticky="w")

# Functionality
Melody = []

def play_tonic(instrument):
    key = key_dropdown.get()
    file_to_play = Mapping[key][instrument][start_with_do_dropdown.get()]
    
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

    # initialize Melody and get user inputs
    global Melody
    available_notes = [note for note, var in note_vars.items() if var.get()]
    num_notes = int(notes_dropdown.get())
    max_distance = int(distance_dropdown.get())
    starting_index = 1
    ending_index = num_notes

    # Show a warning if not enough notes are selected
    # the minimum number of notes is the minimum of 2 and the effective length of the melody
    # where the effective length is the original length reduced by 1 for each of the "Start with do" and "End with do" checkboxes
    min_number_of_notes_no_repeats = 2 if not allow_repeated_notes_var.get() else 1
    effective_length = num_notes - (start_with_do_var.get() + end_with_do_var.get())
    min_number_of_notes = min(min_number_of_notes_no_repeats, effective_length)  # Ensure at least 2 notes are selected

    if len(available_notes) < min_number_of_notes:
        tk.messagebox.showwarning("Warning", "Not enough notes selected! Please select at least " + str(min_number_of_notes) + " note(s).")
        return  # Exit the function if no notes are available
    # set the first note to"do" if "Start with do" is checked
    if start_with_do_var.get():
        Melody = [start_with_do_dropdown.get()]
        if (not end_with_do_var.get() and num_notes > 1) or (end_with_do_var.get() and num_notes > 2):
            Melody.append(random.choice(available_notes))
        starting_index = 2
    elif (not end_with_do_var.get()) or (end_with_do_var.get() and num_notes > 1):  
        Melody = [random.choice(available_notes)]

    # stop before the last note if "End with do" is checked
    if end_with_do_var.get():
        ending_index = num_notes - 1  
    for _ in range(starting_index, ending_index):
        current_index = available_notes.index(Melody[-1])
        start = max(0, current_index - max_distance)
        end = min(len(available_notes), current_index + max_distance + 1)
        next_note = random.choice(available_notes[start:end])
        if not allow_repeated_notes_var.get():  # Check if repeated notes are allowed
            while next_note == Melody[-1]:  # Ensure the next note is not the same as the last one
                next_note = random.choice(available_notes[start:end])
        else: # just pick one
           next_note = random.choice(available_notes[start:end]) 
        Melody.append(next_note)

    # Replace the last note with "do" if "End with do" is checked
    if end_with_do_var.get() and (len(Melody) < num_notes):
        Melody.append(end_with_do_dropdown.get())

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


# Function to update note_vars based on the selected note set
def update_note_set(event=None):
    selected_set = note_set_dropdown.get()
    if selected_set == "Default":
        checked_notes = ["so0", "la0", "ti0", "do", "re", "mi", "fa", "so", "la", "ti", "do1"]
    elif selected_set == "Diatonic major":
        checked_notes = ["do", "re", "mi", "fa", "so", "la", "ti", "do1"]
    elif selected_set == "Diatonic major lower octave":
        checked_notes = ["do0", "re0", "mi0", "fa0", "so0", "la0", "ti0", "do"]
    elif selected_set == "Diatonic major higher octave":
        checked_notes = ["do1", "re1", "mi1", "fa1", "so1", "la1", "ti1", "do2"]
    elif selected_set == "Natural minor":
        checked_notes = ["do", "re", "nu", "fa", "so", "ki", "pe", "do1"]
    elif selected_set == "Natural minor lower octave":
        checked_notes = ["do0", "re0", "nu0", "fa0", "so0", "ki0", "pe0", "do"]
    elif selected_set == "Natural minor higher octave":
        checked_notes = ["do1", "re1", "nu1", "fa1", "so1", "ki1", "pe1", "do2"]
    elif selected_set == "Select all":
        checked_notes = list(note_vars.keys())
    elif selected_set == "Select none": 
        checked_notes = []
    elif selected_set == "Pentatonic major":
        checked_notes = ["do", "re", "mi", "so", "la", "do1"]
    elif selected_set == "Pentatonic major lower octave":
        checked_notes = ["do0", "re0", "mi0", "so0", "la0", "do"]
    elif selected_set == "Pentatonic major higher octave":
        checked_notes = ["do1", "re1", "mi1", "so1", "la1", "do2"]
    elif selected_set == "Pentatonic minor":
        checked_notes = ["do", "nu", "fa", "so", "pe", "do1"]
    elif selected_set == "Pentatonic minor lower octave":
        checked_notes = ["do0", "nu0", "fa0", "so0", "pe0", "do"]
    elif selected_set == "Pentatonic minor higher octave":
        checked_notes = ["do1", "nu1", "fa1", "so1", "pe1", "do2"]
    elif selected_set == "Blues major":
        checked_notes = ["do", "re", "nu", "mi", "so", "la", "do1"]
    elif selected_set == "Blues major lower octave":
        checked_notes = ["do0", "re0", "nu0", "mi0", "so0", "la0", "do"]
    elif selected_set == "Blues major higher octave":
        checked_notes = ["do1", "re1", "nu1", "mi1", "so1", "la1", "do2"]
    elif selected_set == "Blues minor":
        checked_notes = ["do", "nu", "fa", "jur", "so", "pe", "do1"]
    elif selected_set == "Blues minor lower octave":
        checked_notes = ["do0", "nu0", "fa0", "jur0", "so0", "pe0", "do"]
    elif selected_set == "Blues minor higher octave":
        checked_notes = ["do1", "nu1", "fa1", "jur1", "so1", "pe1", "do2"]
    else:
        checked_notes = []

    # Update note_vars based on the selected note set
    for note, var in note_vars.items():
        var.set(note in checked_notes)

# Bind the dropdown to the update_note_set function
note_set_dropdown.bind("<<ComboboxSelected>>", update_note_set)

# Initialize the note set to "Default"
update_note_set()

# Buttons
generate_button = tk.Button(root, text="Generate melody", command=generate_melody, font=BIGFONT, bg=BUTTON_COLOR, fg=TEXT_COLOR, underline=0)
generate_button.grid(row=8, column=1, columnspan=2, padx=10, pady=10, sticky="w")
root.bind("g", lambda event: generate_melody())

show_solfege_button = tk.Button(root, text="Show Solfege", command=show_solfege, font=FONT, bg=BUTTON_COLOR, fg=TEXT_COLOR, underline=0)
show_solfege_button.grid(row=9, column=0, padx=10, pady=10, sticky="w")
root.bind("s", lambda event: show_solfege())

play_guitar_tonic_button = tk.Button(root, text="Play Guitar Tonic", command=lambda: play_tonic("Guitar"), font=FONT, bg=BUTTON_COLOR, fg=TEXT_COLOR)
play_guitar_tonic_button.grid(row=10, column=0, padx=10, pady=10, sticky="w")

play_piano_tonic_button = tk.Button(root, text="Play Piano Tonic", command=lambda: play_tonic("Piano"), font=FONT, bg=BUTTON_COLOR, fg=TEXT_COLOR)
play_piano_tonic_button.grid(row=10, column=1, padx=10, pady=10, sticky="w")

play_solfege_tonic_button = tk.Button(root, text="Play Solfege Tonic", command=lambda: play_tonic("Solfege"), font=FONT, bg=BUTTON_COLOR, fg=TEXT_COLOR)
play_solfege_tonic_button.grid(row=10, column=2, padx=10, pady=10, sticky="w")

play_guitar_melody_button = tk.Button(root, text="Play Guitar Melody", command=lambda: play_melody("Guitar"), font=FONT, bg=BUTTON_COLOR, fg=TEXT_COLOR, underline=16)
play_guitar_melody_button.grid(row=11, column=0, padx=10, pady=10, sticky="w")
root.bind("d", lambda event: play_melody("Guitar"))

play_piano_melody_button = tk.Button(root, text="Play Piano Melody", command=lambda: play_melody("Piano"), font=FONT, bg=BUTTON_COLOR, fg=TEXT_COLOR, underline=2)
play_piano_melody_button.grid(row=11, column=1, padx=10, pady=10, sticky="w")
root.bind("a", lambda event: play_melody("Piano"))

play_solfege_melody_button = tk.Button(root, text="Play Solfege Melody", command=lambda: play_melody("Solfege"), font=FONT, bg=BUTTON_COLOR, fg=TEXT_COLOR, underline=8)
play_solfege_melody_button.grid(row=11, column=2, padx=10, pady=10, sticky="w")
root.bind("f", lambda event: play_melody("Solfege"))

# configure columns to have the same width
for i in range(3):
    root.columnconfigure(i, weight=1, uniform="equal_width")

# Run the application
root.mainloop()