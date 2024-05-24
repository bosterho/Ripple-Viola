import pretty_midi
from PIL import Image, ImageDraw

# Load the MIDI file
midi_file = pretty_midi.PrettyMIDI('../../Data/midi.mid')

# Get the piano roll representation of the MIDI data
piano_roll = midi_file.get_piano_roll(fs=100)  # fs=100 means 100 samples per second

# Determine the dimensions of the piano roll image
num_notes = piano_roll.shape[0]
num_samples = piano_roll.shape[1]
note_height = 10  # Height of each note in pixels
image_height = num_notes * note_height
image_width = num_samples


# Iterate over each instrument (track)
for instrument_idx, instrument in enumerate(midi_file.instruments):
    # Create a new image with a transparent background
    piano_roll_image = Image.new('RGBA', (image_width, image_height), color=(0, 0, 0, 0))
    draw = ImageDraw.Draw(piano_roll_image)

    # Draw the piano roll for the current instrument
    for note_number in range(num_notes):
        for sample in range(num_samples):
            velocity = piano_roll[note_number, sample]
            if velocity > 0:
                intensity = int(velocity * 255)
                note_top = note_number * note_height
                note_bottom = note_top + note_height
                x = sample
                draw.rectangle([(x, note_top), (x + 1, note_bottom)], fill=(intensity, intensity, intensity, 255))

    # Save the piano roll image for the current instrument
    instrument_name = instrument.name or f"Instrument_{instrument_idx}"
    piano_roll_image.save(f'{instrument_name}.png')