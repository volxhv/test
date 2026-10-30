FROM docker:27-cli
RUN apk add --no-cache openssh-server bash curl && ssh-keygen -A && mkdir -p /run/sshd /root/.ssh /opt/devops-stack && chmod 700 /root/.ssh && echo 'PermitRootLogin prohibit-password' >> /etc/ssh/sshd_config
CMD ["/usr/sbin/sshd", "-D", "-e"]
