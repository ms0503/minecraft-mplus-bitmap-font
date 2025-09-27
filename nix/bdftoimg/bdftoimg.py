#!/usr/bin/env python3
# Original by @makutamoto

import re

from PIL import Image, ImageOps
from math import ceil
from optparse import OptionParser
from sys import exit, stderr


def main():
    parser = OptionParser(usage="Usage: %prog <filename> <outputfile>")
    (_, args) = parser.parse_args()
    if len(args) != 2:
        stderr.write("Input and output files must be specified.\n")
        exit(1)
    input_file = args[0]
    output_file = args[1]
    input_data = ""
    try:
        with open(input_file) as f:
            input_data = f.read()
    except OSError:
        stderr.write(f"Could not open '{args[0]}'\n")
        exit(1)
    charsRegex = re.compile(r"CHARS (\d+)")
    chars = int(next(charsRegex.finditer(input_data)).group(1))
    clauseRegex = re.compile(
        r"STARTCHAR(?s:.+?)BBX\s+(\d+)\s+(\d+)\s+(-*\d+)\s+(-*\d+)\s*\nBITMAP\s*\n((?s:.*?))\n?ENDCHAR\n"
    )
    result: list[Image.Image] = []
    maxSize = (0, 0)
    for char in clauseRegex.finditer(input_data):
        base_image = []
        size = (int(char.group(1)), int(char.group(2)))
        maxSize = (max(size[0], maxSize[0]), max(size[1], maxSize[1]))
        bitmap = char.group(5).split("\n")
        if bitmap == [""]:
            continue
        for line in bitmap:
            bitwidth = len(line) * 4
            bin = int(line, 16)
            for _ in range(-int(char.group(3))):
                base_image.append(0xFF)
            for _ in range(-int(char.group(3)), size[0]):
                if bin & (0b01 << (bitwidth - 1)):
                    base_image.append(0xFF)
                else:
                    base_image.append(0x00)
                bin = bin << 1
        image = Image.frombytes("L", size, bytes(base_image))
        mask = image.copy()
        image.putalpha(mask)
        result.append(image)
    result_iter = iter(result)
    rows = ceil(chars / 16)
    image = Image.new("LA", (maxSize[0] * 16, maxSize[1] * rows))
    try:
        for row in range(rows):
            for col in range(16):
                current = next(result_iter)
                image.paste(current, (maxSize[0] * col, maxSize[1] * row))
    except StopIteration:
        pass
    image.save(output_file)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
