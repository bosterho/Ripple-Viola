from PIL import Image
import os

def rgb_to_hex(r, g, b):
    return "#{:02x}{:02x}{:02x}".format(r, g, b)

def find_full_alpha_pixel_colors(image_paths, output_path):
    found_colors = []

    for image_path in image_paths:
        # Open the image file
        with Image.open(image_path) as img:
            # Ensure the image has an alpha channel
            if img.mode != 'RGBA':
                img = img.convert('RGBA')
            
            # Get the image data
            pixels = img.load()
            
            # Iterate over each pixel to find a fully opaque one
            width, height = img.size
            for y in range(height):
                for x in range(width):
                    r, g, b, a = pixels[x, y]
                    if a == 255:
                        hex_color = rgb_to_hex(r, g, b)
                        found_colors.append((image_path, hex_color))
                        break
                if found_colors and found_colors[-1][0] == image_path:
                    break
    
    # Write all found colors to the output file
    with open(output_path, 'w') as f:
        i=1
        f.write("hex_colors = []\n")
        f.write("hex_colors[0] = '#ffffff'\n")
        for image_path, hex_color in found_colors:
            f.write(f"hex_colors[{i}] = '{hex_color}'\n")
            i=i+1
    
    print(f"Colors found and written to {output_path}")

# Example usage
basepath = "../../../../Resources/pictures/"
image_files = []
image_paths = []

for i in range(1, 16, 1):
    image_files.append("ripple 1 ch " + str(i) + ".png")

for file in image_files:
    image_paths.append(os.path.join(basepath, file))

output_file = "channel_colors.js"
find_full_alpha_pixel_colors(image_paths, output_file)
