FROM quay.io/operator-framework/ansible-operator:v1.3.0
ARG ACC_PROVISION_REPO_BRANCH
ENV ACC_PROVISION_BRANCH=${ACC_PROVISION_REPO_BRANCH:-master}

COPY requirements.yml ${HOME}/requirements.yml
USER 0
RUN update-crypto-policies --set LEGACY && pip3 install pyopenssl
RUN ansible-galaxy collection install -r ${HOME}/requirements.yml \
 && chmod -R ug+rwx ${HOME}/.ansible
RUN yum install git -y
RUN git clone --single-branch --branch newacioperator-trial https://github.com/noironetworks/acc-provision.git
RUN cd acc-provision/provision && python3 setup.py install

USER 1001
COPY watches.yaml ${HOME}/watches.yaml
COPY roles/ ${HOME}/roles/
COPY playbooks/ ${HOME}/playbooks/
