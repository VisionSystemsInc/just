FROM andyneff/wine_msys64:ubuntu_16.04

ARG PYTHON_VERSION=2.7.3
RUN apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      curl ca-certificates; \
    curl -LO https://www.python.org/ftp/python/${PYTHON_VERSION}/python-${PYTHON_VERSION}.amd64.msi; \
    curl -LO https://bootstrap.pypa.io/get-pip.py; \
    DEBIAN_FRONTEND=noninteractive apt-get purge -y --auto-remove curl ca-certificates; \
    rm -rf /var/lib/apt/lists/*

RUN export WINEPREFIX=/home/wine; \
    cd /home/wine/drive_c; \
    mkdir -p python; \
    msiexec /a /python-${PYTHON_VERSION}.amd64.msi /qb TARGETDIR=./python; \
    rm /python-${PYTHON_VERSION}.amd64.msi; \
    wineserver -w

RUN apt-get update; apt-get install -y ca-certificates; \
    export WINEPREFIX=/home/wine; \
    wine c:\\python\\python Z:\\get-pip.py; \
    wineserver -w

RUN export WINEPREFIX=/home/wine; \
    wine c:\\python\\Scripts\\pip install pyinstaller==2.1; \
    wineserver -w