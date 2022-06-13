import os
from time import sleep


def main(args):
    """
    generate unbound config for adblocking
    """

    reader = open(args.adlist, 'r')
    adlist = reader.readlines()
    reader.close

    for line in adlist:
        print(line.strip())

        # delay
        sleep(0.1)
