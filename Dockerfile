FROM quay.io/operator-framework/ansible-operator:main
ARG ACC_PROVISION_REPO_BRANCH
ENV ACC_PROVISION_BRANCH=${ACC_PROVISION_REPO_BRANCH:-master}
# Required OpenShift Labels
LABEL name="ACI CNI Operator" \
vendor="Cisco" \
version="v1.1.0" \
release="1" \
summary="This is an ACI CNI Operator." \
description="This operator will deploy a single instance of ACI CNI Operator."
# Required Licenses
COPY docker/licenses /licenses
# Export http and https proxy here if building locally for dev
COPY requirements.yml ${HOME}/requirements.yml
USER 0
RUN update-crypto-policies --set LEGACY && \
   dnf -y install rust git python3.9 python3.9-pip python3.9-setuptools && \
   pip3 install --upgrade pip && \
   pip3 install --upgrade pyyaml && \
   pip3 install setuptools-rust && \
   pip3 install pyopenssl && \
   pip3 install requests==2.31.0 && \
   pip3 install --upgrade 'urllib3<1.27'
RUN ansible-galaxy collection install -r ${HOME}/requirements.yml \
 && chmod -R ug+rwx ${HOME}/.ansible
RUN yum install git -y
RUN git clone --single-branch --branch ${ACC_PROVISION_BRANCH} https://github.com/noironetworks/acc-provision.git
RUN cd acc-provision/provision && python3 setup.py install

USER 1001
# Unset http and https proxy here if defined earlier

COPY watches.yaml ${HOME}/watches.yaml
COPY roles/ ${HOME}/roles/
COPY playbooks/ ${HOME}/playbooks/
