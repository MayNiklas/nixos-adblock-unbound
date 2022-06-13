import os
from urllib.parse import urlparse

import validators


def uri_validator(url):
    if validators.domain(url):
        return 1
    else:
        return 0


def get_domains(path):
    """
    get valid domains from file
    """

    list = []
    reader = open(path, 'r')
    adlines = reader.readlines()
    reader.close
    for line in adlines:
        if "0.0.0.0 " in line:
            split = line.strip().split(' ')
            if uri_validator(split[1]):
                list.append(split[1])
    return list


def main(args):
    """
    generate unbound config for adblocking
    """

    domains = get_domains(args.adlist)

    for entry in domains:
        print("local-zone: \"" + entry+"\" static")
