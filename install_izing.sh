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

function popular_base(){
  RET=0
  sudo /etc/init.d/postgresql restart
  sudo psql -U postgres -c "DROP DATABASE izing;"
  sudo psql -U postgres -c "CREATE DATABASE izing OWNER izing;"
  cd /var/www/html/izing/backend
  sudo npm run db:migrate
  if [[ $? -eq 1 ]]; then
  	RET=$((${RET} + 1))
  fi
  sudo npm run db:seed
  if [[ $? -eq 1 ]]; then
  	RET=$((${RET} + 1))
  fi
  echo ${RET}
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
echoyellow "AJUSTANDO TIMEZONE"
sleep 2
sudo timedatectl set-timezone America/Sao_Paulo

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
echoyellow "INSTALANDO GOOGLE CHROME"
sleep 2
cd /tmp
sudo rm -rf google-chrome-stable_current_amd64.deb
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
while [[ $? -eq 1 ]]; do
  sudo rm -rf google-chrome-stable_current_amd64.deb
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
done
sudo dpkg -i google-chrome-stable_current_amd64.deb
sudo apt-get -f --force-yes --yes install

clear
echoyellow "INSTALANDO DEPENDÊNCIAS"
sleep 2
apt-get update
sudo apt-get --force-yes --yes install apt-transport-https ffmpeg ufw fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 ca-certificates software-properties-common curl libgbm-dev wget unzip fontconfig locales libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libnss3 lsb-release xdg-utils build-essential libxshmfence-dev

clear
echoyellow "ATUALIZNDO REGRAS DE FIREWALL"
sleep 2
sudo ufw allow 3000/tcp
sudo ufw allow 80/tcp
sudo ufw allow 9000/tcp
sudo ufw allow 4000/tcp

clear
echoyellow "INSTALANDO CURL E GIT"
sleep 2
apt-get update
apt-get --force-yes --yes install curl git

clear
echoyellow "INSTALANDO REDIS"
sleep 2
apt-get update
apt-get --force-yes --yes install redis

clear
echoyellow "INSTALANDO NODEJS"
sleep 2
curl -sL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh
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
psql -U postgres -c "CREATE ROLE izing WITH SUPERUSER LOGIN PASSWORD 'izing';"

clear
echoyellow "CRIANDO DATABASE"
sleep 2
psql -U postgres -c "CREATE DATABASE izing OWNER izing;"

clear
echoyellow "INSTALANDO APACHE"
sleep 2
apt-get update
sudo apt-get --force-yes --yes install apache2

clear
echoyellow "ATUALIZANDO UBUNTU"
sleep 2
apt-get update
sudo apt-get --force-yes --yes upgrade

clear
echoyellow "CLONANDO REPOSITÓRIO DO IZING"
sleep 2
cd /var/www/html
sudo rm -rf izing
sudo git clone https://github.com/cleitonme/izing.open.io.git izing
while [[ $? -ne 0 ]]; do
  sudo rm -rf izing
  sudo git clone https://github.com/cleitonme/izing.open.io.git izing
done

clear
echoyellow "CONFIGURANDO .ENV"
sleep 2
IP=$(ip addr show | grep 'inet ' | grep brd | tr -s ' ' '|' | cut -d '|' -f 3 | cut -d '/' -f 1 | head -n 1)
CHAVE=$(openssl rand -base64 32)
CHAVE2=$(openssl rand -base64 32)
sudo cp /var/www/html/izing/.env.example /var/www/html/izing/.env
sudo cp /var/www/html/izing/backend/.env.example /var/www/html/izing/backend/.env
sudo sed -i "s|/localhost:3003|/${IP}|g" /var/www/html/izing/backend/.env
sudo sed -i "s|/localhost|/${IP}|g" /var/www/html/izing/backend/.env
sudo sed -i "s|JWT_SECRET=DPHmNRZWZ4isLF9vXkMv1QabvpcA80Rc|JWT_SECRET=${CHAVE}|g" /var/www/html/izing/backend/.env
sudo sed -i "s|JWT_REFRESH_SECRET=EMPehEbrAdi7s8fGSeYzqGQbV5wrjH4i|JWT_REFRESH_SECRET=${CHAVE2}|g" /var/www/html/izing/backend/.env
sudo sed -i "s|PROXY_PORT=3100|PROXY_PORT=3000|g" /var/www/html/izing/backend/.env
sudo sed -i "s|#CHROME_BIN=/usr/bin/google-chrome-stable|CHROME_BIN=/usr/bin/google-chrome-stable|g" /var/www/html/izing/backend/.env
sudo sed -i "s|POSTGRES_HOST=host.docker.internal|POSTGRES_HOST=localhost|g" /var/www/html/izing/backend/.env
sudo sed -i "s|POSTGRES_USER=postgres|POSTGRES_USER=izing|g" /var/www/html/izing/backend/.env
sudo sed -i "s|POSTGRES_PASSWORD=postgres|POSTGRES_PASSWORD=izing|g" /var/www/html/izing/backend/.env
sudo sed -i "s|IO_REDIS_SERVER=izing-redis|IO_REDIS_SERVER=127.0.0.1|g" /var/www/html/izing/backend/.env

cat << ENV > /var/www/html/izing/frontend/.env
VUE_URL_API='http://${IP}:3000'
VUE_FACEBOOK_APP_ID='23156312477653241'
ENV

cat << ENV > /var/www/html/izing/frontend/server.js
// simple express server to run frontend production build;
const express = require('express')
const path = require('path')
const app = express()
app.use(express.static(path.join(__dirname, 'dist/pwa')))
app.get('/*', function (req, res) {
  res.sendFile(path.join(__dirname, 'dist/pwa', 'index.html'))
})
app.listen(4000)
ENV

clear
echoyellow "EXECUTANDO NPM E PM2"
sleep 2
cd /var/www/html/izing
sudo npm install --force
if [[ $? -eq 1 ]]; then
	sudo npm audit fix
fi

if [[ $? -eq 1 ]]; then
	sudo npm audit fix --force
fi

cd /var/www/html/izing/backend
sudo npm install --force
if [[ $? -eq 1 ]]; then
	sudo npm audit fix
fi

if [[ $? -eq 1 ]]; then
	sudo npm audit fix --force
fi
sudo npm run build
SAIDA=1
while [[ ${SAIDA} -gt 0 ]]; do
  SAIDA=$(popular_base)
done
cd /var/www/html/izing/backend
sudo npm install -g pm2
sudo pm2 stop all
sudo rm .wwebjs_auth -Rf
sudo rm .wwebjs_cache -Rf
sudo npm r whatsapp-web.js
sudo npm i whatsapp-web.js@^1.24.0
sudo pm2 restart all
sudo pm2 start dist/server.js --name izing-backend
sudo pm2 startup ubuntu -u root
cd /var/www/html/izing/frontend
sudo npm install --force
if [[ $? -eq 1 ]]; then
	sudo npm audit fix
fi

if [[ $? -eq 1 ]]; then
	sudo npm audit fix --force
fi
sudo npm i @quasar/cli
sudo npm run build
sudo pm2 start server.js --name izing-frontend
sudo pm2 save --force

clear
echoyellow "CONFIGURANDO APACHE"
sleep 2
sudo cat << APADEF > /etc/apache2/sites-available/izing.conf
<VirtualHost *:80>

    <Location />
      Require all granted
      ProxyPass http://${IP}:4000/
      ProxyPassReverse http://${IP}:4000/
    </Location>

</VirtualHost>
APADEF

sudo a2enmod rewrite proxy proxy_http headers proxy_wstunnel
sudo a2dissite 000-default
sudo chown www-data -R /var/www/html
sudo chmod 775 -R /var/www/html
sudo a2ensite izing
sudo /etc/init.d/apache2 restart

clear
echogreen "INSTALAÇÃO TERMINADA,IZING INSTALADO,ACESSE ATRAVÉS DE SEU NAVEGADOR WEB EM http://$(ip addr show | grep 'inet ' | grep brd | tr -s ' ' '|' | cut -d '|' -f 3 | cut -d '/' -f 1 | head -n 1) USUÁRIO:admin@izing.io SENHA:123456"
