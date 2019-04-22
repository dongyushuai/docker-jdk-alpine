FROM alpine:latest

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# Here we install GNU libc (aka glibc) and set C.UTF-8 locale as default.

RUN ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
    ALPINE_GLIBC_PACKAGE_VERSION="2.28-r0" && \
    ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    echo \
        "-----BEGIN PUBLIC KEY-----\
        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApZ2u1KJKUu/fW4A25y9m\
        y70AGEa/J3Wi5ibNVGNn1gT1r0VfgeWd0pUybS4UmcHdiNzxJPgoWQhV2SSW1JYu\
        tOqKZF5QSN6X937PTUpNBjUvLtTQ1ve1fp39uf/lEXPpFpOPL88LKnDBgbh7wkCp\
        m2KzLVGChf83MS0ShL6G9EQIAUxLm99VpgRjwqTQ/KfzGtpke1wqws4au0Ab4qPY\
        KXvMLSPLUp7cfulWvhmZSegr5AdhNw5KNizPqCJT8ZrGvgHypXyiFvvAH5YRtSsc\
        Zvo9GI2e2MaZyo9/lvb+LbLEJZKEQckqRj4P26gmASrZEPStwc+yqy1ShHLA0j6m\
        1QIDAQAB\
        -----END PUBLIC KEY-----" | sed 's/   */\n/g' > "/etc/apk/keys/sgerrand.rsa.pub" && \
    wget \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    apk add --no-cache \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    \
    rm "/etc/apk/keys/sgerrand.rsa.pub" && \
    /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true && \
    echo "export LANG=$LANG" > /etc/profile.d/locale.sh && \
    \
    apk del glibc-i18n && \
    \
    rm "/root/.wget-hsts" && \
    apk del .build-dependencies && \
    rm \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"

ENV PACKAGE   jdk
ENV MAJOR     8
ENV MINOR     211

COPY ${PACKAGE}-${MAJOR}u${MINOR}-linux-x64.tar.gz /opt/${PACKAGE}-${MAJOR}u${MINOR}-linux-x64.tar.gz

RUN cd /opt && \
	tar xzf ${PACKAGE}-${MAJOR}u${MINOR}-linux-x64.tar.gz && \
	ln -s /opt/jdk1.${MAJOR}.0_${MINOR} /opt/jdk && \
	ln -s /opt/jdk1.${MAJOR}.0_${MINOR}/bin/* /usr/bin && \
	rm -rf ${PACKAGE}-${MAJOR}u${MINOR}-linux-x64.tar.gz \
			/opt/jdk/*src.zip \
			/opt/jdk/lib/missioncontrol \
			/opt/jdk/lib/visualvm \
			/opt/jdk/lib/*javafx* \
			/opt/jdk/jre/lib/plugin.jar \
			/opt/jdk/jre/lib/ext/jfxrt.jar \
			/opt/jdk/jre/bin/javaws \
			/opt/jdk/jre/lib/javaws.jar \
			/opt/jdk/jre/lib/desktop \
			/opt/jdk/jre/plugin \
			/opt/jdk/jre/lib/deploy* \
			/opt/jdk/jre/lib/*javafx* \
			/opt/jdk/jre/lib/*jfx* \
			/opt/jdk/jre/lib/amd64/libdecora_sse.so \
			/opt/jdk/jre/lib/amd64/libprism_*.so \
			/opt/jdk/jre/lib/amd64/libfxplugins.so \
			/opt/jdk/jre/lib/amd64/libglass.so \
			/opt/jdk/jre/lib/amd64/libgstreamer-lite.so \
			/opt/jdk/jre/lib/amd64/libjavafx*.so \
			/opt/jdk/jre/lib/amd64/libjfx*.so \
			/tmp/*

ENV JAVA_HOME /opt/jdk
ENV PATH ${PATH}:${JAVA_HOME}/bin
