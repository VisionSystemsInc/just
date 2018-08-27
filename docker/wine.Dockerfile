FROM vsiri/recipe:gosu as gosu
FROM vsiri/recipe:tini-musl as tini
FROM vsiri/recipe:vsi as vsi

#FROM fedora:28

#SHELL ["/usr/bin/env", "bash", "-euxvc"]

#RUN dnf install -y wine; \
#    dnf clean all

#ARG WINE_MONO_VERSION=4.7.1
#ARG WINE_GECKO_VERSION=2.47

#RUN export WINEPREFIX=/home/wine; \
#    mkdir -p /root/.cache/wine; \
#    cd /root/.cache/wine; \
#    curl -LO http://dl.winehq.org/wine/wine-mono/${WINE_MONO_VERSION}/wine-mono-${WINE_MONO_VERSION}.msi; \
#    curl -LO http://dl.winehq.org/wine/wine-gecko/${WINE_GECKO_VERSION}/wine_gecko-${WINE_GECKO_VERSION}-x86.msi; \
#    curl -LO http://dl.winehq.org/wine/wine-gecko/${WINE_GECKO_VERSION}/wine_gecko-${WINE_GECKO_VERSION}-x86_64.msi; \
#    wineboot; \
#    wineserver -w; \
#    cd /; \
#    rm -rf /root/.cache

#ARG PYTHON_VERSION=2.7.15
#RUN curl -LO https://www.python.org/ftp/python/${PYTHON_VERSION}/python-${PYTHON_VERSION}.amd64.msi; \
#    export WINEPREFIX=/home/wine; \
#    cd /home/wine/drive_c; \
#    mkdir -p python; \
#    msiexec /python-${PYTHON_VERSION}.amd64.msi /qn TARGETDIR=./python; \
#    rm /python-${PYTHON_VERSION}.amd64.msi; \
#    wineserver -w

#RUN export WINEPREFIX=/home/wine; \
#    wine c:\\python\\Scripts\\pip install pyinstaller==2.1; \
#    wineserver -w

#COPY --from=tini /usr/local/bin/tini /usr/local/bin/tini
#COPY --from=gosu /usr/local/bin/gosu /usr/local/bin/gosu
## Allow non-privileged to run gosu (remove this to take root away from user)
#RUN chmod u+s /usr/local/bin/gosu
#COPY --from=vsi /vsi /vsi
#ADD docker/wine_entrypoint.bsh /

## Not sure if this is necessary, but it's never bad
#ENV LANG=en_US.UTF-8 \
#    LANGUAGE=en_US:en \
#    LC_ALL=en_US.UTF-8 \
#    TERM=xterm-256color \
#    WINEPREFIX=/home/wine

#ENTRYPOINT ["/usr/local/bin/tini", "/usr/bin/env", "bash", "/wine_entrypoint.bsh"]
## Does not require execute permissions, unlike:
## ENTRYPOINT ["/usr/local/bin/tini", "/wine_entrypoint.bsh"]

#CMD ["wine"]


FROM andyneff/wine

RUN apk add --no-cache gnutls

ARG PYTHON_VERSION=2.7.15
RUN apk add --no-cache --virtual .deps curl; \
    curl -LO https://www.python.org/ftp/python/${PYTHON_VERSION}/python-${PYTHON_VERSION}.amd64.msi; \
    apk del .deps; \
    # Install python
    export WINEPREFIX=/home/wine; \
    cd /home/wine/drive_c; \
    mkdir -p python; \
    msiexec /i /python-${PYTHON_VERSION}.amd64.msi /qn TARGETDIR=c:\\python; \
    rm /python-${PYTHON_VERSION}.amd64.msi; \
    wineserver -w

RUN export WINEPREFIX=/home/wine; \
    cd /home/wine/drive_c/python/Lib; \
    wine64 python -m ensurepip; \
    wine64 python -m pip install -U pip; \
    wineserver -w

RUN export WINEPREFIX=/home/wine; \
    wine64 pip install pyinstaller==3.3.1 pywin32; \
    wineserver -w

ADD docker/wine_entrypoint.bsh /

# ARG PYTHON_VERSION=3.7.0
# RUN apk add --no-cache --virtual .deps curl; \
#     curl -LO https://www.python.org/ftp/python/${PYTHON_VERSION}/python-${PYTHON_VERSION}-embed-amd64.zip; \
#     apk del .deps

# ADD docker/wine_entrypoint.bsh /

# RUN apt-get update; apt-get install -y ca-certificates; \
#     export WINEPREFIX=/home/wine; \
#     wine c:\\python\\python Z:\\get-pip.py; \
#     wineserver -w

# RUN export WINEPREFIX=/home/wine; \
#     wine c:\\python\\Scripts\\pip install pyinstaller==2.1; \
#     wineserver -w
