from PIL import Image, ImageSequence
import os
import sys

# Function to create a vertical image strip
def create_vertical_strip(input_image, output_filename, num_frames=128):
    # Open the input image
    im = Image.open(input_image)

    # Get the image size
    width, height = im.size

    # Create a list of frames with increasing opacity
    frames = []
    for frame in ImageSequence.Iterator(im):
        for i in range(num_frames):
            opacity = i / (num_frames - 1)  # Calculate opacity value from 0 to 1
            alpha = int(255 * opacity)  # Convert opacity to alpha value
            im_frame = frame.copy()
            im_frame.putalpha(alpha)  # Set the alpha value for the current frame
            frames.append(im_frame)

    # Create the vertical strip image from the frames
    vertical_strip = Image.new('RGBA', (width, height * num_frames))
    for i, frame in enumerate(frames):
        vertical_strip.paste(frame, (0, i * height))

    # Save the vertical strip image
    vertical_strip.save(output_filename)

# Check if image files were provided
if len(sys.argv) < 2:
    print("Please drag and drop one or more image files onto this script.")
    sys.exit()

# Get the input image files
input_files = sys.argv[1:]

# Process each input image file
for input_file in input_files:
    # Generate the output filename
    file_name, file_ext = os.path.splitext(input_file)
    output_file = f"{file_name}_vertical_strip{file_ext}"

    # Create the vertical image strip
    create_vertical_strip(input_file, output_file)
    print(f"Vertical image strip created: {output_file}")