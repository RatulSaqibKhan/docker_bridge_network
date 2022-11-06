FROM ubuntu
RUN apt update -y
RUN apt install telnet dnsutils iproute2 net-tools iputils-ping -y
CMD ["sleep", "30000"]
