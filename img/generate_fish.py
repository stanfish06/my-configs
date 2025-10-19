from PIL import Image

palette = {
    "0": (0x00, 0x00, 0x00),  # Black
    "1": (0x00, 0x00, 0xAA),  # Blue
    "2": (0x00, 0xAA, 0x00),  # Green
    "3": (0x00, 0xAA, 0xAA),  # Cyan
    "4": (0xAA, 0x00, 0x00),  # Red
    "5": (0xAA, 0x00, 0xAA),  # Magenta
    "6": (0xAA, 0x55, 0x00),  # Brown
    "7": (0xAA, 0xAA, 0xAA),  # Light Gray
    "8": (0x55, 0x55, 0x55),  # Dark Gray
    "9": (0x55, 0x55, 0xFF),  # Light Blue
    "A": (0x55, 0xFF, 0x55),  # Light Green
    "B": (0x55, 0xFF, 0xFF),  # Light Cyan
    "C": (0xFF, 0x55, 0x55),  # Light Red
    "D": (0xFF, 0x55, 0xFF),  # Light Magenta
    "E": (0xFF, 0xFF, 0x55),  # Yellow
    "F": (0xFF, 0xFF, 0xFF),  # White
    ".": (0x00, 0x00, 0x00),  # Transparent/Background (Black)
}

fish_data = [
    "...................................",
    "...................................",
    "...................................",
    "...................................",
    "...................................",
    "...................................",
    "...................................",
    "...................................",
    "............6666.....66............",
    "............6868666666866..........",
    ".............68686868666866........",
    "....66......66666666666666666......",
    "....66666..6666666666866666F66.....",
    "....6866666668686868686666FFF6.....",
    ".....688666668686868688686FF066....",
    ".....688868688888888838888FFF66....",
    ".....6883838638383838338388F866....",
    "......3833333333333333333338336....",
    ".....333..33333333333333333333.....",
    ".....383..3333333333333333333......",
    "....3333...33333333333333333.......",
    "....333.....33333333333333.........",
    "....333....333333.333..............",
    "....33............3................",
    "...................................",
    "...................................",
    "...................................",
    "...................................",
    "...................................",
    "...................................",
    "...................................",
    "...................................",
]


def generate_fish_sprite(scale=1, output_filename="templeos_fish.png"):
    width = 35
    height = 32

    img = Image.new("RGB", (width * scale, height * scale))
    pixels = img.load()

    for y in range(height):
        for x in range(width):
            char = fish_data[y][x].upper()
            color = palette.get(char, palette["."])

            for sy in range(scale):
                for sx in range(scale):
                    pixels[x * scale + sx, y * scale + sy] = color

    img.save(output_filename)
    print(
        f"Fish sprite saved as '{output_filename}' ({width * scale}x{height * scale} pixels)"
    )


if __name__ == "__main__":
    generate_fish_sprite(scale=1, output_filename="fish_1x.png")
    generate_fish_sprite(scale=10, output_filename="fish_10x.png")
    generate_fish_sprite(scale=20, output_filename="fish_20x.png")
