from ubuntu:12.04
maintainer Vo Minh Thu <noteed@gmail.com>

run echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list # 20103-08-24
run apt-get update
run apt-get install -q -y language-pack-en
run update-locale LANG=en_US.UTF-8

#run echo "mail" > /etc/hostname
#add etc-hosts.txt /etc/hosts
#run chown root:root /etc/hosts

run apt-get install -q -y vim

# Install Postfix.
run echo "postfix postfix/main_mailer_type string Internet site" > preseed.txt
run echo "postfix postfix/mailname string mail.example.com" >> preseed.txt
# Use Mailbox format.
run debconf-set-selections preseed.txt
run DEBIAN_FRONTEND=noninteractive apt-get install -q -y postfix

run postconf -e myhostname=mail.politkz.com
run postconf -e mydestination="mail.politkz.com, politkz.com, local.host, localhost.localdomain, localhost"
run postconf -e mail_spool_directory="/var/spool/mail/"
run postconf -e mailbox_command=""
run postconf -e mynetworks="172.17.0.0/16 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128"

# Add a local user to receive mail at someone@example.com, with a delivery directory
# (for the Mailbox format).
run useradd -s /bin/bash support
run mkdir /var/spool/mail/support
run chown support:mail /var/spool/mail/support

add etc-aliases.txt /etc/aliases
run chown root:root /etc/aliases
run newaliases

add virtual.txt /etc/postfix/virtual
run chown root:root /etc/postfix/virtual

run echo "virtual_alias_maps = hash:/etc/postfix/virtual" >> /etc/postfix/main.cf
run postmap /etc/postfix/virtual

# Use syslog-ng to get Postfix logs (rsyslog uses upstart which does not seem
# to run within Docker).
run apt-get install -q -y syslog-ng

expose 25
cmd ["sh", "-c", "service syslog-ng start ; service postfix start ; tail -F /var/log/mail.log"]
