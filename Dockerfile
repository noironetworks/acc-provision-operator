FROM quay.io/operator-framework/ansible-operator:v1.3.0
ARG ACC_PROVISION_REPO_BRANCH
ENV ACC_PROVISION_BRANCH=${ACC_PROVISION_REPO_BRANCH:-master}

COPY requirements.yml ${HOME}/requirements.yml
USER 0
ENV http_proxy=http://proxy.esl.cisco.com:80
ENV https_proxy=http://proxy.esl.cisco.com:80
RUN update-crypto-policies --set LEGACY && pip3 install pyopenssl

RUN ansible-galaxy collection install -r ${HOME}/requirements.yml \
 && chmod -R ug+rwx ${HOME}/.ansible
RUN yum install git -y \
  && yum clean all

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.14.6/bin/linux/amd64/kubectl \
  && chmod u+x kubectl && mv kubectl /usr/local/bin/kubectl
RUN git clone --single-branch --branch master https://github.com/noironetworks/acc-provision.git
RUN cd acc-provision/provision && python3 setup.py install
RUN chmod +x /usr/local/bin/kubectl
ENV http_proxy=''
ENV https_proxy=''
USER 1001

COPY watches.yaml ${HOME}/watches.yaml
COPY roles/ ${HOME}/roles/
COPY playbooks/ ${HOME}/playbooks/
