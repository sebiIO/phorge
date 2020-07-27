#!/bin/bash

sleep 30

useradd $GIT_USER
usermod -p NP $GIT_USER

cp /var/www/phabric/phabricator/resources/sshd/phabricator-ssh-hook.sh /usr/libexec/phabricator-ssh-hook.sh
sed "s/vcs-user/$GIT_USER/g" /usr/libexec/phabricator-ssh-hook.sh
sed "s/\/path\/to\/phabricator/\/var\/www\/phabric\/phabricator/g" /usr/libexec/phabricator-ssh-hook.sh
chmod 755 /usr/libexec/phabricator-ssh-hook.sh

cp /var/www/phabric/phabricator/resources/sshd/sshd_config.phabricator.example /etc/ssh/sshd_config.phabricator
sed "s/vcs-user/$GIT_USER/g" /etc/ssh/sshd_config.phabricator
sed "s/2222/$SSH_PORT/g" /etc/ssh/sshd_config.phabricator

#SSH Configuration
/var/www/phabric/phabricator/bin/config set diffusion.ssh-port $SSH_PORT
/var/www/phabric/phabricator/bin/config set diffusion.ssh-user $GIT_USER
/var/www/phabric/phabricator/bin/config set files.enable-imagemagick true
#DB configuration
/var/www/phabric/phabricator/bin/config set mysql.host $MYSQL_HOST
/var/www/phabric/phabricator/bin/config set mysql.port $MYSQL_PORT
/var/www/phabric/phabricator/bin/config set mysql.user $MYSQL_USER
/var/www/phabric/phabricator/bin/config set mysql.pass $MYSQL_PASSWORD
#Large file storage configuration
[ ! -z "$MINIO_SERVER" ]
then
    /var/www/phabric/phabricator/bin/config set storage.s3.bucket $MINIO_SERVER
    /var/www/phabric/phabricator/bin/config set amazon-s3.secret-key $MINIO_SERVER_SECRET_KEY
    /var/www/phabric/phabricator/bin/config set amazon-s3.access-key $MINIO_SERVER_ACCESS_KEY
    /var/www/phabric/phabricator/bin/config set amazon-s3.endpoint $MINIO_SERVER:$MINIO_PORT
    # /var/www/phabric/phabricator/bin/config set amazon-s3.region us-west-1
fi

# Update base uri
/var/www/phabric/phabricator/bin/config set phabricator.base-uri "http://$BASE_URI/"
sed "s/  server_name phabricator.local;/  server_name $BASE_URI;/g" /etc/nginx/sites-available//phabricator.conf > /etc/nginx/sites-available/phabricator.conf
#sed "s/    return 301 \$scheme:\/\/phabricator.local$request_uri;"
#general parameters configuration
/var/www/phabric/phabricator/bin/config set pygments.enabled true
#setup db in not exists
/var/www/phabric/phabricator/bin/storage upgrade --force
#start supervisord
/usr/bin/supervisord -n -c /etc/supervisord.conf