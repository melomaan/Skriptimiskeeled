# -*- coding: utf-8 -*-
"""Script prints a Christmas tree according to the height given."""
__author__ = 'Üllar Seerme'

while True:
    rows = int(input("Insert height of Christmas tree in rows: "))
    if rows > 40:
        print("Enter a smaller height!")
    else:
        break

spc = rows
i = 1
j = 1
greeting = "Merry Christmas!"

print()
print(' '*(spc - int((len(greeting) / 2))), greeting)
print()

while i <= rows:
    print(' '*spc, '*'*j)
    spc -= 1
    j += 2
    i += 1

base_mid = int(((j/2) - 0.5))

if rows >= 30:
    print(' '*(base_mid-6), '|'*12)
elif rows >= 20:
    print(' '*(base_mid-4), '|'*9)
elif rows >= 10:
    print(' '*(base_mid-2), '|'*5)
else:
    print(' '*base_mid, '|')