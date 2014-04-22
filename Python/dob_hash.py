# -*- coding: utf-8 -*-
"""Script for finding an SHA-1 hash that ends with the person's
date of birth. DOB must be formatted as DayMonthYear with leading zeros
where necessary. Currently, the script only goes through a set amount of
numbers. I didn't see it necessary to implement anything more because it
worked for my birth date as I added a zero, or three, to the while condition.
Depending on the machine and on the size of the value being checked against,
the code might run for quite a while, and it still might come up with nothing.
"""
__author__ = 'Üllar Seerme'

import hashlib

num = 1
dob = "090592"
while num <= 10000:
    h = hashlib.sha1(b"num").hexdigest()
    if h.endswith(dob):
        print(num, h)
        break
    else:
        num += 1
