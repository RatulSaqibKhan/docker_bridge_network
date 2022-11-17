FROM ubuntu
RUN apt update -y
RUN apt install telnet dnsutils iproute2 net-tools iputils-ping tcpdump -y
CMD ["sleep", "30000"]
