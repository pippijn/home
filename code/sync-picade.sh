#!/bin/sh

set -eux

#for i in 0 1 2 3 4; do
#  rsync -avrP --delete "root@10.100.0.10$i:/etc/wireguard/" "$HOME/code/picade/picade$i/etc/wireguard"
#  rsync -avrP --delete "root@10.100.0.10$i:/etc/network/interfaces.d/" "$HOME/code/picade/picade$i/etc/network/interfaces.d"
#done

#rsync -avrP --delete "pi@10.100.0.100:/home/pi/" "$HOME/code/picade/home/pi"

#for i in 0 1 2 3 4; do
#  rsync -avrP --delete --chown root:root "$HOME/code/picade/picade$i/etc/wireguard/" "root@10.100.0.10$i:/etc/wireguard"
#  rsync -avrP --delete --chown root:root "$HOME/code/picade/picade$i/etc/network/interfaces.d/" "root@10.100.0.10$i:/etc/network/interfaces.d"
#  rsync -avrP --delete "$HOME/code/picade/home/pi/" "pi@10.100.0.10$i:/home/pi"
#done
