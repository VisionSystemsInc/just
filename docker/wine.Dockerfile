FROM andyneff/wine

# ARG PYTHON_VERSION=2.7.15
# RUN apk add --no-cache --virtual .curl curl; \
#     curl -LO https://www.python.org/ftp/python/${PYTHON_VERSION}/python-${PYTHON_VERSION}.amd64.msi; \
#     apk del .curl

# RUN export WINEPREFIX=/home/wine; \
#     cd /home/wine/drive_c; \
#     mkdir -p python; \
#     msiexec /python-${PYTHON_VERSION}.amd64.msi /qn TARGETDIR=./python; \
#     rm /python-${PYTHON_VERSION}.amd64.msi; \
#     wineserver -w

ARG PYTHON_VERSION=3.7.0
RUN apk add --no-cache --virtual .curl curl; \
    curl -LO https://www.python.org/ftp/python/${PYTHON_VERSION}/python-${PYTHON_VERSION}-embed-amd64.zip; \
    apk del .curl

ADD docker/wine_entrypoint.bsh /

# RUN apt-get update; apt-get install -y ca-certificates; \
#     export WINEPREFIX=/home/wine; \
#     wine c:\\python\\python Z:\\get-pip.py; \
#     wineserver -w

# RUN export WINEPREFIX=/home/wine; \
#     wine c:\\python\\Scripts\\pip install pyinstaller==2.1; \
#     wineserver -w