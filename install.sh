#!/bin/bash

txtund=$(tput sgr 0 1)          # Underline
txtbld=$(tput bold)             # Bold
bldred=${txtbld}$(tput setaf 1) #  red
bldgre=${txtbld}$(tput setaf 2) #  green
bldblu=${txtbld}$(tput setaf 4) #  blue
bldwht=${txtbld}$(tput setaf 7) #  white
bldyel=${txtbld}$(tput setaf 11) #  yellow
txtrst=$(tput sgr0)             # Reset
info=${bldyel}*${txtrst}        # Feedback
pass=${bldblu}*${txtrst}
warn=${bldred}*${txtrst}
ques=${bldblu}?${txtrst}

function echoblue () {
  echo "${bldblu}$1${txtrst}"
}
function echored () {
  echo "${bldred}$1${txtrst}"
}
function echogreen () {
  echo "${bldgre}$1${txtrst}"
}
function echoyellow () {
  echo "${bldyel}$1${txtrst}"
}

#atribui configuraçao
sed_configuracao() {
	orig=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 1 | head -n 1)
	origparm=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 3 | head -n 1)
		if [[ -z $origparm ]];then
			origparm=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 2 | head -n 1)
		fi
	dest=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 1 | head -n 1)
	destparm=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 3 | head -n 1)
		if [[ -z $destparm ]];then
			destparm=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 2 | head -n 1)
		fi
case ${dest} in
	\#${orig})
			sed -i "/^$dest.*$destparm/c\\${1}" $2
		;;
	\;${orig})
			sed -i "/^$dest.*$destparm/c\\${1}" $2
		;;
	${orig})
			if [[ $origparm != $destparm ]]; then
				sed -i "/^$orig/c\\${1}" $2
				else
					if [[ -z $(grep '[A-Z\_A-ZA-Z]$origparm' $2) ]]; then
						fullorigparm3=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 3 | head -n 1)
						fullorigparm4=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 4 | head -n 1)
						fullorigparm5=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 5 | head -n 1)
						fulldestparm3=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 3 | head -n 1)
						fulldestparm4=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 4 | head -n 1)
						fulldestparm5=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 5 | head -n 1)
						sed -i "/^$dest.*$fulldestparm3\ $fulldestparm4\ $fulldestparm5/c\\$orig\ \=\ $fullorigparm3\ $fullorigparm4\ $fullorigparm5" $2
					fi
			fi
		;;
		*)
			echo ${1} >> $2
		;;
	esac
}

RELEASE=$(cat /etc/lsb-release | grep DISTRIB_CODENAME | cut -c18-30)

clear
case "$RELEASE" in
    focal)
        echoyellow "É UBUNTU 20.04 FOCAL"
	sleep 2
    ;;
    jammy)
        echoyellow "É UBUNTU 22.04 JAMMY"
	sleep 2
    ;;
		noble)
        echoyellow "É UBUNTU 24.04 NOBLE"
	sleep 2
    ;;
    *)
        echored "RELEASE INVALIDA"
	sleep 2
	exit
    ;;
esac
clear

echoyellow "CONFIGURANDO CANAIS DE SOFTWARE DO POSTGRESQL"
sleep 2
case "$RELEASE" in
    focal)
    touch /etc/apt/sources.list.d/pgdg.list
    echo "deb http://apt.postgresql.org/pub/repos/apt/ ${RELEASE}-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list
    apt-key adv --keyserver keyserver.ubuntu.com --recv 7FCC7D46ACCC4CF8
    ;;
    jammy)
    touch /etc/apt/sources.list.d/pgdg.list
    echo "deb http://apt.postgresql.org/pub/repos/apt/ ${RELEASE}-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list
    apt-get --force-yes --yes install curl ca-certificates gnupg
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg
    ;;
    noble)
    touch /etc/apt/sources.list.d/pgdg.list
    echo "deb http://apt.postgresql.org/pub/repos/apt/ ${RELEASE}-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list
    apt-get --force-yes --yes install curl ca-certificates gnupg
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg
    ;;
    *)
    exit
    ;;
esac
clear

clear
echoyellow "AJUSTANDO REPOSITÓRIOS"
sleep 2
sed -i 's/\/archive/\/br.archive/g' /etc/apt/sources.list
sed -i 's/\/[a-z][a-z].archive/\/br.archive/g' /etc/apt/sources.list
sed -i 's/\/archive/\/br.archive/g' /etc/apt/sources.list.d/ubuntu.sources
sed -i 's/\/[a-z][a-z].archive/\/br.archive/g' /etc/apt/sources.list.d/ubuntu.sources

clear
echoyellow "AJUSTANDO IDIOMA"
sleep 2
apt-get update
apt-get --force-yes --yes install language-pack-gnome-pt language-pack-pt-base myspell-pt myspell-pt wbrazilian wportuguese software-properties-common gettext

clear
echoyellow "INSTALANDO UNZIP"
sleep 2
apt-get update
apt-get --force-yes --yes install unzip

clear
echoyellow "INSTALANDO DEPENDÊNCIAS"
sleep 2
apt-get update
apt-get --force-yes --yes install libgbm-dev wget fontconfig locales libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libnss3 lsb-release xdg-utils build-essential

clear
echoyellow "INSTALANDO CURL E GIT"
sleep 2
apt-get update
apt-get --force-yes --yes install curl git

clear
echoyellow "INSTALANDO NODEJS"
sleep 2
curl -sL https://deb.nodesource.com/setup_16.x -o nodesource_setup.sh
bash nodesource_setup.sh
apt-get --force-yes --yes install nodejs

clear
echoyellow "INSTALANDO POSTGRESQL"
sleep 2
apt-get update
apt-get --force-yes --yes install postgresql postgresql-client

clear
echoyellow "CONFIGURANDO POSTGRESQL"
sleep 2

# Liberando autenticao
sed -i 's/md5$/trust/g' /etc/postgresql/$(ls /etc/postgresql | tail -n 1)/main/pg_hba.conf
sed -i 's/peer$/trust/g' /etc/postgresql/$(ls /etc/postgresql | tail -n 1)/main/pg_hba.conf
sed -i 's/scram-sha-256/trust/g' /etc/postgresql/$(ls /etc/postgresql | tail -n 1)/main/pg_hba.conf

PGPATH=/etc/postgresql/$(ls /etc/postgresql | tail -n 1)/main/postgresql.conf
sed_configuracao "listen_addresses = '*'" "$PGPATH"
sed_configuracao "max_connections = 20" "$PGPATH"

/etc/init.d/postgresql restart

clear
echoyellow "CRIANDO USUÁRIOS"
sleep 2
psql -U postgres -c "CREATE ROLE whatsapp WITH SUPERUSER LOGIN PASSWORD 'whatsapp';"

clear
echoyellow "CRIANDO DATA-BASE"
sleep 2
psql -U postgres -c "CREATE DATABASE whatsapp OWNER whatsapp;"

clear
echoyellow "INSTALANDO APACHE"
sleep 2
apt-get update
sudo apt-get --force-yes --yes install apache2

clear
echoyellow "CLONANDO REPOSITÓRIO DO WHATICKET"
sleep 2
cd /var/www/html
git clone https://github.com/unkbot/whaticket-free.git

clear
echoyellow "CONFIGURANDO .ENV"
sleep 2
IP=$(ip addr show | grep 'inet ' | grep brd | tr -s ' ' '|' | cut -d '|' -f 3 | cut -d '/' -f 1 | head -n 1)
CHAVE=$(printf '%s' "$data" | openssl dgst -sha256 -hmac dummy_secret -binary | openssl base64 -e -A | sed 's/+/-/g; s:/:_:g; s/=\+$//')
cat << ENV > /var/www/html/whaticket-free/backend/.env
NODE_ENV=
BACKEND_URL=http://${IP}
FRONTEND_URL=http://${IP}
PROXY_PORT=443
PORT=8080

DB_DIALECT=postgres
DB_HOST=localhost
DB_USER=whatsapp
DB_PASS=whatsapp
DB_NAME=whatsapp

JWT_SECRET=${CHAVE}
JWT_REFRESH_SECRET=${CHAVE}

REDIS_URI=
REDIS_OPT_LIMITER_MAX=1
REDIS_OPT_LIMITER_DURATION=3000

ENV

cat << ENV > /var/www/html/whaticket-free/frontend/.env
REACT_APP_BACKEND_URL = http://${IP}:8080/
REACT_APP_HOURS_CLOSE_TICKETS_AUTO =
ENV

clear
echoyellow "EXECUTANDO NPM E PM2"
sleep 2
cd /var/www/html/whaticket-free/backend
sudo npm install
if [[ $? -eq 1 ]]; then
	sudo npm audit fix
fi

if [[ $? -eq 1 ]]; then
	sudo npm audit fix --force
fi
sudo npm run build
sudo npm run db:migrate
sudo npm run db:seed
cd /var/www/html/whaticket-free/frontend
sudo npm install
if [[ $? -eq 1 ]]; then
	sudo npm audit fix
fi

if [[ $? -eq 1 ]]; then
	sudo npm audit fix --force
fi
sudo npm run build
sudo npm install -g pm2
cd /var/www/html/whaticket-free/backend
sudo pm2 start dist/server.js --name whaticket-backend
cd /var/www/html/whaticket-free/frontend
sudo pm2 start server.js --name whaticket-frontend
sudo pm2 startup ubuntu -u root
sudo pm2 save --force

clear
echoyellow "CONFIGURANDO APACHE"
sleep 2
sudo cat << APADEF > /etc/apache2/sites-available/whatsapp.conf
<VirtualHost *:80>

      <Location />
          Require all granted
          ProxyPass http://127.0.0.1:3333/
          ProxyPassReverse http://127.0.0.1:3333/
      </Location>

</VirtualHost>
APADEF

sudo a2enmod rewrite proxy proxy_http proxy_balancer lbmethod_byrequests
sudo a2dissite 000-default
sudo chown www-data -R /var/www/html
sudo chmod 775 -R /var/www/html
sudo a2ensite whatsapp
sudo /etc/init.d/apache2 restart

clear
echogreen "INSTALAÇÃO TERMINADA,WHATICKET INSTALADO,ACESSE ATRAVÉS DE SEU NAVEGADOR WEB EM http://$(ip addr show | grep 'inet ' | grep brd | tr -s ' ' '|' | cut -d '|' -f 3 | cut -d '/' -f 1 | head -n 1) USUÁRIO:admin@whaticket.com SENHA:admin"