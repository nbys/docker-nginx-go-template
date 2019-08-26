#! /usr/bin/env bash
# THIS IS ONLY FOR DEV USAGE!!!!
echo -e "\x1B[101mDo not use this script in production! Never use self-signed certs in production!\x1B[0m"

# 1. Certificates used for ouside connections (simulate lego result)
echo -e "\x1B[42mCreate certificates for outgoing connection (in real life: certbot or lego)\x1B[0m"
echo -e "\x1B[42mGenerate server private key\x1B[0m"
openssl genrsa -out .ssl/server.key 2048
openssl ecparam -genkey -name secp384r1 -out .ssl/server.key

echo -e "\x1B[42mGenerate server public key\x1B[0m"
# Generation of self-signed(x509) public key (PEM-encodings .pem|.crt) based on the private (.key)
openssl req -new -x509 -sha256 -key .ssl/server.key -out .ssl/server.crt -days 3650

# 2. Certificates used for internal proxing 
# Create the CA Key and Certificate for signing Client Certs
echo -e "\x1B[42mCreate certificates for internal proxy upstream\x1B[0m"
echo -e "\x1B[42mGenerate CA authority cert and key\x1B[0m"
openssl genrsa -des3 -out .certs/ca.key 4096
openssl req -new -x509 -days 3650 -key .certs/ca.key -out .certs/ca.crt


# Create the Server Key, CSR, and Certificate
echo -e "\x1B[42mCreate upstream services key (server)\x1B[0m"
openssl genrsa -des3 -out .certs/server/server.key 1024
openssl req -new -key .certs/server/server.key -out .certs/server/server.csr

# We're self signing our own server cert here.  This is a no-no in production.
echo -e "\x1B[42mSign upstream services cert (server)\x1B[0m"
openssl x509 -req -days 3650 -in .certs/server/server.csr -CA .certs/ca.crt -CAkey .certs/ca.key -set_serial 01 -out .certs/server/server.crt

# # Create the Client Key and CSR
echo -e "\x1B[42mGenerate client key and cert (nginx)\x1B[0m"
openssl genrsa -des3 -out .certs/client/client.key 1024
openssl req -new -key .certs/client/client.key -out .certs/client/client.csr

# # Sign the client certificate with our CA cert.  Unlike signing our own server cert, this is what we want to do.
# # Serial should be different from the server one, otherwise curl will return NSS error -8054
echo -e "\x1B[42mSign client key and cert (nginx)\x1B[0m" 
openssl x509 -req -days 3650 -in .certs/client/client.csr -CA .certs/ca.crt -CAkey .certs/ca.key -set_serial 02 -out .certs/client/client.crt


echo -e "\x1B[42mVerify certificates (upstream server and client)\x1B[0m"
# Verify Server Certificate
openssl verify -purpose sslserver -CAfile .certs/ca.crt .certs/server/server.crt

# Verify Client Certificate
openssl verify -purpose sslclient -CAfile .certs/ca.crt .certs/client/client.crt

# Convert to PEM
echo -e "\x1B[42mConvert to PEM\x1B[0m"
openssl x509 -in .certs/ca.crt -out .certs/ca.cert.pem -outform PEM
cat .ssl/server.crt .ssl/server.key > .ssl/server.key.pem
cat .certs/server/server.crt .certs/server/server.key > .certs/server/server.key.pem
cat .certs/client/client.crt .certs/client/client.key > .certs/client/client.key.pem
openssl x509 -in .ssl/server.crt -out .ssl/server.cert.pem -outform PEM
openssl x509 -in .certs/client/client.crt -out .certs/client/client.cert.pem -outform PEM

echo -e "\x1B[101mCreate unencrypted keys for golang server and nginx. Password: secret. Change script if you use diffrent password in previous step\x1B[0m"
openssl rsa -in .certs/server/server.key.pem -out .certs/server/server.key.unencrypted.pem -passin pass:secret
openssl rsa -in .certs/client/client.key.pem -out .certs/client/client.key.unencrypted.pem -passin pass:secret
