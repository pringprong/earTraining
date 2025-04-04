import tkinter as tk
from tkinter import ttk

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
notes_dropdown = ttk.Combobox(root, values=[2, 3, 4, 5, 6])
notes_dropdown.grid(row=1, column=1, padx=10, pady=5)
notes_dropdown.current(0)

# Checkboxes for "Notes"
notes_frame = tk.LabelFrame(root, text="Notes")
notes_frame.grid(row=2, column=0, columnspan=2, padx=10, pady=5, sticky="w")
note_vars = {}
for i, note in enumerate(["do", "re", "mi", "fa", "so", "la", "ti"]):
    note_vars[note] = tk.BooleanVar()
    checkbox = tk.Checkbutton(notes_frame, text=note, variable=note_vars[note])
    checkbox.grid(row=0, column=i, padx=5, pady=5)

# Dropdown for "Solfege/Sound"
mode_label = tk.Label(root, text="Mode:")
mode_label.grid(row=3, column=0, padx=10, pady=5, sticky="w")
mode_dropdown = ttk.Combobox(root, values=["Solfege only", "Sound only", "Sound and Solfege"])
mode_dropdown.grid(row=3, column=1, padx=10, pady=5)
mode_dropdown.current(0)

# Checkbox for "Start with do"
start_with_do_var = tk.BooleanVar()
start_with_do_checkbox = tk.Checkbutton(root, text="Start with do", variable=start_with_do_var)
start_with_do_checkbox.grid(row=4, column=0, padx=10, pady=5, sticky="w")

# Checkbox for "End with do"
end_with_do_var = tk.BooleanVar()
end_with_do_checkbox = tk.Checkbutton(root, text="End with do", variable=end_with_do_var)
end_with_do_checkbox.grid(row=4, column=1, padx=10, pady=5, sticky="w")

# Buttons at the bottom
button_frame = tk.Frame(root)
button_frame.grid(row=5, column=0, columnspan=2, pady=10)

buttons = [
    "Show Solfege",
    "Play Guitar Tonic",
    "Play Piano Tonic",
    "Play Solfege Tonic",
    "Play Guitar Melody",
    "Play Piano Melody",
    "Play Solfege Melody",
    "Next"
]

for i, button_text in enumerate(buttons):
    button = tk.Button(button_frame, text=button_text)
    button.grid(row=i // 4, column=i % 4, padx=5, pady=5)

# Run the application
root.mainloop()