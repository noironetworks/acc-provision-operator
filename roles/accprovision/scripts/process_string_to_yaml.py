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

    crd_definition = os.getenv('CRD_DEFINITION')
    crd_definition = yaml.safe_load(crd_definition) 
    deep_merge(yaml_crd, yaml_cmap, crd_definition)

    acc_prov_file_path = os.path.join(os.getenv('ACCPROVDIR'), os.getenv('ACCPROVFILE'))
    with open(acc_prov_file_path, 'w') as outfile:
        yaml.dump(yaml_crd, outfile, default_flow_style=False)
    return 0

def deep_merge(override, default, crd_definition):
    if isinstance(override, dict) and isinstance(default, dict):
        for k, v in default.items():
            if k not in override:
                if k not in crd_definition.keys():
                    override[k] = v
            else:
                if 'properties' in crd_definition[k].keys():
                    override[k] = deep_merge(override[k], v, crd_definition[k]['properties'])
                else:
                    override[k] = deep_merge(override[k], v, crd_definition)
    return copy.deepcopy(override)

if __name__ == "__main__":
    main()
