import argparse
import os

from .generate_unbound_conf import main


def parse_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument('--adlist', type=file_path)
    return parser.parse_args()


def file_path(string):
    if os.path.isfile(string):
        return os.path.abspath(string)
    else:
        raise FileNotFoundError(string)


def main():
    """ Entrypoint """

    args = parse_arguments()
    generate_unbound_conf.main(args)
