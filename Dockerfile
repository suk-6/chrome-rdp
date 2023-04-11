FROM ubuntu:16.04
LABEL Maintainer="https://suk.kr"
LABEL Forked="sfoxdev"

ENV VNC_PASSWORD="" \
	DEBIAN_FRONTEND="noninteractive" \
	LC_ALL="C.UTF-8" \
	LANG="ko_KR.UTF-8" \
	LANGUAGE="ko_KR.UTF-8"

ADD https://dl.google.com/linux/linux_signing_key.pub /tmp/
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list ; \
	echo "deb http://dl.google.com/linux/chrome-remote-desktop/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list ; \
	apt-key add /tmp/linux_signing_key.pub ; \
	apt update ; \
	apt install -y \
	google-chrome-stable \
	chrome-remote-desktop ; \
	apt install -y \
	fonts-takao \
	pulseaudio \
	supervisor \
	x11vnc \
	fluxbox \
	mc \
	xfce4 \
	xrdp \
	wget \
	unzip \
	fontconfig ; \
	rm -rf /var/cache/* /var/log/apt/* /var/lib/apt/lists/* /tmp/*

RUN addgroup chrome-remote-desktop ; \
	addgroup pulse-access ; \
	useradd -m -G chrome-remote-desktop,pulse-access -p chrome chrome ; \
	{ echo "chrome"; echo "chrome"; } | passwd chrome ; \
	ln -s /crdonly /usr/local/sbin/crdonly ; \
	ln -s /update /usr/local/sbin/update ; \
	mkdir -p /home/chrome/.config/chrome-remote-desktop ; \
	mkdir -p /home/chrome/.fluxbox ; \
	echo ' \n\
	session.screen0.toolbar.visible:        false\n\
	session.screen0.fullMaximization:       true\n\
	session.screen0.maxDisableResize:       true\n\
	session.screen0.maxDisableMove: true\n\
	session.screen0.defaultDeco:    NONE\n\
	' >> /home/chrome/.fluxbox/init ; \
	chown -R chrome:chrome /home/chrome/.config /home/chrome/.fluxbox

RUN wget -P /tmp/ http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFont_TTF_ALL.zip ; \
	unzip /tmp/NanumFont_TTF_ALL.zip -d /tmp/NanumFont ; \
	mv /tmp/NanumFont /usr/share/fonts/ ; \
	fc-cache -f -v

ADD ./conf/ /

VOLUME ["/home/chrome"]

EXPOSE 5900 3389

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
