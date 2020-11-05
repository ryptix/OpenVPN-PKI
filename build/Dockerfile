FROM debian:buster-slim
ADD ./src /
WORKDIR /opt
RUN apt update &&\
    apt -y upgrade &&\
	apt install -y easy-rsa openvpn wget easy-rsa tar python3 python3-pip

RUN pip3 install pexpect

RUN chmod +x ./entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]
