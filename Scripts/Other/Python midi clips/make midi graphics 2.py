from PIL import Image, ImageDraw
# import midi_data # not sure how to do this
midi_data = [
	[
		{"pitch":60, "vel":127, "pos":0, "length":1920, },
		{"pitch":63, "vel":127, "pos":0, "length":1920, },
		{"pitch":67, "vel":127, "pos":2640, "length":1920, },
		{"pitch":70, "vel":127, "pos":2640, "length":1920, },
	],
	[
		{"pitch":60, "vel":127, "pos":0, "length":1920, },
		{"pitch":67, "vel":127, "pos":0, "length":1920, },
		{"pitch":54, "vel":127, "pos":2640, "length":1920, },
		{"pitch":61, "vel":127, "pos":2640, "length":1920, },
	],
]
clip_lengths = [7680, 7680, ]
clip_names = ["clip 1", "clip 2", ]
lowest_pitches = [60, 54, ]
highest_pitches = [70, 67, ]


def mapRange(value, inMin, inMax, outMin, outMax):
    return outMin + (((value - inMin) / (inMax - inMin)) * (outMax - outMin))

clip_width = 100
clip_height = 100
margin = 10

for clip_i, clip in enumerate(midi_data):
    clip_image = Image.new('RGBA', (clip_width, clip_height), color=(0, 0, 0, 0))
    draw = ImageDraw.Draw(clip_image)

    radius = 4
    rect = [(0, 0), (clip_width, clip_height)]
    draw.rounded_rectangle(rect, radius, fill=(255, 255, 255, 50))

    pitchRange = highest_pitches[clip_i] - lowest_pitches[clip_i]
    h = (clip_height - margin*2) / pitchRange
    for note in clip:
        intensity = mapRange(note["vel"], 1, 127, 50, 255)
        intensity = int(intensity)
        print(intensity)
        x = mapRange(note["pos"], 0, clip_lengths[clip_i], margin, clip_width - margin)
        y = mapRange(note["pitch"], lowest_pitches[clip_i], highest_pitches[clip_i], margin, clip_height - h - margin)
        w = mapRange(note["length"], 0, clip_lengths[clip_i], 0, clip_width - margin*2)
        radius = 4
        rect = [(x, y), (x + w, y + h)]
        draw.rounded_rectangle(rect, radius, fill=(intensity, intensity, intensity, 255))

    clip_image.save(clip_names[clip_i] + '.png')
    

'''
# Determine the dimensions of the piano roll image
num_notes = piano_roll.shape[0]
num_samples = piano_roll.shape[1]
note_height = 10  # Height of each note in pixels
image_height = num_notes * note_height
image_width = num_samples

clip_width = 100
clip_height = 100


# Iterate over each instrument (track)
for instrument_idx, instrument in enumerate(midi_file.instruments):
    # Create a new image with a transparent background
    clip_image = Image.new('RGBA', (clip_width, clip_height), color=(0, 0, 0, 0))
    draw = ImageDraw.Draw(clip_image)

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
    clip_image.save(f'{instrument_name}.png')
'''