# -*- coding: utf-8 -*-
"""Script for generating one thousand pseudo-random numbers, finding the
number of occurrences of each and writing them to a specified file. Afterwards
an output is displayed of the maximum, minimum and average values of the list.
"""
__author__ = 'Üllar Seerme'

import random

rng = []
d = {}
loc = input("Enter full path (with the name) of the output file: ")

with open(loc + ".txt", "w") as f:
    for i in range(1, 1001):
        j = random.randrange(1, 1001)
        f.write(str(i) + ". " + str(j) + "\n")
        rng.append(j)

    f.write("\n")

    for k in set(rng):
        d[k] = rng.count(k)

    for key, value in d.items():
        f.write(str(key) + ":" + str(value) + "\n")

print("Maximum value was: " + str(max(rng)))
print("Minimum value was: " + str(min(rng)))
print("Average value was: " + str(sum(rng)/len(rng)))