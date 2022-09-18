OVPN_DATA="ovpn"
docker run -v $OVPN_DATA:/etc/openvpn --rm -it aniydx/openvpn:v1 easyrsa build-client-full ycz nopass
docker run -v $OVPN_DATA:/etc/openvpn --rm aniydx/openvpn:v1 ovpn_getclient ycz > ycz.ovpn
