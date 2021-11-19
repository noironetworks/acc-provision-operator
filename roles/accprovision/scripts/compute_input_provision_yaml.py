#!/usr/bin/python3

import yaml
import os
from mergedeep import merge

def main():
    crd_input = os.getenv('CRDINPUT')
    config = yaml.safe_load(crd_input)
    if config.get("aci_cni_config"):
        for key, value in config["aci_cni_config"].items():
            if key in config.keys():
                merge(config[key],config["aci_cni_config"][key])
            elif key == 'kube_config':
                config.update(config["aci_cni_config"]['kube_config'])
            else:
                config[key] = config["aci_cni_config"][key]

    acc_prov_file_path = os.path.join(os.getenv('ACCPROVDIR'), os.getenv('ACCPROVFILE'))
    with open(acc_prov_file_path, 'w') as outfile:
        for key, value in config.items():
            if key == 'aci_cni_config':
                pass
            else:
                yaml.dump({key: value}, outfile, default_flow_style=False)
    return 0

if __name__ == "__main__":
    main()
