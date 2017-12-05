#!/usr/bin/env python3
'''Generate random unsigned 16-, 32- or 64-bit integers
that will be written to a file of desired size.

Usage:
    python random_numbers.py -b 16 -n 16 -u MB -o out.dat

To-Do:
    - Make 'fill_file' function more efficient by reducing write
    calls and creating individual batches that can be written to
    the file instead, or find a way to create a data structure
    with a given size (that should be split up into batches once
    there is no more reasonable amount of memory).
'''

import argparse
import os
from random import randrange

parser = argparse.ArgumentParser(description='Generate random numbers to file')
parser.add_argument('-b', '--bitness', type=int, default=16, 
                    choices=[16, 32, 64], 
                    help='Bitness value (default: %(default)s)')
parser.add_argument('-n', '--numerical-value', dest='num', default='64',
                    type=int, 
                    help="Numerical value for the output file's size (default: %(default)s)")
parser.add_argument('-u', '--unit', default='KB', 
                    help='Size unit for the output file (default: %(default)s)')
parser.add_argument('-o', '--output', required=True, 
                    help='Location of the output file')
args = parser.parse_args()


def parse_size(value, unit):
    '''Parse given size and units to determine corresponding number of bytes.

    Args:
        value: A numerical value representing size.
        unit: A two-letter string being either KB, MB or GB.

    Returns:
        A number of bytes.

    Raises:
        ValueError: If 'unit' isn't either 'KB', 'MB' or 'GB'.
    '''
    unit = unit.upper()
    if unit not in ['KB', 'MB', 'GB']:
        raise ValueError('Cannot use {} as a size unit for parsing'.format(unit))

    if unit == 'KB':
        return value * 1024
    elif unit == 'MB':
        return value * (1024**2)
    elif unit == 'GB':
        return value * (1024**3)


def fill_file(file, size):
    '''Fill file with random numbers to stated size.

    Args:
        file: Path to output file, which will be created if missing.
        size: Desired file size in bytes.
    '''
    f = open(file, 'w')

    while os.stat(file).st_size < size:
        f.write(str(randrange(2**args.bitness)) + '\n')

    f.close()


def main():
    val = parse_size(args.num, args.unit)
    fill_file(args.output, val)


if __name__ == '__main__':
    main()
