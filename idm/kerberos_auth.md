# Kerberos Authentication

## Initial authentication

Obtaining a TGT follows these steps:

1. The system the user is logging into sends a request for a TGT for the user to the KDC.

2. The KDC responds with a new TGT, encrypted with the user's password.

3.  If the TGT can be decrypted, the login succeeds, and the TGT is stored.

## Authenticating with a ticket
Once a TGT has been obtained, a user can connect to other Kerberos-enabled services without having to type a password. Authentication happens according to these steps:

1. The client sends a request to the KDC for a service ticket for the principal of the service he or she wishes to authenticate to.

2. The KDC responds with two copies of the same service ticket: one encrypted with the user's TGT, the other encrypted with the password for the service.

3. The client decrypts the version encrypted with the TGT, and uses the decrypted ticket to encrypt a timestamp.

4. The client sends the encrypted timestamp, and the ticket encrypted with the service password, to the service.

5. The service decrypts the service ticket, and uses it to decrypt the timestamp. If that succeeds, and the timestamp is less than two minutes old, the user is authenticated.
