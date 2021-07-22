FROM quay.io/operator-framework/ansible-operator:v1.3.0

COPY requirements.yml ${HOME}/requirements.yml
USER 0
# TBD: No need to use proxy anymore once we move to build it in the jenkins I think?
ENV http_proxy=http://proxy.esl.cisco.com:80
ENV https_proxy=http://proxy.esl.cisco.com:80
RUN update-crypto-policies --set LEGACY && pip3 install pyopenssl
RUN ansible-galaxy collection install -r ${HOME}/requirements.yml \
 && chmod -R ug+rwx ${HOME}/.ansible
RUN yum install git -y
RUN git clone --single-branch --branch newacioperator-oldimages https://github.com/noironetworks/acc-provision.git
RUN cd acc-provision/provision && python3 setup.py install

USER 1001
ENV http_proxy=''
ENV https_proxy=''

COPY watches.yaml ${HOME}/watches.yaml
COPY roles/ ${HOME}/roles/
COPY playbooks/ ${HOME}/playbooks/
