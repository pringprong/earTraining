#region ############## TOOLTIP ####################

import tkinter as tk
from tkinter import ttk, scrolledtext
import random
from playsound import playsound
from pydub import AudioSegment
from pydub.playback import play

import os
import threading
import sys
import tempfile  # Import the tempfile module
import tkinter.messagebox  # Import the messagebox module

class Tooltip:
    def __init__(self, widget, text):
        self.widget = widget
        self.text = text
        self.tooltip_window = None
        self.widget.bind("<Enter>", self.show_tooltip)
        self.widget.bind("<Leave>", self.hide_tooltip)

    def show_tooltip(self, event=None):
        x, y, _, _ = self.widget.bbox("insert")
        x += self.widget.winfo_rootx() + 25
        y += self.widget.winfo_rooty() + 25

        self.tooltip_window = tk.Toplevel(self.widget)
        self.tooltip_window.wm_overrideredirect(True)  # Remove window decorations
        self.tooltip_window.wm_geometry(f"+{x}+{y}")
        label = tk.Label(self.tooltip_window, text=self.text, background="#FFFFE0", relief="solid", borderwidth=1)
        label.pack()

    def hide_tooltip(self, event=None):
        if self.tooltip_window:
            self.tooltip_window.destroy()
            self.tooltip_window = None

#endregion ########### TOOLTIP

#region ############## FONTS & COLORS ###############

def multiply_hex_color(hex_color, factor):
    """Multiplies a hex color by a factor.

    Args:
        hex_color: The hex color string (e.g., "#RRGGBB").
        factor: The multiplication factor (a float or integer).

    Returns:
        The multiplied hex color string.
    """
    if (factor == 1):
        return hex_color
    hex_color = hex_color.lstrip("#")
    r = int(hex_color[0:2], 16)
    g = int(hex_color[2:4], 16)
    b = int(hex_color[4:6], 16)

    new_r = int(r * factor)
    new_g = int(g * factor)
    new_b = int(b * factor)

    new_r = min(255, max(0, new_r))
    new_g = min(255, max(0, new_g))
    new_b = min(255, max(0, new_b))

    return "#{:02x}{:02x}{:02x}".format(new_r, new_g, new_b)

# Define a global font and colors
FONT = ("Arial", 12, "bold")
FONTLIGHT = ("Arial", 13)
DEACTIVATEDFONT = ("Arial", 8)
BIGFONT = ("Arial", 16, "bold")
BG_COLOR = multiply_hex_color("#98a59c", 1.6)  # Light blue background
DEACTIVATED_BG_COLOR = "#b8c7b2"  # Grey background for deactivated buttons
BUTTON_COLOR = "#84b6d4"  # Sky blue for buttons
TEXT_COLOR = "#34341d"  # 

COLOR1 = "#8189d3" # dark blue green
COLOR2 = "#89afaa"  # brown
COLOR3 = "#bcae9a"  # blue
COLOR4 = "#c3b2b7"  # brtck red
COLOR5 = "#d0a89b"  # dusty purple

FACTOR1 = 0.85  # Darker color factor
FACTOR2 = 1  #  color factor
FACTOR3 = 1.15  #  color factor
FACTOR4 = 1.3  # Lightest color factor
FACTOR5 = 1.45  # Lightest color factor

def get_chord_button_color(chord_name):
    color = BUTTON_COLOR
    if chord_name.endswith("_VL_R"):
        color = multiply_hex_color(COLOR1, FACTOR1)
    elif chord_name.endswith("_L_R"):
        color = multiply_hex_color(COLOR1, FACTOR2)
    elif chord_name.endswith("_M_R"):
        color = multiply_hex_color(COLOR1, FACTOR3)
    elif chord_name.endswith("_H_R"):
        color = multiply_hex_color(COLOR1, FACTOR4)
    elif chord_name.endswith("_VL_1i"):
        color = multiply_hex_color(COLOR2, FACTOR1)
    elif chord_name.endswith("_L_1i"):
        color = multiply_hex_color(COLOR2, FACTOR2)
    elif chord_name.endswith("_M_1i"):
        color = multiply_hex_color(COLOR2, FACTOR3)
    elif chord_name.endswith("_H_1i"):
        color = multiply_hex_color(COLOR2, FACTOR4)
    elif chord_name.endswith("_VL_2i"):
        color = multiply_hex_color(COLOR3, FACTOR1)
    elif chord_name.endswith("_L_2i"):
        color = multiply_hex_color(COLOR3, FACTOR2)
    elif chord_name.endswith("_M_2i"):
        color = multiply_hex_color(COLOR3, FACTOR3)
    elif chord_name.endswith("_H_2i"):
        color = multiply_hex_color(COLOR3, FACTOR4)
    elif chord_name.endswith("_VL_3i"):
        color = multiply_hex_color(COLOR4, FACTOR1)
    elif chord_name.endswith("_L_3i"):
        color = multiply_hex_color(COLOR4, FACTOR2)
    elif chord_name.endswith("_M_3i"):
        color = multiply_hex_color(COLOR4, FACTOR3)
    elif chord_name.endswith("_H_3i"):
        color = multiply_hex_color(COLOR4, FACTOR4)
    elif chord_name.endswith("_All"):
        color = multiply_hex_color(COLOR5, FACTOR2)
    return color

#endregion ########### FONTS & COLORS ###############

#region ############## SETUP ######################

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

# Load Chords.txt into a dictionary named "Chords"
chords_file_path = os.path.join(base_path, "mapping", "Chords.txt")
Chords = {}
Chord_lookup = {}
chord_names = []  # List to store chord names in the same order as in the file
chord_button_tooltips = {}
with open(chords_file_path, "r") as file:
    for line in file:
        scale, chord_number, chord_name, notes = line.strip().split("\t")
        if scale not in Chords:
            Chords[scale] = {}
        if chord_number not in Chords[scale]:
            Chords[scale][chord_number] = {}
        Chords[scale][chord_number][chord_name] = notes.split(",")  # Split notes into a list
        chord_names.append(chord_name)  # Keep track of chord names in order
        Chord_lookup[chord_name] = notes.split(",")  # Store the chord name and its notes

# Load ChordSets.txt into a dictionary named "Chord_sets"
chordsets_file_path = os.path.join(base_path, "mapping", "ChordSets.txt")
Chord_sets = {}
with open(chordsets_file_path, "r") as file:
    for line in file:
        octave, chordset_name, chords = line.strip().split("\t")
        if octave not in Chord_sets:
            Chord_sets[octave] = {}
        Chord_sets[octave][chordset_name] = chords.split(",")  # Split notes into a list

# Extract octaves and scales for the dropdowns
chordset_octaves = list(Chord_sets.keys())
chordsets = set()
for thingy in Chord_sets.values():
    chordsets.update(thingy.keys())
chordsets = sorted(chordsets)

# global variable Melody to store the generated melody
Melody = []
melody_text = []

# Create the main window
root = tk.Tk()
root.title("Melody Ear Trainer")
# Apply background color to the root window
root.configure(background=BG_COLOR)
temp_dir = tempfile.gettempdir()  # Get the system's temporary directory

def instrument_temp_file(instrument):
    return os.path.join(temp_dir, f"combined_melody_{instrument}.mp3")

# this is to ensure that we always use the os.path method to get the mp3 from the filename
def get_mp3(file_to_play):
    folder, filename = os.path.split(file_to_play)   
    full_path = os.path.join(base_path, folder, filename)
    return AudioSegment.from_mp3(full_path)

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

# initialize set of notes
note_vars = {}
# we have to load these as a hard-coded list to ensure that they stay in the right order.
notes = [
    "do0", "ga0", "re0", "nu0", "mi0", "fa0", "jur0", "so0", "ki0", "la0", "pe0", "ti0",
    "do", "ga", "re", "nu", "mi", "fa", "jur", "so", "ki", "la", "pe", "ti",
    "do1", "ga1", "re1", "nu1", "mi1", "fa1", "jur1", "so1", "ki1", "la1", "pe1", "ti1",
    "do2"
]
# Initialize note_vars with BooleanVar for each note
note_vars = {note: tk.BooleanVar(value=False) for note in notes}
# Initialize BooleanVars for each chord
chord_vars = {chord_name: tk.BooleanVar(value=True) for chord_name in chord_names}

#endregion #######################SETUP##############################

#region ############## FRAMES #####################

labelFrameList = ["Settings", "Tonic", "Scales", "Notes", "Chord Settings", "Chord Sets", "Major Scale Chords", "Minor Scale Chords", "Other Chords", "Melody"]
hidden_frames = ["Settings", "Tonic", "Scales", "Chord Settings", "Major Scale Chords", "Minor Scale Chords", "Other Chords"]  # Frames to be hidden initially

labelFrames = {}
toggle_buttons = {}
toggle_button_frame = tk.Frame(root, bg=BG_COLOR)
toggle_button_frame.grid(row=0, column=0, padx=10, pady=4, sticky="ew")
toggle_button_tooltips = {}

for i, lf in enumerate(labelFrameList):
    this_lf = tk.LabelFrame(root, text=lf, font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
    this_lf.grid(row=i+1, column=0, padx=10, pady=4, sticky="ew")
    labelFrames[lf] = this_lf

    # Create a toggle button for the label frame
    toggle_button = tk.Button(toggle_button_frame, text=lf, font=FONT, bg=BUTTON_COLOR, fg=TEXT_COLOR)
    toggle_button.grid(row=0, column=i, padx=5, pady=0, sticky="w")
    toggle_button.configure(command=lambda p=this_lf, b=toggle_button: toggle_settings(p, b))
    toggle_buttons[lf] = toggle_button
    toggle_button_tooltips[lf] = Tooltip(toggle_button, f"Show or hide {lf} section")

    if lf in hidden_frames:
        this_lf.grid_remove()
        toggle_button.configure(bg=DEACTIVATED_BG_COLOR, font=DEACTIVATEDFONT)

# Function to toggle the visibility of the panes
def toggle_settings(pane, button=None):
    if button is not None:
        if button['bg'] == BUTTON_COLOR:
            button.config(bg=DEACTIVATED_BG_COLOR, font=DEACTIVATEDFONT)  # Change the button color to grey
        else:
            button.config(bg=BUTTON_COLOR, font=FONT)
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
key_dropdown_tooltip = Tooltip(key_dropdown, "The note \"do\" will be set to the key of the melody. E is the lowest key.")

# Dropdown for "Number of notes"
notes_label = tk.Label(labelFrames["Settings"], text="Number of notes in melody:", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
notes_label.grid(row=1, column=0, columnspan=2, padx=10, pady=4, sticky="w")
notes_dropdown = ttk.Combobox(labelFrames["Settings"], values=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], font=FONT, state="readonly", takefocus=True)
notes_dropdown.grid(row=1, column=2, padx=10, pady=4, sticky="w")
notes_dropdown.current(5)

# Dropdown for "Maximum distance between notes"
distance_label = tk.Label(labelFrames["Settings"], text="Max distance between adjacent notes:", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
distance_label.grid(row=2, column=0, columnspan=2, padx=10, pady=4, sticky="w")
distance_dropdown = ttk.Combobox(labelFrames["Settings"], values=[1, 2, 3, 4, 5, 6, 7], font=FONT, state="readonly", takefocus=True)
distance_dropdown.grid(row=2, column=2, padx=10, pady=4, sticky="w")
distance_dropdown.current(6)

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
instruments_dropdown.current(1)  

# Dropdown for time between notes selection
melody_offset_label = tk.Label(labelFrames["Settings"], text="Time between notes in melody (ms):", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
melody_offset_label.grid(row=7, column=0, columnspan=2, padx=10, pady=4, sticky="w")
melody_offset_dropdown = ttk.Combobox(labelFrames["Settings"], values=[300, 600, 900, 1200], font=FONT, state="readonly", takefocus=True)
melody_offset_dropdown.grid(row=7, column=2, padx=10, pady=4, sticky="w")
melody_offset_dropdown.current(2)  

# Dropdown for time between notes selection
truncate_label = tk.Label(labelFrames["Settings"], text="Truncate notes in melody (ms):", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
truncate_label.grid(row=8, column=0, columnspan=2, padx=10, pady=4, sticky="w")
truncate_dropdown = ttk.Combobox(labelFrames["Settings"], values=["None", 600, 900, 1200, 1500, 1800], font=FONT, state="readonly", takefocus=True)
truncate_dropdown.grid(row=8, column=2, padx=10, pady=4, sticky="w")
truncate_dropdown.current(3) 

# this didn't work because the overall window was still bright
#dark_mode_checkbox = tk.Checkbutton(labelFrames["Settings"], text="Dark mode", variable=dark_mode_var, font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
#dark_mode_checkbox.grid(row=9, column=2, padx=10, pady=4, sticky="w")

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

play_guitar_tonic_button = tk.Button(labelFrames["Tonic"], text="Play Guitar Tonic", 
                                     command=lambda: play_single_note("Guitar", start_with_do_dropdown.get(), True), 
                                     font=FONT, bg=BUTTON_COLOR, fg=TEXT_COLOR)
play_guitar_tonic_button.grid(row=10, column=0, padx=10, pady=4, sticky="w")

play_piano_tonic_button = tk.Button(labelFrames["Tonic"], text="Play Piano Tonic", 
                                    command=lambda: play_single_note("Piano", start_with_do_dropdown.get(), True), 
                                    font=FONT, bg=BUTTON_COLOR, fg=TEXT_COLOR)
play_piano_tonic_button.grid(row=10, column=1, padx=10, pady=4, sticky="w")

play_solfege_tonic_button = tk.Button(labelFrames["Tonic"], text="Play Solfege Tonic", 
                                      command=lambda: play_single_note("Solfege", start_with_do_dropdown.get(), True), 
                                      font=FONT, bg=BUTTON_COLOR, fg=TEXT_COLOR)
play_solfege_tonic_button.grid(row=10, column=2, padx=10, pady=4, sticky="w")

# Function to play a single note when an active button is left-clicked, or when the play tonic buttons are clicked
def play_single_note(instrument, note, should_play):
    if (should_play):
        key = key_dropdown.get()
        file_to_play = Mapping[key][instrument][note]
        folder, filename = os.path.split(file_to_play)
        full_path = os.path.join(base_path, folder, filename)
        play = threading.Thread(target=playsound, args=(full_path,))
        play.start()

#endregion ############## TONIC ##########################33

#region ############## NOTES ######################

# Function to toggle the state of a note button
def toggle_note_state(note, button):
    if note_vars[note].get():  # If the note is currently active
        note_vars[note].set(False)  # Set it to inactive
        button.config(bg=DEACTIVATED_BG_COLOR, font=DEACTIVATEDFONT)  # Change the button color to grey
    else:  # If the note is currently inactive
        note_vars[note].set(True)  # Set it to active
        button.config(bg=BUTTON_COLOR, font=FONT)  # Change the button color to active color

# Dictionary to store references to the buttons
note_buttons = {}
for i, note in enumerate(notes):
    # Create a button for each note
    button = tk.Button(
        labelFrames["Notes"],
        text=note,
        font=DEACTIVATEDFONT,
        bg=DEACTIVATED_BG_COLOR,  # Default to inactive color
        fg=TEXT_COLOR,
        height=1,
        width=3,
    )
    button.grid(row=i // 12, column=i % 12, padx=4, pady=4)
    button.configure(command=lambda n=note: play_single_note(instruments_dropdown.get(), n, note_vars[n].get()))  # Left-click plays the note
    # Bind right-click to toggle the state of the button
    button.bind("<Button-3>", lambda event, n=note, b=button: toggle_note_state(n, b))
    # Store the button reference in the dictionary
    note_buttons[note] = button

#endregion #################### NOTES ##############################

#region ############## CHORD SETTINGS ######################

# Dropdown for "Maximum chord_frequency between notes"
chord_frequency_label = tk.Label(labelFrames["Chord Settings"], text="Chord frequency:", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
chord_frequency_label.grid(row=2, column=0, columnspan=2, padx=10, pady=4, sticky="w")
chord_frequency_dropdown = ttk.Combobox(labelFrames["Chord Settings"], values=["Never", "Every 4 notes", "Every 3 notes", "Every 2 notes", "Every note"], font=FONT, state="readonly", takefocus=True)
chord_frequency_dropdown.grid(row=2, column=2, padx=10, pady=4, sticky="w")
chord_frequency_dropdown.current(2)

allow_repeated_chords_var = tk.BooleanVar(value=False)  # Unchecked by default
allow_repeated_chords = tk.Label(labelFrames["Chord Settings"], text="Allow repeated chords:", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
allow_repeated_chords.grid(row=5, column=0, columnspan=1, padx=10, pady=4, sticky="w")
allow_repeated_chords_checkbox = tk.Checkbutton(labelFrames["Chord Settings"], text="Allow repeated chords", variable=allow_repeated_chords_var, font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
allow_repeated_chords_checkbox.grid(row=5, column=2, padx=10, pady=4, sticky="w")

arpeggiate_chords_var = tk.BooleanVar(value=True)  # Unchecked by default
arpeggiate_chords = tk.Label(labelFrames["Chord Settings"], text="Arpeggiate chords:", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
arpeggiate_chords.grid(row=6, column=0, columnspan=1, padx=10, pady=4, sticky="w")
arpeggiate_checkbox = tk.Checkbutton(labelFrames["Chord Settings"], text="Arpeggiate chords", variable=arpeggiate_chords_var, font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
arpeggiate_checkbox.grid(row=6, column=2, padx=10, pady=4, sticky="w")

arpeggiate_chord_delay_label = tk.Label(labelFrames["Chord Settings"], text="Arpeggiate chord delay (ms):", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
arpeggiate_chord_delay_label.grid(row=7, column=0, columnspan=2, padx=10, pady=4, sticky="w")
arpeggiate_chord_delay_dropdown = ttk.Combobox(labelFrames["Chord Settings"], values=[50,  100, 200, 300, 400, 500], font=FONT, state="readonly", takefocus=True)
arpeggiate_chord_delay_dropdown.grid(row=7, column=2, padx=10, pady=4, sticky="w")
arpeggiate_chord_delay_dropdown.current(1)  # Set the first option as the default

# Dropdown for arpeggiate chord note order
arpeggiate_chord_note_order_label = tk.Label(labelFrames["Chord Settings"], text="Arpeggiate chord note order:", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
arpeggiate_chord_note_order_label.grid(row=8, column=0, columnspan=2, padx=10, pady=4, sticky="w")
arpeggiate_chord_note_order_dropdown = ttk.Combobox(labelFrames["Chord Settings"], values=["Ascending", "Descending", "Random"], font=FONT, state="readonly", takefocus=True)
arpeggiate_chord_note_order_dropdown.grid(row=8, column=2, padx=10, pady=4, sticky="w")
arpeggiate_chord_note_order_dropdown.current(0)  # Set the first option as the default
# Dropdown for harmonic vs arpeggiated chords

display_chord_notes_chords_var = tk.BooleanVar(value=False)  # Unchecked by default
display_chord_notes_chords = tk.Label(labelFrames["Chord Settings"], text="Display chord notes in Solfege text section:", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
display_chord_notes_chords.grid(row=5, column=0, columnspan=1, padx=10, pady=4, sticky="w")
display_chord_notes_chords_checkbox = tk.Checkbutton(labelFrames["Chord Settings"], text="Display individual notes", variable=display_chord_notes_chords_var, font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
display_chord_notes_chords_checkbox.grid(row=5, column=2, padx=10, pady=4, sticky="w")


#endregion #################### CHORD SETTINGS ##############################

#region ############## CHORDS ######################

def toggle_chord_state(chord_name, button):
    if chord_vars[chord_name].get():  # If the chord is currently active
        chord_vars[chord_name].set(False)  # Set it to inactive
        button.config(bg=DEACTIVATED_BG_COLOR, font=DEACTIVATEDFONT)  # Change the button color to grey
    else:  # If the chord is currently inactive
        chord_vars[chord_name].set(True)  # Set it to active
        button.config(bg=get_chord_button_color(chord_name), font=FONT)  # Change the button color to active color

def playchord(chord_notes_original):
    chord_file = os.path.join(temp_dir, "chord.mp3")
    os.remove(chord_file) if os.path.exists(chord_file) else None
    chord_notes = chord_notes_original.copy()  # Create a copy of the chord notes

    if arpeggiate_chord_note_order_dropdown.get() == "Descending":
        chord_notes.reverse()
    elif arpeggiate_chord_note_order_dropdown.get() == "Random":
        random.shuffle(chord_notes)

    instrument = instruments_dropdown.get()
    chord_length = len(chord_notes)

    if arpeggiate_chords_var.get():
        # Play the notes in the specified order with a delay
        last_note= get_mp3(Mapping[key_dropdown.get()][instrument][chord_notes[-1]])
        length_of_last_note = len(last_note) if last_note else 0
        offset = int(arpeggiate_chord_delay_dropdown.get())
        truncate = False
        if (truncate_dropdown.get() != "None"):
            truncate = True
            truncation = int(truncate_dropdown.get())
            length_of_last_note = min(length_of_last_note, truncation)
        # the total length of the chord in ms is the number of notes substract 1
        # times the time between notes plus the time of the last note
        chord_length_ms = ((chord_length - 1) * offset) + length_of_last_note
        sound = AudioSegment.silent(duration=chord_length_ms) 
        # Combine MP3s for all instruments
        for i, note in enumerate(chord_notes):
            this_offset = offset * i
            new_sound = get_mp3(Mapping[key_dropdown.get()][instrument][note])
            if (truncate):
                new_sound = new_sound.fade(to_gain=-120, start=truncation, duration=200)
            sound = sound.overlay(new_sound, position = this_offset)
    else :       
        sound = get_mp3(Mapping[key_dropdown.get()][instrument][chord_notes[0]])
        length_of_first_note = len(sound) if sound else 0
        truncate = False
        if (truncate_dropdown.get() != "None"):
            truncate = True
            truncation = int(truncate_dropdown.get())
            length_of_last_note = truncation
            sound = sound.fade(to_gain=-120, start=truncation-200, duration=200)
        for note in chord_notes[1:]:
            next_note = get_mp3(Mapping[key_dropdown.get()][instruments_dropdown.get()][note])
            if (truncate):
                next_note = next_note.fade(to_gain=-120, start=truncation-200, duration=200)
            sound = sound.overlay(next_note)
    sound.export(chord_file, format="mp3")   
    play = threading.Thread(target=playsound, args=(chord_file,))
    play.start()

# Create buttons for chords in the Chords LabelFrame
chord_buttons = {}
column = 0
row = 0
for scale, chord_numbers in Chords.items():
    if (scale == "Major"):
        frame_name = "Major Scale Chords"
    elif (scale == "Minor"):
        frame_name = "Minor Scale Chords"
    else: 
        frame_name = "Other Chords"
    for chord_number, chords in chord_numbers.items():
        for chord_name, notes in chords.items():
            # Create a button for each chord
            button = tk.Button(
                labelFrames[frame_name],
                text=chord_name,
                font=FONT,
                bg=get_chord_button_color(chord_name),
                fg=TEXT_COLOR,
                height=1,
                width=8,
                command=lambda n=notes: playchord(n)  # Left-click plays the chord
            )
            button.grid(row=row, column=column, padx=4, pady=4, sticky="w")
            chord_button_tooltips[chord_name] = Tooltip(button, notes)

            # Bind right-click to toggle the state of the button
            button.bind("<Button-3>", lambda event, n=chord_name, b=button: toggle_chord_state(n, b))

            # Store the button reference in the dictionary
            chord_buttons[chord_name] = button
            column += 1
        row += 1
        column = 0

#endregion #################### CHORDS ##############################

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

#region ############## CHORD SETS ######################

# Add "Octave" dropdown to the Chord Sets frame
chordset_octave_label = tk.Label(labelFrames["Chord Sets"], text="Range:", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
chordset_octave_label.grid(row=5, column=0, columnspan=1, padx=10, pady=4, sticky="w")
chordset_octave_dropdown = ttk.Combobox(labelFrames["Chord Sets"], values=chordset_octaves, font=FONT, state="readonly", takefocus=True)
chordset_octave_dropdown.grid(row=5, column=2, padx=10, pady=4, sticky="w")
chordset_octave_dropdown.current(0)  # Set the first octave as the default

# Update the "Note set" dropdown to use scales from Chord Sets.txt
chord_set_label = tk.Label(labelFrames["Chord Sets"], text="Set:", font=FONT, bg=BG_COLOR, fg=TEXT_COLOR)
chord_set_label.grid(row=6, column=0, columnspan=1, padx=10, pady=4, sticky="w")
chord_set_dropdown = ttk.Combobox(labelFrames["Chord Sets"], values=chordsets, font=FONT, state="readonly", takefocus=True)
chord_set_dropdown.grid(row=6, column=2, padx=10, pady=4, sticky="w")
chord_set_dropdown.current(0)  

# Update the "update_chord_set" function to use the selected octave and scale
def update_chord_set(event=None):
    selected_octave = chordset_octave_dropdown.get()
    selected_scale = chord_set_dropdown.get()

    # Get the notes for the selected octave and scale
    if selected_scale == "Select all":
        checked_chords = chord_names
    elif selected_octave in Chord_sets and selected_scale in Chord_sets[selected_octave]:
        checked_chords = Chord_sets[selected_octave][selected_scale]
    else:
        checked_chords = []

    # Update note_vars based on the selected notes
    for chord, var in chord_vars.items():
        var.set(chord in checked_chords)
    
    # Update the button states based on note_vars
    for chord, button in chord_buttons.items():
        if chord_vars[chord].get():
            button.config(bg=get_chord_button_color(chord), font=FONT)  # Active state
        else:
            button.config(bg=DEACTIVATED_BG_COLOR, font=DEACTIVATEDFONT)  # Inactive state

# Bind the dropdowns to the update_chord_set function
chordset_octave_dropdown.bind("<<ComboboxSelected>>", update_chord_set)
chord_set_dropdown.bind("<<ComboboxSelected>>", update_chord_set)

# Initialize the note set to the default values
update_chord_set()

#endregion ############################ CHORD SETS ##############################

#region ############## MELODY ######################

def generate_chord_melody():
    # Clear previous melody and files
    solfege_text.config(state="normal")  # Enable editing temporarily
    solfege_text.delete("1.0", tk.END)  # Clear the text box
    solfege_text.config(state="disabled")  # Disable editing again  
    global Melody
    Melody = []  # Clear the melody list
    global melody_text
    melody_text = []

    for instrument in instruments:
        combined_file = instrument_temp_file(instrument)
        os.remove(combined_file) if os.path.exists(combined_file) else None

    # Get user inputs
    num_notes = int(notes_dropdown.get())
    max_distance = int(distance_dropdown.get())
    allow_repeated_notes = allow_repeated_notes_var.get()
    allow_repeated_chords = allow_repeated_chords_var.get()
    chord_frequency = chord_frequency_dropdown.get()
    start_with_do = start_with_do_var.get()
    end_with_do = end_with_do_var.get()
    starting_do = start_with_do_dropdown.get()
    ending_do = end_with_do_dropdown.get()
    # values=["Never", "Every 4 notes", "Every 3 notes", "Every 2 notes", "Every note"]
    chord_start_offset = 2
    if chord_frequency == "Every 3 notes":
        chord_start_offset = 1
    # Get available notes and chords
    available_notes = [note for note, var in note_vars.items() if var.get()]
    available_chords = [chord for chord, var in chord_vars.items() if var.get()]

    # Show a warning if not enough notes are selected
    # the minimum number of notes is the minimum of 2 and the effective length of the melody
    # where the effective length is the original length reduced by 1 for each of the "Start with do" and "End with do" checkboxes
    min_number_of_notes = 2 if not allow_repeated_notes else 1
    min_number_of_notes = 0 if chord_frequency == "Every note" else min_number_of_notes

    min_number_of_chords = 2 if not allow_repeated_chords else 1
    min_number_of_chords = 0 if chord_frequency == "Never" else min_number_of_chords
    effective_length = num_notes - (start_with_do + end_with_do)
    min_number_of_notes = min(min_number_of_notes, effective_length)  # Ensure at least 2 notes are selected
    min_number_of_chords = min(min_number_of_chords, effective_length)  # Ensure at least 2 chords are selected

    if len(available_notes) < min_number_of_notes or len(available_chords) < min_number_of_chords:
        tk.messagebox.showwarning(
            "Warning",
            f"Not enough notes or chords selected! Please select at least {min_number_of_notes} notes and {min_number_of_chords} chords."
        )
        return

    # Generate the melody
    for i in range(1, num_notes + 1):
        if i == 1 and start_with_do:  # First note
            Melody.append(starting_do)
            melody_text.append(starting_do)
        elif i == num_notes and end_with_do:  # Last note
            Melody.append(ending_do)
            melody_text.append(ending_do)
        elif (chord_frequency != "Never") and (i+chord_start_offset) % {"Every 4 notes": 4, "Every 3 notes": 3, "Every 2 notes": 2, "Every note": 1}[chord_frequency] == 0:
            # Add a chord
            if allow_repeated_chords:
                selected_chord = random.choice(available_chords)
            else:
                available_chords = [chord for chord in available_chords if chord not in Melody]
                if not available_chords:
                    tk.messagebox.showwarning(
                        "Warning",
                        "Not enough unique chords available! Please enable repeated chords or select more chords."
                    )
                    return
                selected_chord = random.choice(available_chords)
            Melody.append(Chord_lookup[selected_chord])
            melody_text.append(selected_chord)
        else:
            # Add a note
            if (i == 2 and start_with_do):
               # second note of melody: we don't want it to be the same as starting_do
                if allow_repeated_notes:
                    candidates = available_notes
                else:
                    candidates = [note for note in available_notes if note != starting_do]
            else:
                # third or later note of melody: need to check distance from previous note
                current_note = Melody[-1] if Melody else None
                if not isinstance(current_note, str):
                    current_note = Melody[-2] if Melody else None
                if allow_repeated_notes:
                    # check distance from previous note only
                    candidates = [
                        note for note in available_notes
                        if not current_note or abs(available_notes.index(note) - available_notes.index(current_note)) <= max_distance ]
                elif i == num_notes - 1 and end_with_do:
                    # second last note of melody: we also don't want it to be the same as ending_do
                    candidates = [
                        note for note in available_notes
                        if not current_note or (note != current_note
                                                and note != ending_do
                                                and abs(available_notes.index(note) - available_notes.index(current_note)) <= max_distance) ]
                else:
                    # middle note of melody: we don't want it to be the same as current_note
                    candidates = [
                        note for note in available_notes
                        if not current_note or (note != current_note 
                                                and abs(available_notes.index(note) - available_notes.index(current_note)) <= max_distance)
                    ]
                if not candidates:
                    tk.messagebox.showwarning(
                        "Warning",
                        "Not enough unique notes available! Please enable repeated notes or select more notes."
                    )
                    return
            next_note = random.choice(candidates)
            Melody.append(next_note)
            melody_text.append(next_note)

    # Write the melody to MP3 files
    write_chord_melody()  

def write_chord_melody():
    global Melody

    # Step 1: Count single notes and chords in the Melody
    melody_structure = []
    for item in Melody:
        if isinstance(item, list):  # It's a chord
            melody_structure.append(len(item))  # Store the number of notes in the chord
        else:  # It's a single note
            melody_structure.append(1)

    # Step 2: Get settings that impact the chord melody
    melody_offset = int(melody_offset_dropdown.get())
    truncate = truncate_dropdown.get() != "None"
    truncation_length = int(truncate_dropdown.get()) if truncate else None
    arpeggiate_chords = arpeggiate_chords_var.get()
    arpeggiate_order = arpeggiate_chord_note_order_dropdown.get()
    chord_offset = int(arpeggiate_chord_delay_dropdown.get())

    # Step 3: Process each instrument
    for instrument in instruments:
        # Step 3a: Calculate the total length of the melody in milliseconds
        total_length = 0

        # Determine the length of the last note or chord
        last_item = Melody[-1]
        if isinstance(last_item, list):  # Last item is a chord
            last_note = get_mp3(Mapping[key_dropdown.get()][instrument][last_item[-1]])
        else:  # Last item is a single note
            last_note = get_mp3(Mapping[key_dropdown.get()][instrument][last_item])
        length_of_last_note = len(last_note) if last_note else 0
        effective_length_of_last_note = min(length_of_last_note, truncation_length) if truncate else length_of_last_note

        for i, item in enumerate(Melody):
            if isinstance(item, list):  # It's a chord
                if arpeggiate_chords:
                    total_length += melody_offset + (len(item) - 1) * chord_offset
                else:
                    total_length += melody_offset
            else:  # It's a single note
                total_length += melody_offset
        total_length += effective_length_of_last_note

        # Step 3b: Create a silent audio segment of the total length
        sound = AudioSegment.silent(duration=total_length)

        # Step 3c: Iterate through each single note and each note in each chord
        current_position = 0
        for item in Melody:
            if isinstance(item, list):  # It's a chord
                chord_notes = item.copy()
                if arpeggiate_order == "Descending":
                    chord_notes.reverse()
                elif arpeggiate_order == "Random":
                    random.shuffle(chord_notes)

                for i, note in enumerate(chord_notes):
                    note_audio = get_mp3(Mapping[key_dropdown.get()][instrument][note])
                    if truncate:
                        note_audio = note_audio.fade(to_gain=-120, start=truncation_length, duration=200)
                    offset = current_position + (i * chord_offset if arpeggiate_chords else 0)
                    sound = sound.overlay(note_audio, position=offset)

                current_position += melody_offset + (len(chord_notes) - 1) * chord_offset if arpeggiate_chords else melody_offset
            else:  # It's a single note
                note_audio = get_mp3(Mapping[key_dropdown.get()][instrument][item])
                if truncate:
                    note_audio = note_audio.fade(to_gain=-120, start=truncation_length, duration=200)
                sound = sound.overlay(note_audio, position=current_position)
                current_position += melody_offset

        # Step 3d: Export the MP3 to file
        combined_file = instrument_temp_file(instrument)
        sound.export(combined_file, format="mp3")

def show_solfege():
    solfege_text.config(state="normal")  # Enable editing temporarily
    solfege_text.delete("1.0", tk.END)  # Clear the text box
    display_text = melody_text
    if display_chord_notes_chords_var.get():
        display_text = Melody
    # Build the solfege string
    solfege_display = []
#    for item in Melody:
    for item in display_text:
        if isinstance(item, list):  # It's a chord
            chord_display = "[" + " ".join(item) + "]"  # Format chord notes in square brackets
            solfege_display.append(chord_display)
        else:  # It's a single note
            solfege_display.append(item)

    # Insert the formatted solfege into the text box
    solfege_text.insert(tk.END, " ".join(solfege_display))
    solfege_text.config(state="disabled")  # Disable editing again 

def play_melody(instrument):
    # Path to the pre-generated combined MP3 for the selected instrument
    combined_file = instrument_temp_file(instrument)   
    # Play the file
    play = threading.Thread(target=playsound, args=(combined_file,))
    play.start()

# Buttons for the Melody frame
generate_button = tk.Button(labelFrames["Melody"], text="Generate melody", command=generate_chord_melody, font=BIGFONT, bg=BUTTON_COLOR, fg=TEXT_COLOR, underline=0)
generate_button.grid(row=8, column=1, columnspan=1, padx=5, pady=4, sticky="w")
root.bind("g", lambda event: generate_chord_melody())
generate_button_tooltip = Tooltip(generate_button, "Generate a new melody. The previous melody will be overwritten.")

# Text area for "Solfege"
# First create a frame so that we can put the button and the text area closer together
solfege_frame = tk.Frame(labelFrames["Melody"], bg=BG_COLOR)
solfege_frame.grid(row=9, column=0, columnspan=3, padx=0, pady=0, sticky="w")

show_solfege_button = tk.Button(solfege_frame, text="Show Solfege", command=show_solfege, font=FONT, bg=BUTTON_COLOR, fg=TEXT_COLOR, underline=0)
show_solfege_button.grid(row=0, column=0, padx=5, pady=4, sticky="w")
root.bind("s", lambda event: show_solfege())

solfege_text = tk.Text(solfege_frame, font=FONTLIGHT, height=2, width=56, bg="white", fg=TEXT_COLOR, takefocus=False, state="disabled")
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