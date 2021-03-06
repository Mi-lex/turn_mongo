### 1. stage: create build image
FROM debian:stable AS coturn-build
ARG DEFAULT_TURN_USER
ARG DEFAULT_TURN_PASSWORD
ARG DEFAULT_TURN_REALM

ENV BUILD_PREFIX /usr/local/src

# Install build dependencies
RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get update && \
	apt-get install -y build-essential git debhelper dpkg-dev libssl-dev libevent-dev sqlite3 libsqlite3-dev libmongoc-dev libbson-dev

# Clone Coturn
WORKDIR ${BUILD_PREFIX}
RUN git clone https://github.com/coturn/coturn.git

# Build Coturn
WORKDIR ${BUILD_PREFIX}/coturn
RUN ./configure
RUN make

### 2. stage: create production image

FROM debian:stable AS coturn

ENV INSTALL_PREFIX /usr/local
ENV BUILD_PREFIX /usr/local/src
ENV TURNSERVER_GROUP turnserver
ENV TURNSERVER_USER turnserver

COPY --from=coturn-build ${BUILD_PREFIX}/coturn/bin/ ${INSTALL_PREFIX}/bin/
COPY --from=coturn-build ${BUILD_PREFIX}/coturn/man/ ${INSTALL_PREFIX}/man/
#COPY turnserver.conf ${INSTALL_PREFIX}/etc
COPY --from=coturn-build ${BUILD_PREFIX}/coturn/sqlite/turndb ${INSTALL_PREFIX}/var/db/turndb
COPY --from=coturn-build ${BUILD_PREFIX}/coturn/turndb ${INSTALL_PREFIX}/turndb

# Install lib dependencies
RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get update && \
	apt-get install -y curl libc6 libevent-core-2.1-6 libevent-extra-2.1-6 libevent-openssl-2.1-6 libevent-pthreads-2.1-6 libhiredis0.14 libmariadbclient-dev libpq5 libsqlite3-0 libssl1.1 libmongoc-1.0-0 libbson-1.0-0

# Workaround for MongoDB
RUN ln -s /bin/echo /bin/systemctl

RUN if ! getent group "$TURNSERVER_GROUP" >/dev/null; then \
        addgroup --system "$TURNSERVER_GROUP" || exit 1 ;\
    fi \
    && \
    if ! getent passwd "$TURNSERVER_USER" >/dev/null; then \
        adduser --system \
           --home / \
           --shell /bin/false \
           --no-create-home \
           --ingroup "$TURNSERVER_GROUP" \
           --disabled-password \
           --disabled-login \
           --gecos "turnserver daemon" \
               "$TURNSERVER_USER" || exit 1; \
    fi


# set startup parameters
# SUTN/TURN PORTS
EXPOSE 3478 3479 3478/udp 3479/udp 80 80/udp
EXPOSE 5349 5350 5349/udp 5350/udp 443 443/udp
# CLI
EXPOSE 5766
# Relay Ports
EXPOSE 49152-65535 49152-65535/udp

#COPY ./docker-entrypoint.sh /
#ENTRYPOINT ["/docker-entrypoint.sh"]

WORKDIR ${INSTALL_PREFIX}
ADD ./deploy-turnserver.sh ./
# CMD ${INSTALL_PREFIX}/bin/turnserver
ENTRYPOINT ["sh", "./deploy-turnserver.sh"]
