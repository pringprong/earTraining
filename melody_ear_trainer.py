#region ############## SETUP ######################

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

# Extract keys and instruments for the dropdowns
mapping_keys = list(Mapping.keys())
mapping_keys.sort()  # Sort the keys for better readability
instruments = set()
for instrument in Mapping.values():
    instruments.update(instrument.keys())
instruments = sorted(instruments)  # Sort the instruments for better readability

# Load Scales.txt into a dictionary named "Note_sets"
scales_file_path = os.path.join(base_path, "mapping", "Scales.txt")
Note_sets = {}
with open(scales_file_path, "r") as file:
    for line in file:
        octave, scale_name, notes = line.strip().split("\t")
        if octave not in Note_sets:
            Note_sets[octave] = {}
        Note_sets[octave][scale_name] = notes.split(",")  # Split notes into a list

# Extract octaves and scales for the dropdowns
octaves = list(Note_sets.keys())
scales = set()
for octave_scales in Note_sets.values():
    scales.update(octave_scales.keys())
scales = sorted(scales)

# Define a global font and colors
FONT = ("Arial", 14, "bold")
FONTLIGHT = ("Arial", 13)
DEACTIVATEDFONT = ("Arial", 8)
BIGFONT = ("Arial", 16, "bold")
BG_COLOR = "#e1eaf7"  # Light blue background
DEACTIVATED_BG_COLOR = "grey"  # Grey background for deactivated buttons
BUTTON_COLOR = "#82aaf4"  # Sky blue for buttons
TEXT_COLOR = "#0c1d43"  # Navy text color

# Create the main window
root = tk.Tk()
root.title("Melody Ear Trainer")
# Apply background color to the root window
root.configure(background=BG_COLOR)
temp_dir = tempfile.gettempdir()  # Get the system's temporary directory

def instrument_temp_file(instrument):
    return os.path.join(temp_dir, f"combined_melody_{instrument}.mp3")

def on_closing():      
    for instrument in instruments:
        combined_file = instrument_temp_file(instrument)
        os.remove(combined_file) if os.path.exists(combined_file) else None
    root.destroy()  # Close the application

root.protocol("WM_DELETE_WINDOW", on_closing)  # Call on_closing when window is closed

def center_window(window):
    window.update_idletasks()
    screen_width = window.winfo_screenwidth()
    screen_height = window.winfo_screenheight()

    # Calculate the x-coordinate for centering horizontally
    x = (screen_width - window.winfo_width()) // 2

    # Set the window position without specifying size
    window.geometry(f"+{x}+0")



#endregion #######################SETUP##############################

#region ############## FRAMES #####################

labelFrameList = ["Settings", "Tonic", "Scales", "Notes", "Melody"]
labelFrames = {}
toggle_buttons = {}
toggle_button_frame = tk.Frame(root, bg=BG_COLOR)
toggle_button_frame.grid(row=0, column=0, padx=10, pady=4, sticky="ew")

for i, lf in enumerate(labelFrameList):
    this_lf = tk.LabelFrame(root, text=lf, font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
    this_lf.grid(row=i+1, column=0, padx=10, pady=4, sticky="ew")
    labelFrames[lf] = this_lf

    # Create a toggle button for the label frame
    toggle_button = tk.Button(toggle_button_frame, text=lf, font=FONT, bg=BUTTON_COLOR, fg=TEXT_COLOR)
    toggle_button.grid(row=0, column=i, padx=10, pady=0, sticky="w")
    toggle_button.configure(command=lambda p=this_lf, b=toggle_button: toggle_settings(p, b))
    toggle_buttons[lf] = toggle_button

# Function to toggle the visibility of the panes
def toggle_settings(pane, button=None):
    if button is not None:
        if button['bg'] == BUTTON_COLOR:
            button.configure(bg=DEACTIVATED_BG_COLOR)
        else:
            button.configure(bg=BUTTON_COLOR)
    if pane.winfo_ismapped():
        pane.grid_remove()  # Hide the pane
    else:
        pane.grid()  # Show the pane

#endregion #######################FRAMES##############################

#region ############## SETTINGS ###################

# Dropdown for "Key"
key_label = tk.Label(labelFrames["Settings"], text="Key of melody:", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
key_label.grid(row=0, column=0, columnspan=2, padx=10, pady=4, sticky="w")
key_dropdown = ttk.Combobox(labelFrames["Settings"], values=mapping_keys, font=FONT, state="readonly", takefocus=True)
key_dropdown.grid(row=0, column=2, padx=10, pady=4, sticky="w")
key_dropdown.current(3)
# Set initial focus
key_dropdown.focus_set()

# Dropdown for "Number of notes"
notes_label = tk.Label(labelFrames["Settings"], text="Number of notes in melody:", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
notes_label.grid(row=1, column=0, columnspan=2, padx=10, pady=4, sticky="w")
notes_dropdown = ttk.Combobox(labelFrames["Settings"], values=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16], font=FONT, state="readonly", takefocus=True)
notes_dropdown.grid(row=1, column=2, padx=10, pady=4, sticky="w")
notes_dropdown.current(5)

# Dropdown for "Maximum distance between notes"
distance_label = tk.Label(labelFrames["Settings"], text="Max distance between adjacent notes:", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
distance_label.grid(row=2, column=0, columnspan=2, padx=10, pady=4, sticky="w")
distance_dropdown = ttk.Combobox(labelFrames["Settings"], values=[1, 2, 3, 4, 5, 6, 7], font=FONT, state="readonly", takefocus=True)
distance_dropdown.grid(row=2, column=2, padx=10, pady=4, sticky="w")
distance_dropdown.current(2)

# Define BooleanVars for checkboxes
start_with_do_var = tk.BooleanVar(value=True)  # Checked by default
end_with_do_var = tk.BooleanVar(value=True)  # Checked by default
allow_repeated_notes_var = tk.BooleanVar(value=False)  # Unchecked by default

allow_repeated_notes = tk.Label(labelFrames["Settings"], text="Allow repeated notes:", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
allow_repeated_notes.grid(row=5, column=0, columnspan=1, padx=10, pady=4, sticky="w")
allow_repeated_notes_checkbox = tk.Checkbutton(labelFrames["Settings"], text="Allow repeated notes", variable=allow_repeated_notes_var, font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
allow_repeated_notes_checkbox.grid(row=5, column=2, padx=10, pady=4, sticky="w")

# Dropdown for instruments selection
instruments_label = tk.Label(labelFrames["Settings"], text="Instrument for playback in Notes:", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
instruments_label.grid(row=6, column=0, columnspan=2, padx=10, pady=4, sticky="w")
instruments_dropdown = ttk.Combobox(labelFrames["Settings"], values=instruments, font=FONT, state="readonly", takefocus=True)
instruments_dropdown.grid(row=6, column=2, padx=10, pady=4, sticky="w")
instruments_dropdown.current(0)  # Set the first instrument as the default

#endregion #################### SETTINGS ##############################

#region ############## TONIC #################################

# Checkboxes for "Start with do" and "End with do"
start_with_do_label = tk.Label(labelFrames["Tonic"], text="Starting note (tonic):", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
start_with_do_label.grid(row=3, column=0, columnspan=1, padx=10, pady=4, sticky="w")
start_with_do_checkbox = tk.Checkbutton(labelFrames["Tonic"], text="Always start with", variable=start_with_do_var, font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
start_with_do_checkbox.grid(row=3, column=1, padx=10, pady=4, sticky="w")
start_with_do_dropdown = ttk.Combobox(labelFrames["Tonic"], values=["do0", "la0", "do", "la", "do1", "la1", "do2"], font=FONT, state="readonly", takefocus=True)
start_with_do_dropdown.grid(row=3, column=2, padx=10, pady=4, sticky="w")
start_with_do_dropdown.current(2)

end_with_do_label = tk.Label(labelFrames["Tonic"], text="Ending note:", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
end_with_do_label.grid(row=4, column=0, columnspan=1, padx=10, pady=4, sticky="w")
end_with_do_checkbox = tk.Checkbutton(labelFrames["Tonic"], text="Always end with", variable=end_with_do_var, font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
end_with_do_checkbox.grid(row=4, column=1, padx=10, pady=4, sticky="w")
end_with_do_dropdown = ttk.Combobox(labelFrames["Tonic"], values=["do0", "la0", "do", "la", "do1", "la1", "do2"], font=FONT, state="readonly", takefocus=True)
end_with_do_dropdown.grid(row=4, column=2, padx=10, pady=4, sticky="w")
end_with_do_dropdown.current(2)

play_guitar_tonic_button = tk.Button(labelFrames["Tonic"], text="Play Guitar Tonic", command=lambda: play_tonic("Guitar"), font=FONT, bg=BUTTON_COLOR, fg=TEXT_COLOR)
play_guitar_tonic_button.grid(row=10, column=0, padx=10, pady=4, sticky="w")

play_piano_tonic_button = tk.Button(labelFrames["Tonic"], text="Play Piano Tonic", command=lambda: play_tonic("Piano"), font=FONT, bg=BUTTON_COLOR, fg=TEXT_COLOR)
play_piano_tonic_button.grid(row=10, column=1, padx=10, pady=4, sticky="w")

play_solfege_tonic_button = tk.Button(labelFrames["Tonic"], text="Play Solfege Tonic", command=lambda: play_tonic("Solfege"), font=FONT, bg=BUTTON_COLOR, fg=TEXT_COLOR)
play_solfege_tonic_button.grid(row=10, column=2, padx=10, pady=4, sticky="w")

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

#endregion ############## TONIC ##########################33

#region ############## NOTES ######################

# initialize set of notes
note_vars = {}
notes = [
    "do0", "ga0", "re0", "nu0", "mi0", "fa0", "jur0", "so0", "ki0", "la0", "pe0", "ti0",
    "do", "ga", "re", "nu", "mi", "fa", "jur", "so", "ki", "la", "pe", "ti",
    "do1", "ga1", "re1", "nu1", "mi1", "fa1", "jur1", "so1", "ki1", "la1", "pe1", "ti1",
    "do2"
]
# Initialize note_vars with BooleanVar for each note
note_vars = {note: tk.BooleanVar(value=False) for note in notes}

# Function to toggle the state of a note button
def toggle_note_state(note, button):
    if note_vars[note].get():  # If the note is currently active
        note_vars[note].set(False)  # Set it to inactive
        button.config(bg=DEACTIVATED_BG_COLOR, font=DEACTIVATEDFONT)  # Change the button color to grey
    else:  # If the note is currently inactive
        note_vars[note].set(True)  # Set it to active
        button.config(bg=BUTTON_COLOR, font=FONT)  # Change the button color to active color

# Function to play a single note when an active button is left-clicked
def play_single_note(note):
    if note_vars[note].get():  # Only play if the note is active
        key = key_dropdown.get()
        file_to_play = Mapping[key][instruments_dropdown.get()][note]
        # Split file_to_play into folder and filename
        folder, filename = os.path.split(file_to_play)
        # Reassemble the path using base_path
        full_path = os.path.join(base_path, folder, filename)
        # Play the file
        play = threading.Thread(target=playsound, args=(full_path,))
        play.start()

# Dictionary to store references to the buttons
note_buttons = {}
for i, note in enumerate(notes):
    # Create a button for each note
    button = tk.Button(
        labelFrames["Notes"],
        text=note,
        #font=FONTLIGHT if note in ["ga0", "nu0", "jur0", "ki0", "pe0", "ga", "nu", "jur", "ki", "pe", "ga1", "nu1", "jur1", "ki1", "pe1"] else FONT,
        font=DEACTIVATEDFONT,
        bg=DEACTIVATED_BG_COLOR,  # Default to inactive color
        fg=TEXT_COLOR,
        height=1,
        width=3,
        command=lambda n=note: play_single_note(n)  # Left-click plays the note if active
    )
    button.grid(row=i // 12, column=i % 12, padx=4, pady=4)
    # Bind right-click to toggle the state of the button
    button.bind("<Button-3>", lambda event, n=note, b=button: toggle_note_state(n, b))
    # Store the button reference in the dictionary
    note_buttons[note] = button

#endregion #################### NOTES ##############################

#region ############## SCALES ######################

# Add "Octave" dropdown to the Scales frame
octave_label = tk.Label(labelFrames["Scales"], text="Octave:", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
octave_label.grid(row=5, column=0, columnspan=1, padx=10, pady=4, sticky="w")
octave_dropdown = ttk.Combobox(labelFrames["Scales"], values=octaves, font=FONT, state="readonly", takefocus=True)
octave_dropdown.grid(row=5, column=2, padx=10, pady=4, sticky="w")
octave_dropdown.current(2)  # Set the first octave as the default

# Update the "Note set" dropdown to use scales from Scales.txt
note_set_label = tk.Label(labelFrames["Scales"], text="Scale:", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
note_set_label.grid(row=6, column=0, columnspan=1, padx=10, pady=4, sticky="w")
note_set_dropdown = ttk.Combobox(labelFrames["Scales"], values=scales, font=FONT, state="readonly", takefocus=True)
note_set_dropdown.grid(row=6, column=2, padx=10, pady=4, sticky="w")
note_set_dropdown.current(3)  

# Update the "update_note_set" function to use the selected octave and scale
def update_note_set(event=None):
    selected_octave = octave_dropdown.get()
    selected_scale = note_set_dropdown.get()

    # Get the notes for the selected octave and scale
    if selected_octave in Note_sets and selected_scale in Note_sets[selected_octave]:
        checked_notes = Note_sets[selected_octave][selected_scale]
    else:
        checked_notes = []

    # Update note_vars based on the selected notes
    for note, var in note_vars.items():
        var.set(note in checked_notes)
    
    # Update the button states based on note_vars
    for note, button in note_buttons.items():
        if note_vars[note].get():
            button.config(bg=BUTTON_COLOR, font=FONT)  # Active state
        else:
            button.config(bg=DEACTIVATED_BG_COLOR, font=DEACTIVATEDFONT)  # Inactive state

# Bind the dropdowns to the update_note_set function
octave_dropdown.bind("<<ComboboxSelected>>", update_note_set)
note_set_dropdown.bind("<<ComboboxSelected>>", update_note_set)

# Initialize the note set to the default values
update_note_set()

#endregion ############################ SCALES ##############################

#region ############## MELODY ######################

# Functionality
Melody = []

def generate_melody():
    # Clear previous melody and files
    solfege_text.config(state="normal")  # Enable editing temporarily
    solfege_text.delete("1.0", tk.END)  # Clear the text box
    solfege_text.config(state="disabled")  # Disable editing again  
    
    # delete previous combined files
    for instrument in instruments:
        combined_file = instrument_temp_file(instrument)
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
        combined_file = instrument_temp_file(instrument)
        combined.export(combined_file, format="mp3")     

def show_solfege():
    solfege_text.config(state="normal")  # Enable editing temporarily
    solfege_text.delete("1.0", tk.END)  # Clear the text box
    solfege_text.insert(tk.END, " ".join(Melody))  # Insert the melody
    solfege_text.config(state="disabled")  # Disable editing again    

def play_melody(instrument):
 
    # Path to the pre-generated combined MP3 for the selected instrument
    combined_file = instrument_temp_file(instrument)   
    # Play the file
    play = threading.Thread(target=playsound, args=(combined_file,))
    play.start()

# Buttons for the Melody frame
generate_button = tk.Button(labelFrames["Melody"], text="Generate melody", command=generate_melody, font=BIGFONT, bg=BUTTON_COLOR, fg=TEXT_COLOR, underline=0)
generate_button.grid(row=8, column=1, columnspan=1, padx=5, pady=4, sticky="w")
root.bind("g", lambda event: generate_melody())

# Text area for "Solfege"
# First create a frame so that we can put the button and the text area closer together
solfege_frame = tk.Frame(labelFrames["Melody"], bg=BG_COLOR)
solfege_frame.grid(row=9, column=0, columnspan=3, padx=0, pady=0, sticky="w")

show_solfege_button = tk.Button(solfege_frame, text="Show Solfege", command=show_solfege, font=FONT, bg=BUTTON_COLOR, fg=TEXT_COLOR, underline=0)
show_solfege_button.grid(row=0, column=0, padx=5, pady=4, sticky="w")
root.bind("s", lambda event: show_solfege())

solfege_text = tk.Text(solfege_frame, font=FONTLIGHT, height=1, width=56, bg="white", fg=TEXT_COLOR, takefocus=False, state="disabled")
solfege_text.grid(row=0, column=1, columnspan=1, padx=5, pady=4, sticky="w")

play_guitar_melody_button = tk.Button(labelFrames["Melody"], text="Play Guitar Melody", command=lambda: play_melody("Guitar"), font=FONT, bg=BUTTON_COLOR, fg=TEXT_COLOR, underline=16)
play_guitar_melody_button.grid(row=11, column=0, padx=5, pady=4, sticky="w")
root.bind("d", lambda event: play_melody("Guitar"))

play_piano_melody_button = tk.Button(labelFrames["Melody"], text="Play Piano Melody", command=lambda: play_melody("Piano"), font=FONT, bg=BUTTON_COLOR, fg=TEXT_COLOR, underline=2)
play_piano_melody_button.grid(row=11, column=1, padx=5, pady=4, sticky="w")
root.bind("a", lambda event: play_melody("Piano"))

play_solfege_melody_button = tk.Button(labelFrames["Melody"], text="Play Solfege Melody", command=lambda: play_melody("Solfege"), font=FONT, bg=BUTTON_COLOR, fg=TEXT_COLOR, underline=8)
play_solfege_melody_button.grid(row=11, column=2, padx=5, pady=4, sticky="w")
root.bind("f", lambda event: play_melody("Solfege"))

# configure columns to have the same width
for i in range(3):
    labelFrames["Melody"].columnconfigure(i, weight=1, uniform="equal_width")

#endregion ################ MELODY ##############################

# Run the application
center_window(root)
root.mainloop()