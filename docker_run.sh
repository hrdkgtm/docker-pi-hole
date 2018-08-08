#!/bin/bash
# Lookups may not work for VPN / tun0
IP_LOOKUP="$(ip route get 9.9.9.9 | awk '{ print $NF; exit }')"  
IPv6_LOOKUP="$(ip -6 route get 2001:4860:4860::8888 | awk '{for(i=1;i<=NF;i++) if ($i=="src") print $(i+1)}')"  

# Just hard code these to your docker server's LAN IP if lookups aren't working
IP="192.168.0.147"  # use $IP, if set, otherwise IP_LOOKUP
IPv6="${IPv6:-$IPv6_LOOKUP}"  # use $IPv6, if set, otherwise IP_LOOKUP

# Default of directory you run this from, update to where ever.
DOCKER_CONFIGS="$(pwd)"  

echo "### Make sure your IPs are correct, hard code ServerIP ENV VARs if necessary\nIP: ${IP}\nIPv6: ${IPv6}"

# Default ports + daemonized docker container
docker run -d \
    --name pihole \
    -p 53:53/tcp -p 53:53/udp \
    -p 67:67/udp \
    -p 80:80 \
    -p 443:443 \
    -v "/home/dika/git/docker-pi-hole/etc/hosts:/etc/hosts" \
    -v "${DOCKER_CONFIGS}/etc/dnsmasq.d/:/etc/dnsmasq.d/" \
    -v "${DOCKER_CONFIGS}/etc/pihole:/etc/pihole/" \
    -e ServerIP="${IP}" \
    -e ServerIPv6="${IPv6}" \
    -e DNS1="9.9.9.9" \
    -e DNS2="1.1.1.1" \
    --restart=unless-stopped \
    pihole/pihole:latest

echo -n "Your password for https://${IP}/admin/ is "
docker logs pihole 2> /dev/null | grep 'password:'
