import pexpect
import os

PASS = os.environ.get("PASS_CA")

NAME = os.environ.get("NAME_CA")
if NAME == None :
    NAME = "ca"

#print("Creating PKI")
#pexpect.run("/etc/openvpn/EasyRSA-3.0.7/easyrsa init-pki")

print("Launching Script FOR CA")
child = pexpect.spawn("/etc/openvpn/EasyRSA-3.0.7/easyrsa build-ca")
print("Child Spawned")
child.expect("Passphrase")
print("Passphrase Expected")
child.send(PASS+"\n")
print("Send PASS")
child.expect("Passphrase")
print("Passphrase Expected")
child.send(PASS+"\n")
print("Send PASS")
child.expect("Common Name")
print("Name Expected")
child.send(NAME+"\n")
print("Send NAME")
child.expect(pexpect.EOF)
print("END Expected")
child.close()
print("Program ENDS")
