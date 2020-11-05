import pexpect
import os 

FILE = os.environ.get("UserPassFile")
PASS = os.environ.get("PASS_CA")
NAME_SERVER = os.environ.get("NAME_SERVER")
NAME = os.environ.get("NAME_CA")
if NAME == None :
    NAME = "ca"

file = open(FILE)
lines = file.readlines()

for line in lines:
    line = line.strip("\n")
    creds = line.split(":")
    
    print("username = " + creds[0] + " password = " + creds[1])
    
    pexpect.run(["mkdir","/etc/openvpn/client/"+creds[0]])

    child = pexpect.spawn("./EasyRSA-3.0.7/easyrsa gen-req " + creds[0])
    child.expect("pass phrase")
    child.send(creds[1]+"\n")
    child.expect("pass phrase")
    child.send(creds[1]+"\n")
    child.expect("common name")
    child.send(creds[0]+"\n")
    child.expect(pexpect.EOF)
    child.close()

    pexpect.run(["cp",("./EasyRSA-3.0.7/pki/private/"+creds[0]+".key"),("/etc/openvpn/client/"+creds[0]+"/")]) 

    child = pexpect.spawn("./EasyRSA-3.0.7/easyrsa sign-req client " + creds[0])
    child.expect("Confirm")
    child.send("yes\n")
    child.expect("pass phrase")
    child.send(PASS + "\n")
    child.expect(pexpect.EOF)
    child.close()

    pexpect.run(["cp", ("./EasyRSA-3.0.7/pki/issued/" + creds[0] + ".crt"),("/etc/openvpn/client/"+creds[0])])
    pexpect.run(["cp", "/etc/openvpn/ta.key",("/etc/openvpn/client/" + creds[0] )])
    pexpect.run(["cp", "/etc/openvpn/"+NAME_CA+".crt" ,("/etc/openvpn/client/" + creds[0] )])
    pexpect.run(["cp", "/etc/openvpn/client/base.conf", ("/etc/openvpn/client/"+creds[0]+"/"+creds[0]+".conf")])
    pexpect.run(["cp", "/etc/openvpn/client/make_config.sh",("/etc/openvpn/client/" + creds[0] + "/")])
    pexpect.run([("/etc/openvpn/client/make_config.sh"),creds[0]])

