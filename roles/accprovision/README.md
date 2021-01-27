Role Name
=========

The acc-provision role manages the lifecycle of ACI CNI, including upgrades. It watches the AccProvisionInput CRD and generates the ACI CNI deployment based on that- applies it on the cluster if there's been a change in the input. 


Role Variables
--------------

The following variables are set as defaults:
acc_provision_dir_path: Directory created on the container to store role artifacts
acc_provision_file_name: Filename used to store computed input file
acicnideployment: Filename used to store computed acicnideployment

The following variables are expected to be set in the env of the operator:
WATCH_NAMESPACE: Namespace used to watch the accprovisioninput CR
ACC_PROVISION_FLAVOR: Cluster flavor
