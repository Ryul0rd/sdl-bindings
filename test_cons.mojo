from sys.info import os_is_linux, os_is_macos


fn main():
    constrained[(os_is_linux() or os_is_macos()), "OS is not supported"]()
    print("mac", os_is_macos())
    print("linux", os_is_linux())
