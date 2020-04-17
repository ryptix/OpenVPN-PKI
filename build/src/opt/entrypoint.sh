#!/bin/bash

ls -la /opt

# Go in EasyRSA directory
if [ -d /etc/openvpn/EasyRSA-3.0.7 ];then
	rm -rf /opt/EasyRSA-3.0.7
	cd /etc/openvpn/EasyRSA-3.0.7
else
	cp -r /opt/EasyRSA-3.0.7 /etc/openvpn
	cd /etc/openvpn/EasyRSA-3.0.7
fi

cp -r /opt/* /etc/openvpn

if [ -d /etc/openvpn/client ];then
	mkdir /etc/openvpn/client
fi

if [ -f /etc/openvpn/client/base.conf ];then
	cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf /etc/openvpn/client/base.conf
fi

## We are in the EasyRSA directory ##
pwd

# Create vars file if not created
if [ ! -f /etc/openvpn/EasyRSA-3.0.7/vars ];then
	cp ./vars.example vars	
	ls -la

# Test if ALL ENV Variable are SET

	if [ -z "${OPENVPN_COUNTRY}" ];then
		echo "Please Set OPENVPN_COUNTRY"
		exit 2
	else
		echo "Changing EASYRSA_REQ_COUNTRY"
		sed -i 's/#set_var\ EASYRSA_REQ_COUNTRY.*/set_var\ EASYRSA_REQ_COUNTRY\ \"'${OPENVPN_COUNTRY}'\"/g' ./vars
	fi

	if [ -z "${OPENVPN_PROVINCE}" ];then
		echo "Please Set OPENVPN_PROVINCE"
		exit 2	
	else
		sed -i 's,#set_var\ EASYRSA_REQ_PROVINCE.*,set_var\ EASYRSA_REQ_PROVINCE\ \"'${OPENVPN_PROVINCE}'\",g' /etc/openvpn/EasyRSA-3.0.7/vars
	fi

	if [ -z "${OPENVPN_CITY}" ];then
		echo "Please Set OPENVPN_CITY"
		exit 2
	else
		sed -i 's,#set_var\ EASYRSA_REQ_CITY.*,set_var\ EASYRSA_REQ_CITY\ \"'${OPENVPN_CITY}'\",g' /etc/openvpn/EasyRSA-3.0.7/vars
	fi

	if [ -z "${OPENVPN_ORG}" ];then
		echo "Please Set OPENVPN_ORG"
		exit 2
	else
		sed -i 's,#set_var\ EASYRSA_REQ_ORG.*,set_var\ EASYRSA_REQ_ORG\ \"'${OPENVPN_ORG}'\",g' /etc/openvpn/EasyRSA-3.0.7/vars
	fi

	if [ -z "${OPENVPN_EMAIL}" ];then
		echo "Please Set OPENVPN_EMAIL"
		exit 2
	else
		sed -i 's,#set_var\ EASYRSA_REQ_EMAIL.*,set_var\ EASYRSA_REQ_EMAIL\ \"'${OPENVPN_EMAIL}'\",g' /etc/openvpn/EasyRSA-3.0.7/vars
	fi

	if [ -z "${OPENVPN_OU}" ];then
		echo "Please Set OPENVPN_OU"
		exit 2
	else
		sed -i 's,#set_var\ EASYRSA_REQ_OU.*,set_var\ EASYRSA_REQ_OU\ \"'${OPENVPN_OU}'\",g' /etc/openvpn/EasyRSA-3.0.7/vars
	fi

	if [ ! -z "${OPENVPN_KEY}" ];then
		sed -i 's,#set_var\ EASYRSA_KEY_SIZE.*,set_var\ EASYRSA_KEY_SIZE\ '${OPENVPN_KEY}',g' /etc/openvpn/EasyRSA-3.0.7/vars	
	fi
fi

if [ ! -d ./pki ] || [ ! -f ../ca.crt ] && [ ! -f ../${NAME_CA}.crt ] || [ ! -f ../ta.key ] || [ ! -f ../server.crt ] && [ ! -f ../${NAME_SERVER}.crt ] || [ ! -f dh.pem ];then
	echo "#############################################"
	echo "# You're missing important file... Creating #"
	echo "#############################################"
	
	if [ -f ../ca.crt ];then
		rm ../ca.crt
	elif [ -f ../${NAME_CA}.crt ];then
		rm ../${NAME_CA}.crt
	fi
	if [ -f ../ta.key ];then
		rm ../ta.key
	fi
	if [ -f ../server.crt ];then
		rm ../server.crt
	elif [ -f ../${NAME_SERVER}.crt ];then
		rm ../${NAME_SERVER}.crt
	fi
	if [ -f ../dh.pem ];then
		rm ../dh.pem
	fi
	if [ -d ./pki ];then
		rm -fr pki
	fi
	
	echo "Initialisation of pki"
	./easyrsa init-pki 
	mkdir -p /etc/openvpn/EasyRSA-3.0.7/pki/private
	mkdir -p /etc/openvpn/EasyRSA-3.0.7/pki/issued
	echo -e "${PASS_CA}"	

	if [ ! -z "${PASS_CA}" ];then
		echo "building ca"
		python3 ../build-ca.py
	else
		echo "Please set PASS_CA"
	fi

	if [ ! -z "${NAME_CA}" ];then
		cp ./pki/${NAME_CA}.crt ../
	else
		cp ./pki/ca.crt ../
	fi

	if [ ! -z "${PASS_SERVER}" ] && [ ! -z "${PASS_CA}" ];then
		echo "Generating server cert"
		python3 ../gen-req.py
		echo "Signing server cert"
		python3 ../sign-req.py
	else
		echo "Please set PASS_SERVER"
	fi

	if [ ! -z "${NAME_SERVER}" ];then
		cp ./pki/issued/${NAME_SERVER}.crt ../
		cp ./pki/private/${NAME_SERVER}.key ../
	else
		ls -la ./pki/issued 
		cp ./pki/issued/server.crt ../
		cp ./pki/private/server.key ../
	fi
	
	echo "Generating dh.pem"
	./easyrsa gen-dh
	cp ./pki/dh.pem ../
	
	echo "Generating ta.key"
	openvpn --genkey --secret ta.key
	cp ./ta.key ../

fi

if [ -z "${UserPassFile}" ];then
	if [ -f ../${UserPassFile} ];then
		echo "##########################"
		echo "# Generating Users Creds #"
		echo "##########################"
		python3 ../gen_creds.py	
	else
		echo "The ENV variable is set but there is no file"
	fi	
fi
