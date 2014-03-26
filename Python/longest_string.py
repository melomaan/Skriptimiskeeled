# -*- coding: utf-8 -*-
"""Script for finding out the longest string in a text file. Will print the
longest string, number of characters and line number.

Author: Üllar Seerme
"""

try:
    loc = input("Enter location of text file: ")
    fh = open(loc, "r")
except IOError as err:
    print("Error in opening the file:", err)
else:
    var = 0
    lon = ""
    line_no = 0
    j = 0
    for line in fh.readlines():
        line_no += 1
        words = line.split()
        for word in words:
            if len(word) > var:
                var = len(word)
                lon = word
                j = line_no
    print("Longest string was \"%s\" with %s characters on line %s." % (lon, var, j))