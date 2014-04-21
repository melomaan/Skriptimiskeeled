# -*- coding: utf-8 -*-
"""Script for either packing or unpacking. Presents
a choice to pack a an absolute path, unpack an archive
or just exit. It is possible to tell where to unpack.
"""
__author__ = 'Üllar Seerme'
import shutil


def pack():
    valid = False
    while not valid:
        try:
            src = input("Enter full path to archive: ")
            name = input("Enter name of archive: ")
            dst = input("Enter destination: ") + "\\" + name
            if src and name and dst != "":
                valid = True
                shutil.make_archive(dst, format="zip", root_dir=src)
                print("Finished archiving to", dst + ".zip")
        except IOError as err:
            print("An error occurred: ", err)


def unpack():
    valid = False
    while not valid:
        try:
            src = input("Enter location of archive: ")
            dst = input("Enter destination: ")
            if src and dst != "":
                valid = True
                shutil.unpack_archive(src, dst)
        except IOError as err:
            print("An error occurred: ", err)


def display_menu():
    print("1. Package directory")
    print("2. Unpack archive")
    print("0. Exit")


def get_menu_option():
    option_valid = False
    choice = ""
    while not option_valid:
        try:
            choice = int(input("Option selected: "))
            if 0 <= choice <= 2:
                option_valid = True
            else:
                print("Please enter a valid option!")
        except ValueError:
            print("Please enter valid option!")

    return choice


def manage():
    noexit = True
    while noexit:
        display_menu()
        option = get_menu_option()
        if option == 1:
            pack()
        elif option == 2:
            unpack()
        elif option == 0:
            noexit = False