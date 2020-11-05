#!/bin/sh

cp /opt/* /etc/openvpn

if [ ! -d /etc/openvpn/easy-rsa ];then
    mkdir /etc/openvpn/easy-rsa
fi

ln -s /usr/share/easy-rsa/* /etc/openvpn/easy-rsa/

cd /etc/openvpn/easy-rsa

# Create user directory
if [ -d /etc/openvpn/client ];then
	mkdir /etc/openvpn/client
fi

# Copy base config for user config
if [ -f /etc/openvpn/client/base.conf ];then
	cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf /etc/openvpn/client/base.conf
fi

# Create vars file if not created
if [ ! -f /etc/openvpn/easy-rsa/vars ];then
# Test if ALL ENV Variable are SET
    cp /etc/openvpn/easy-rsa/vars.example /etc/openvpn/easy-rsa/vars    

	if [ -z "${OPENVPN_COUNTRY}" ];then
		echo "Please Set OPENVPN_COUNTRY"
		exit 2
	else
		echo "Changing EASYRSA_REQ_COUNTRY"
		sed -i 's/#set_var\ EASYRSA_REQ_COUNTRY.*/set_var\ EASYRSA_REQ_COUNTRY\ \"'${OPENVPN_COUNTRY}'\"/g' /etc/openvpn/easy-rsa/vars
	fi

	if [ -z "${OPENVPN_PROVINCE}" ];then
		echo "Please Set OPENVPN_PROVINCE"
		exit 2	
	else
		echo "Changing EASYRSA_REQ_PROVINCE"
		sed -i 's,#set_var\ EASYRSA_REQ_PROVINCE.*,set_var\ EASYRSA_REQ_PROVINCE\ \"'${OPENVPN_PROVINCE}'\",g' /etc/openvpn/easy-rsa/vars
	fi

	if [ -z "${OPENVPN_CITY}" ];then
		echo "Please Set OPENVPN_CITY"
		exit 2
	else
		echo "Changing EASYRSA_REQ_CITY"
		sed -i 's,#set_var\ EASYRSA_REQ_CITY.*,set_var\ EASYRSA_REQ_CITY\ \"'${OPENVPN_CITY}'\",g' /etc/openvpn/easy-rsa/vars
	fi

	if [ -z "${OPENVPN_ORG}" ];then
		echo "Please Set OPENVPN_ORG"
		exit 2
	else
		echo "Changing EASYRSA_REQ_ORG"
		sed -i 's,#set_var\ EASYRSA_REQ_ORG.*,set_var\ EASYRSA_REQ_ORG\ \"'${OPENVPN_ORG}'\",g' /etc/openvpn/easy-rsa/vars
	fi

	if [ -z "${OPENVPN_EMAIL}" ];then
		echo "Please Set OPENVPN_EMAIL"
		exit 2
	else
		echo "Changing EASYRSA_REQ_EMAIL"
		sed -i 's,#set_var\ EASYRSA_REQ_EMAIL.*,set_var\ EASYRSA_REQ_EMAIL\ \"'${OPENVPN_EMAIL}'\",g' /etc/openvpn/easy-rsa/vars
	fi

	if [ -z "${OPENVPN_OU}" ];then
		echo "Please Set OPENVPN_OU"
		exit 2
	else
		echo "Changing EASYRSA_REQ_OU"
		sed -i 's,#set_var\ EASYRSA_REQ_OU.*,set_var\ EASYRSA_REQ_OU\ \"'${OPENVPN_OU}'\",g' /etc/openvpn/easy-rsa/vars
	fi

	if [ ! -z "${OPENVPN_KEY}" ];then
		sed -i 's,#set_var\ EASYRSA_KEY_SIZE.*,set_var\ EASYRSA_KEY_SIZE\ '${OPENVPN_KEY}',g' /etc/openvpn/easy-rsa/vars	
	fi
fi

# Test if all necessary file are created
# If some file are missing it delete everything and recreate ALL
if [ ! -d /etc/openvpn/easy-rsa/pki ] || [ ! -f /etc/openvpn/ca.crt ] && [ ! -f /etc/openvpn/${NAME_CA}.crt ] || [ ! -f /etc/openvpn/ta.key ] || [ ! -f /etc/openvpn/server.crt ] && [ ! -f /etc/openvpn/${NAME_SERVER}.crt ] || [ ! -f /etc/openvpn/dh.pem ];then
	echo " -- You're missing important file... Creating"
	
	if [ -f /etc/openvpn/ca.crt ];then
		rm /etc/openvpn/ca.crt
	elif [ -f /etc/openvpn/${NAME_CA}.crt ];then
		rm /etc/openvpn/${NAME_CA}.crt
	fi
	
    if [ -f /etc/openvpn/ta.key ];then
		rm /etc/openvpn/ta.key
	fi
	
    if [ -f /etc/openvpn/server.crt ];then
		rm /etc/openvpn/server.crt
	elif [ -f /etc/openvpn/${NAME_SERVER}.crt ];then
		rm /etc/openvpn/${NAME_SERVER}.crt
	fi

	if [ -f /etc/openvpn/dh.pem ];then
		rm /etc/openvpn/dh.pem
	fi
	
    if [ -d /etc/openvpn/easy-rsa/pki ];then
		rm -rf /etc/openvpn/easy-rsa/pki
	fi
	
	echo "Initialisation of pki"
    # initialise the PKI
	/etc/openvpn/easy-rsa/easyrsa init-pki
	
    # Build the Certificat Authority
    echo -e "${PASS_CA}"	
	if [ ! -z "${PASS_CA}" ];then
		echo "building ca"
		python3 /etc/openvpn/build-ca.py
	else
		echo "Please set PASS_CA"
	fi

    # Copy the CA to /etc/openvpn
	if [ ! -z "${NAME_CA}" ];then
		cp /etc/openvpn/easy-rsa/pki/${NAME_CA}.crt /etc/openvpn/
	else
		cp /etc/openvpn/easy-rsa/pki/ca.crt /etc/openvpn/
	fi

    # Create Server Certificat
	if [ ! -z "${PASS_SERVER}" ] && [ ! -z "${PASS_CA}" ];then
		echo "Generating server cert"
		python3 /etc/openvpn/gen-req.py
		echo "Signing server cert"
		python3 /etc/openvpn/sign-req.py
	else
		echo "Please set PASS_SERVER"
	fi

    # Copy the Server Cert to /etc/openvpn
	if [ ! -z "${NAME_SERVER}" ];then
		cp /etc/openvpn/easy-rsa/pki/issued/${NAME_SERVER}.crt /etc/openvpn/
		cp /etc/openvpn/easy-rsa/pki/private/${NAME_SERVER}.key /etc/openvpn/
	else
		ls -la /etc/openvpn/easy-rsa/pki/issued 
		cp /etc/openvpn/easy-rsa/pki/issued/server.crt /etc/openvpn/
		cp /etc/openvpn/easy-rsa/pki/private/server.key /etc/openvpn/
	fi
	
	echo "Generating dh.pem"
    # Generate gen-dh and copy it to /etc/openvpn
    /etc/openvpn/easy-rsa/easyrsa gen-dh
	cp /etc/openvpn/easy-rsa/pki/dh.pem /etc/openvpn/
	
	echo "Generating ta.key"
    # Generate ta.key and copy it to /etc/openvpn
	openvpn --genkey --secret /etc/openvpn/ta.key

fi

if [ ! -z "${UserPassFile}" ];then
	if [ -f /etc/openvpn/${UserPassFile} ];then
		echo "Generating Users Creds"
		#python3 ../gen_creds.py	
	else
		echo "No file found to create users from."
	fi	
fi
