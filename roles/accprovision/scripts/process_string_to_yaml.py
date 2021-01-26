#!/usr/bin/python3

import yaml
import os

def main():
    string = os.getenv('INPUTSTRING')
    filepath = os.getenv('INPUTFILEPATH')
    converted = yaml.safe_load(string)
    with open(filepath, 'w') as outfile:
        yaml.dump(converted, outfile, default_flow_style=False)
    print(converted)
    return 0

if __name__ == "__main__":
    main()
