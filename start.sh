#!/bin/bash

### build openvpn image and run container
start() {
    OVPN_DATA="ovpn"
    docker rm -f openvpn
    docker rmi aniydx/openvpn:v1
    docker volume rm ovpn

    docker build -t aniydx/openvpn:v1 -f Dockerfile . &&
    docker volume create --name $OVPN_DATA
    docker run -v $OVPN_DATA:/etc/openvpn --rm aniydx/openvpn:v1 ovpn_genconfig -u udp://39.97.105.138
    docker run -v $OVPN_DATA:/etc/openvpn --rm -it aniydx/openvpn:v1 ovpn_initpki nopass
    docker run -v $OVPN_DATA:/etc/openvpn -d --name openvpn -p 1194:1194/udp --cap-add=NET_ADMIN aniydx/openvpn:v1
}


### create a demo cert
cert() {
    OVPN_DATA="ovpn"
    docker run -v $OVPN_DATA:/etc/openvpn --rm -it aniydx/openvpn:v1 easyrsa build-client-full base nopass
    docker run -v $OVPN_DATA:/etc/openvpn --rm aniydx/openvpn:v1 ovpn_getclient base > base.ovpn
}



### add openvpn user
# 添加账号
add() {
    USERNAME=$1
    PASSWORD=$(/usr/bin/openssl rand -base64 12)
    docker exec -it openvpn sh -c "echo '${USERNAME} ${PASSWORD}' >> /etc/openvpn/psw-file" && docker exec -it openvpn cat /etc/openvpn/psw-file
}

### delete username
# 删除账号
delete() {
    USERNAME=$1
    docker exec -it openvpn sed -i "/^${USERNAME}/d" /etc/openvpn/psw-file && docker exec -it openvpn sh -c "{ echo 'kill ${USERNAME}'; echo 'exit' ; } | /bin/busybox-extras telnet localhost 7505"
}

while getopts ":s:c:a:d:h" opt
do
    case $opt in
        s)
            s1=${OPTARG}
            start $s1
            ;;
        c)
            s2=${OPTARG}
            cert $s2
            ;;
        a)
            s3=${OPTARG}
            add $s3
            ;;
        d)
            s4=${OPTARG}
            delete $s4
            ;;
        h)
            echo "1、Docker Build And Start ; sh start.sh -s start"
            echo "2、Create Ovpn  Cert      ; sh start.sh -c base"
            echo "3、Create User  xushen    ; sh start.sh -a xushen"
            echo "4、Delete User  xushen    ; sh start.sh -d xushen"
            exit 1
            ;;
    esac
done
