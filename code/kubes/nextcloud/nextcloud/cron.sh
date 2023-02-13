sudo k3s kubectl exec --stdin --tty -n nextcloud deployment/nextcloud-server -c nextcloud -- apk add sudo
sudo k3s kubectl exec --stdin --tty -n nextcloud deployment/nextcloud-server -c nextcloud -- sudo -u www-data php -d memory_limit=1024M ./cron.php
