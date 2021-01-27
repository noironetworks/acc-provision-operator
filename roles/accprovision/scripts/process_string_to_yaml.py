#!/usr/bin/python3

import json
import yaml
import copy
import os

def main():
    cmap_input_path = os.getenv('CONFIGMAP_INPUT_FILE')
    cmap = dict()
    input_dict = dict()
    with open(cmap_input_path, 'r') as stream:
        cmap = yaml.safe_load(stream)
        yaml_cmap_intermediate = cmap['data']['spec']
        input_dict = yaml.safe_load(yaml_cmap_intermediate)
        yaml_cmap = input_dict['acc_provision_input']
    crd_input = os.getenv('CRDINPUT')
    yaml_crd = yaml.safe_load(crd_input)
    deep_merge(yaml_crd, yaml_cmap)

    # Write configmap file
    input_dict['acc_provision_input'] = yaml_crd
    cmap['data']['spec'] = json.dumps(input_dict)
    cmap['metadata'].pop('managedFields', None)
    cmap['metadata'].pop('annotations', None)
    cmap['metadata'].pop('creationTimestamp', None)
    cmap['metadata'].pop('resourceVersion', None)
    cmap['metadata'].pop('uid', None)
    with open(cmap_input_path, 'w') as outfile:
        json.dump(cmap, outfile)

    # Write acc_provision_input to file
    acc_prov_dir = os.getenv('ACCPROVDIR')
    acc_prov_file = os.getenv('ACCPROVFILE')
    acc_prov_file_path = os.path.join(acc_prov_dir, acc_prov_file)
    with open(acc_prov_file_path, 'w') as outfile:
        yaml.dump(yaml_crd, outfile, default_flow_style=False)
    return 0

def deep_merge(override, default):
    if isinstance(override, dict) and isinstance(default, dict):
        for k, v in default.items():
            if k not in override:
                override[k] = v
            else:
                override[k] = deep_merge(override[k], v)
    return copy.deepcopy(override)

if __name__ == "__main__":
    main()
