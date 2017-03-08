# AlpineLinux with a glibc-2.23 and Oracle Java %JVM_MAJOR%
FROM alpine:3.4

MAINTAINER Kamesh <kamesh.84@gmail.com>

# Java Version and other ENV
ENV JAVA_VERSION_MAJOR=8 \
    JAVA_VERSION_MINOR=102 \
    JAVA_VERSION_BUILD=14 \
    JAVA_PACKAGE=jdk \
    JAVA_JCE=unlimited \
    JAVA_HOME=/opt/jdk \
    PATH=${PATH}:/opt/jdk/bin \
    GLIBC_VERSION=2.23-r3 \
    LANG=C.UTF-8 \
    NODE_VERSION=v0.12.9 \
    NPM_VERSION=3.9.5 \
    TI_VERSION=3.3.0 \
    TI_SDK_VERSION=3_5_X \
    TI_USERNAME=username \
    TI_PASSWORD=password
	

# Create app directory
RUN mkdir -p /usr/src/app
RUN mkdir -p /usr/src/app/project
WORKDIR /usr/src/app/project

VOLUME   ["/Users/admin/Kamesh-Project/panasonic/", "/usr/src/app/project"]

# do all in one step
RUN set -ex && \
    apk upgrade --update && \
    apk add --update libstdc++ curl ca-certificates bash && \
    for pkg in glibc-${GLIBC_VERSION} glibc-bin-${GLIBC_VERSION} glibc-i18n-${GLIBC_VERSION}; do curl -sSL https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/${pkg}.apk -o /tmp/${pkg}.apk; done && \
    apk add --allow-untrusted /tmp/*.apk && \
    rm -v /tmp/*.apk && \
    ( /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true ) && \
    echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh && \
    /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib && \
    mkdir /opt && \
    curl -jksSLH "Cookie: oraclelicense=accept-securebackup-cookie" -o /tmp/java.tar.gz \
      http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz && \
    gunzip /tmp/java.tar.gz && \
    tar -C /opt -xf /tmp/java.tar && \
    ln -s /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} /opt/jdk && \
    if [ "${JAVA_JCE}" == "unlimited" ]; then echo "Installing Unlimited JCE policy" >&2 && \
      curl -jksSLH "Cookie: oraclelicense=accept-securebackup-cookie" -o /tmp/jce_policy-${JAVA_VERSION_MAJOR}.zip \
        http://download.oracle.com/otn-pub/java/jce/${JAVA_VERSION_MAJOR}/jce_policy-${JAVA_VERSION_MAJOR}.zip && \
      cd /tmp && unzip /tmp/jce_policy-${JAVA_VERSION_MAJOR}.zip && \
      cp -v /tmp/UnlimitedJCEPolicyJDK8/*.jar /opt/jdk/jre/lib/security; \
    fi && \
    sed -i s/#networkaddress.cache.ttl=-1/networkaddress.cache.ttl=10/ $JAVA_HOME/jre/lib/security/java.security && \
    apk del curl glibc-i18n && \
    rm -rf /opt/jdk/*src.zip \
           /opt/jdk/lib/missioncontrol \
           /opt/jdk/lib/visualvm \
           /opt/jdk/lib/*javafx* \
           /opt/jdk/jre/plugin \
           /opt/jdk/jre/bin/javaws \
           /opt/jdk/jre/bin/jjs \
           /opt/jdk/jre/bin/orbd \
           /opt/jdk/jre/bin/pack200 \
           /opt/jdk/jre/bin/policytool \
           /opt/jdk/jre/bin/rmid \
           /opt/jdk/jre/bin/rmiregistry \
           /opt/jdk/jre/bin/servertool \
           /opt/jdk/jre/bin/tnameserv \
           /opt/jdk/jre/bin/unpack200 \
           /opt/jdk/jre/lib/javaws.jar \
           /opt/jdk/jre/lib/deploy* \
           /opt/jdk/jre/lib/desktop \
           /opt/jdk/jre/lib/*javafx* \
           /opt/jdk/jre/lib/*jfx* \
           /opt/jdk/jre/lib/amd64/libdecora_sse.so \
           /opt/jdk/jre/lib/amd64/libprism_*.so \
           /opt/jdk/jre/lib/amd64/libfxplugins.so \
           /opt/jdk/jre/lib/amd64/libglass.so \
           /opt/jdk/jre/lib/amd64/libgstreamer-lite.so \
           /opt/jdk/jre/lib/amd64/libjavafx*.so \
           /opt/jdk/jre/lib/amd64/libjfx*.so \
           /opt/jdk/jre/lib/ext/jfxrt.jar \
           /opt/jdk/jre/lib/ext/nashorn.jar \
           /opt/jdk/jre/lib/oblique-fonts \
           /opt/jdk/jre/lib/plugin.jar \
           /tmp/* /var/cache/apk/* && \
	apk add --update curl make gcc g++ binutils-gold python linux-headers paxctl libgcc libstdc++ && \
	curl  -o /tmp/node.tar.gz  -sSL https://nodejs.org/download/release/${NODE_VERSION}/node-${NODE_VERSION}.tar.gz && \
	gunzip /tmp/node.tar.gz && \
    tar -C /tmp -xf /tmp/node.tar && \
	  cd /tmp/node-${NODE_VERSION} && \
	  ./configure --prefix=/usr ${CONFIG_FLAGS} && \
	  make -j$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
	  make install && \
	  paxctl -cm /usr/bin/node && \
	  cd / && \
	  if [ -x /usr/bin/npm ]; then \
		npm install -g npm@${NPM_VERSION} && \
		npm install -g pm2@1.1.3 && \
		find /usr/lib/node_modules/npm -name test -o -name .bin -type d | xargs rm -rf; \
	  fi && \
	  apk del curl make gcc g++ binutils-gold python linux-headers paxctl ${DEL_PKGS} && \
	  rm -rf /etc/ssl /node-${NODE_VERSION} ${RM_DIRS} \
		/usr/share/man /tmp/* /var/cache/apk/* /root/.npm /root/.node-gyp \
		/usr/lib/node_modules/npm/man /usr/lib/node_modules/npm/doc /usr/lib/node_modules/npm/html  

#TITANIUM SETUP

RUN npm -g install titanium@${TI_VERSION} && \
	titanium login ${TI_USERNAME} ${TI_PASSWORD} && \
	titanium sdk install  --branch ${TI_SDK_VERSION} -default && \
	echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf

# ANDROID SETUP
# https://github.com/yongjhih/docker-android/blob/master/ubuntu-openjdk-8-android/Dockerfile

ENV ANDROID_SDK_ZIP http://dl.google.com/android/android-sdk_r24.3.4-linux.tgz

RUN apk add --no-cache curl ca-certificates bash && \
    curl -L $ANDROID_SDK_ZIP | tar zxv -C /opt
    # apk add --nocache lib32stdc++6 lib32z1

ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH $PATH:$ANDROID_HOME/tools
ENV PATH $PATH:$ANDROID_HOME/platform-tools

# https://github.com/yongjhih/docker-android/blob/master/ubuntu-openjdk-8-android-extra/Dockerfile
RUN echo "y" | android update sdk -u -a --filter tools && \
    echo "y" | android update sdk -u -a --filter platform-tools && \
    echo "y" | android update sdk -u -a --filter extra-android-support && \
    echo "y" | android update sdk -u -a --filter extra-android-m2repository && \
    echo "y" | android update sdk -u -a --filter extra-google-google_play_services && \
    echo "y" | android update sdk -u -a --filter extra-google-m2repository && \

# https://github.com/yongjhih/docker-android/blob/master/ubuntu-openjdk-8-android-all/Dockerfile
RUN echo "y" | android update sdk -u -a --filter android-23 && \
    echo "y" | android update sdk -u -a --filter build-tools-23.0.2 && \
    echo "y" | android update sdk -u -a --filter build-tools-23.0.1 && \
    echo "y" | android update sdk -u -a --filter build-tools-23.0.0 && \
    echo "y" | android update sdk -u -a --filter android-22 && \
    echo "y" | android update sdk -u -a --filter build-tools-22.0.1 && \
    echo "y" | android update sdk -u -a --filter build-tools-22.0.0 && \
    echo "y" | android update sdk -u -a --filter android-21 && \
    echo "y" | android update sdk -u -a --filter build-tools-21.1.2 && \
    echo "y" | android update sdk -u -a --filter build-tools-21.1.1 && \
    echo "y" | android update sdk -u -a --filter build-tools-21.1.0 && \
    echo "y" | android update sdk -u -a --filter build-tools-21.0.2 && \
    echo "y" | android update sdk -u -a --filter build-tools-21.0.1 && \
    echo "y" | android update sdk -u -a --filter build-tools-21.0.0 

# Creating AVD 	
RUN echo n | android create avd --force -n "x86" -t android-21 --abi default/x86
RUN echo n | android create avd --force -n "arm" -t android-21 --abi default/armeabi-v7a
