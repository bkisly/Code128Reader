import sys

set_c_sequences = [
    0b11011001100,
    0b11001101100,
    0b11001100110,
    0b10010011000,
    0b10010001100,
    0b10001001100,
    0b10011001000,
    0b10011000100,
    0b10001100100,
    0b11001001000,
    0b11001000100,
    0b11000100100,
    0b10110011100,
    0b10011011100,
    0b10011001110,
    0b10111001100,
    0b10011101100,
    0b10011100110,
    0b11001110010,
    0b11001011100,
    0b11001001110,
    0b11011100100,
    0b11001110100,
    0b11101101110,
    0b11101001100,
    0b11100101100,
    0b11100100110,
    0b11101100100,
    0b11100110100,
    0b11100110010,
    0b11011011000,
    0b11011000110,
    0b11000110110,
    0b10100011000,
    0b10001011000,
    0b10001000110,
    0b10110001000,
    0b10001101000,
    0b10001100010,
    0b11010001000,
    0b11000101000,
    0b11000100010,
    0b10110111000,
    0b10110001110,
    0b10001101110,
    0b10111011000,
    0b10111000110,
    0b10001110110,
    0b11101110110,
    0b11010001110,
    0b11000101110,
    0b11011101000,
    0b11011100010,
    0b11011101110,
    0b11101011000,
    0b11101000110,
    0b11100010110,
    0b11101101000,
    0b11101100010,
    0b11100011010,
    0b11101111010,
    0b11001000010,
    0b11110001010,
    0b10100110000,
    0b10100001100,
    0b10010110000,
    0b10010000110,
    0b10000101100,
    0b10000100110,
    0b10110010000,
    0b10110000100,
    0b10011010000,
    0b10011000010,
    0b10000110100,
    0b10000110010,
    0b11000010010,
    0b11001010000,
    0b11110111010,
    0b11000010100,
    0b10001111010,
    0b10100111100,
    0b10010111100,
    0b10010011110,
    0b10111100100,
    0b10011110100,
    0b10011110010,
    0b11110100100,
    0b11110010100,
    0b11110010010,
    0b11011011110,
    0b11011110110,
    0b11110110110,
    0b10101111000,
    0b10100011110,
    0b10001011110,
    0b10111101000,
    0b10111100010,
    0b11110101000,
    0b11110100010,
    0b10111011110,
]

if len(sys.argv) < 2:
    print("You must specify output architecture in order to proceed. Terminating.")
    exit()

result_array = []
platform_arg = sys.argv[1]


if platform_arg == "risc-v":
    result_str = ".eqv start_code\t1692\n.eqv stop_code\t1594\n\n\t.data\nsetcarray:\t.byte\n\t"
    ofname = "RISC-V/setcarray.asm"
elif platform_arg == "x86":
    result_str = "\tsection .data\nsetcarray\tdb\t"
    ofname = "x86/setcarray.asm"
else:
    print("Invalid architecture name. Terminating.")
    exit()

for i in range(0b11111111111 + 1):
    result_array.append(-1)

value = 0
for code in set_c_sequences:
    result_array[code] = value
    value += 1

value = 0
for element in result_array:
    result_str += f"{element}, "

    if value % 10 == 9 and platform_arg == "risc-v":
        result_str += "\n\t"

    value += 1

with open(ofname, mode="w") as f:
    f.write(result_str)

print(f"Successfully saved output to {ofname}.")
