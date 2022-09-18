# Smallest base image
FROM alpine:latest

LABEL maintainer="aniydx@gmail.com"

# Testing: pamtester
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    apk add --update openvpn iptables bash easy-rsa openvpn-auth-pam google-authenticator pamtester libqrencode busybox-extras tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin && \
    apk del tzdata && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

# RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories && \
#     apk add tzdata && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
#     echo "Asia/Shanghai" > /etc/timezone && \
#     apk update && \
#     apk add curl openvpn iptables bash easy-rsa openvpn-auth-pam google-authenticator libqrencode busybox-extras && \
#     ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin && \
#     rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/* && \
#     apk del tzdata

# Needed by scripts
ENV OPENVPN=/etc/openvpn
ENV EASYRSA=/usr/share/easy-rsa \
    EASYRSA_CRL_DAYS=3650 \
    EASYRSA_PKI=$OPENVPN/pki

VOLUME ["/etc/openvpn"]

# Internally uses port 1194/udp, remap using `docker run -p 443:1194/tcp`
EXPOSE 1194/udp

CMD ["ovpn_run"]

ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

# Add support for OTP authentication using a PAM module
ADD ./otp/openvpn /etc/pam.d/

# Add login 、logout 、check user ... shell  and  user passwd file
COPY ./login.sh    /etc/openvpn/login.sh
COPY ./logout.sh   /etc/openvpn/logout.sh
COPY ./checkpsw.sh /etc/openvpn/checkpsw.sh
COPY ./psw-file    /etc/openvpn/psw-file
