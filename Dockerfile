FROM quay.io/operator-framework/ansible-operator:main
ARG ACC_PROVISION_REPO_BRANCH
ENV ACC_PROVISION_BRANCH=${ACC_PROVISION_REPO_BRANCH:-master}
USER 0
#RUN microdnf update -y && microdnf clean all
RUN microdnf update -y && microdnf install -y crypto-policies-scripts git && microdnf clean all
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
RUN update-crypto-policies --set LEGACY && pip3 install pyopenssl
#RUN ansible-galaxy collection install -r ${HOME}/requirements.yml \
# && chmod -R ug+rwx ${HOME}/.ansible

# Retry logic for transient Galaxy errors
RUN for i in 1 2 3 4 5; do \
      ansible-galaxy collection install -r ${HOME}/requirements.yml && break || \
      (echo "Retry $i failed, waiting..." && sleep 10); \
    done \
 && chmod -R ug+rwx ${HOME}/.ansible

 RUN microdnf install git -y
RUN git clone --single-branch --branch ${ACC_PROVISION_BRANCH} https://github.com/noironetworks/acc-provision.git
RUN cd acc-provision/provision && python3 setup.py install

USER 1001
# Unset http and https proxy here if defined earlier

COPY watches.yaml ${HOME}/watches.yaml
COPY roles/ ${HOME}/roles/
COPY playbooks/ ${HOME}/playbooks/
