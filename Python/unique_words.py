# -*- coding: utf-8 -*-
"""Script for finding all the unique words on a given site. Source code is
written to a file, after which the HTML-tags are removed in the process. All
the unique words are then added to an array and afterwards written to a file.
Mitsuhiko's MarkupSafe _striptags_re variable was used for the regular
expression.
https://github.com/mitsuhiko/markupsafe/blob/master/markupsafe/__init__.py
"""
__author__ = 'Üllar Seerme'

from urllib.parse import urlsplit
import urllib.request
import re

site = input("Enter a site to scrape for unique words: ")
loc = urlsplit(site)
loc = loc.hostname.replace(".", "_")
response = urllib.request.urlopen(site)
html = response.read().decode("utf-8")
unique = []

with open(loc + "_src.txt", "w", encoding="utf-8") as f:
    f.write(html)

with open(loc + "_unique.txt", "w", encoding="utf-8") as h:
    html = re.sub('(<!--.*?-->|<[^>]*>)', '', html)
    html = html.split()

    for word in html:
        if not word in unique:
            unique.append(word)

    for foo in unique:
        h.write(foo + "\n")
