#!/usr/bin/bash

# WORK IN PROGRESS!

# check if root
if [[ $EUID -ne 0 ]]; then
  echo "You are not root!"
  exit 1
fi

# Installing Metasploit Framework
metasploit_installer () {
  echo "[+] Installing Metasploit Framework.."
  sudo dnf -y install ruby-irb rubygems rubygem-bigdecimal rubygem-rake rubygem-i18n rubygem-bundler
  sudo dnf builddep -y ruby
  sudo dnf -y install ruby-devel libpcap-devel
  sudo gem install rake
  sudo dnf -y install postgresql-server postgresql-devel
  sudo gem install pg
  curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && chmod 755 msfinstall && ./msfinstall
  echo "[+] Metasploit Framework installed."
  echo "[+] Setting up database.."
  echo "sudo -s"
  sudo -s echo "host    msf_database    msf_user      127.0.0.1/32          md5" >> /var/lib/pgsql/data/pg_hba.conf
  postgresql-setup initdb && echo "ctl" && systemctl restart postgresql.service
  whoami
  pwd
  echo "su postgres"
  su postgres -c 'createuser msf_user -P && createdb --owner=msf_user msf_database'

  #su postgres createuser msf_user -P && createdb --owner=msf_user msf_database
  whoami
  msfconsole -q -x "db_status ; db_connect msf_user:nurfuermsfconsole@127.0.0.1:5432/msf_database ; db_status ; exit"
}
metasploit_installer

