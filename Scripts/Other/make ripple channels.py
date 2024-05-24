from PIL import Image
import os

def colorize_image(input_path, output_path, hex_color):
    # Open the input image
    image = Image.open(input_path).convert("RGBA")
    
    # Convert hex color to RGB
    r_color, g_color, b_color = tuple(int(hex_color[i:i+2], 16) for i in (1, 3, 5))
    
    # Load the data of the image
    data = image.getdata()
    
    new_data = []
    for item in data:
        # Change all white (also shades of whites)
        # pixels to the given color
        if item[0] > 200 and item[1] > 200 and item[2] > 200:
            # Apply the alpha of the original white to the new color
            alpha = item[3]
            new_data.append((r_color, g_color, b_color, alpha))
        else:
            new_data.append(item)
    
    # Update image data
    image.putdata(new_data)
    
    # Save the colorized image
    image.save(output_path)

def process_images(file_list, output_dir, hex_colors):
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    for file_path in file_list:
        input_path = file_path
        name, ext = os.path.splitext(os.path.basename(file_path))
        
        for index, hex_color in enumerate(hex_colors):
            output_filename = f"{name} ch {index+1}.png"
            output_path = os.path.join(output_dir, output_filename)
            print(output_filename, hex_color)
            colorize_image(input_path, output_path, hex_color)

def read_hex_colors(file_path):
    with open(file_path, 'r') as file:
        hex_colors = [line.strip() for line in file if line.strip()]
    return hex_colors

# Define your parameters here
pictures_folder = "../../Resources/pictures/"

hex_colors_file = "P5 midi clips/assets/channel colors.txt"
hex_colors = read_hex_colors(hex_colors_file)

# Ripples
file_names = []
for r in range(-5, 6, 1):
    if r != 0:
        file_names.append("ripple " + str(r) + ".png")

file_list = []
for file_name in file_names:
    file_list.append(os.path.join(pictures_folder, file_name))

process_images(file_list, pictures_folder, hex_colors)


# Ripple Swells
file_names = []
for r in range(-5, 6, 1):
    if r != 0:
        file_names.append("ripple swell " + str(r) + ".png")

file_list = []
for file_name in file_names:
    file_list.append(os.path.join(pictures_folder, file_name))

process_images(file_list, pictures_folder, hex_colors)
