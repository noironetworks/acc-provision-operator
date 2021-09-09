FROM quay.io/operator-framework/ansible-operator:v1.10.1
ARG ACC_PROVISION_REPO_BRANCH
ENV ACC_PROVISION_BRANCH=${ACC_PROVISION_REPO_BRANCH:-master}

# Export http and https proxy here if building locally for dev
COPY requirements.yml ${HOME}/requirements.yml
USER 0
RUN update-crypto-policies --set LEGACY && pip3 install pyopenssl
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
