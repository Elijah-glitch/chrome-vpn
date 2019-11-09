FROM browserless/chrome:latest
LABEL maintainer="ericdraken@gmail.com"

WORKDIR "/"

# Switch back to root
# Then in entrypoint call `su -p - blessuser ...`
USER root

ENV URL_NORDVPN_API="https://api.nordvpn.com/server" \
    URL_RECOMMENDED_SERVERS="https://nordvpn.com/wp-admin/admin-ajax.php?action=servers_recommendations" \
    URL_OVPN_FILES="https://downloads.nordcdn.com/configs/archives/servers/ovpn.zip" \
    PROTOCOL=openvpn_udp \
    MAX_LOAD=70 \
    RANDOM_TOP=0 \
    OPENVPN_OPTS=""

ADD https://github.com/just-containers/s6-overlay/releases/download/v1.22.1.0/s6-overlay-amd64.tar.gz /tmp/s6-overlay.tar.gz

RUN apt-get -qq update

RUN apt-get -y -qq install bash curl unzip tar iptables jq openvpn cron

RUN tar xfz /tmp/s6-overlay.tar.gz -C /

RUN mkdir -p /vpn && \
    mkdir -p /ovpn

# Clean up
RUN apt-get -qq clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY root/ /

RUN chmod +x /app/*

VOLUME ["/ovpn"]

# Expose the web-socket and HTTP ports
EXPOSE 3000

ENTRYPOINT ["/init"]