FROM debian:buster-slim
ADD ./src /
WORKDIR /opt
RUN apt update && apt -y upgrade &&\
	apt install -y openvpn wget easy-rsa tar python3 python3-pip

RUN wget https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.7/EasyRSA-3.0.7.tgz &&\
	tar xvf ./EasyRSA-3.0.7.tgz
RUN pip3 install pexpect

ENV EASYRSA_PKI /etc/openvpn/EasyRSA-3.0.7/pki

RUN chmod +x ./entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]
