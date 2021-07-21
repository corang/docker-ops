`docker-compose -f ipa.docker-compose.yml -f docker-compose.yml down`
Use to make sure there are no old networks and containers are fresh

`docker-compose -f ipa.docker-compose.yml -f docker-compose.yml up --no-start`
Create containers and networks but do *not* start them

`docker-compose -f ipa.docker-compose.yml -f docker-compose.yml start ntp`
Start the NTP server

`docker-compose -f ipa.docker-compose.yml -f docker-compose.yml start ipa`
Start the IPA/LDAP Server

`docker-compose -f ipa.docker-compose.yml -f docker-compose.yml logs -f`
Follow the logs until IPA is setup
Log in to IPA to make sure it's working

`docker-compose -f ipa.docker-compose.yml -f docker-compose.yml start gitlab`
Once IPA is running start gitlab and see if the LDAP handshake is successful

ldapsearch -x -b "cn=users,cn=accounts,dc=cspts,dc=xpi" -H ldap://139.241.255.10 -D "uid=admin,cn=users,cn=accounts,dc=cspts,dc=xpi" -W