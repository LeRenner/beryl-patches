uci set firewall.lan2tailscale=forwarding
uci set firewall.lan2tailscale.src='lan'
uci set firewall.lan2tailscale.dest='tailscale0'
uci commit firewall
/etc/init.d/firewall reload
