FROM docker:27-cli
RUN apk add --no-cache python3 py3-pip py3-yaml ansible openssh-client bash git
WORKDIR /project
ENTRYPOINT ["ansible-playbook", "-i", "localhost,", "-c", "local", "ansible/site.yml"]
