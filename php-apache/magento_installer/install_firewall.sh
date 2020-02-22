
#!/bin/bash


apt install ufw -y
ufw allow ssh
ufw allow https
ufw allow http
ufw enable
