# FROM vsiri/recipe:pipenv as pipenv
FROM vsiri/recipe:vsi as vsi

FROM alpine:3.2

SHELL ["/usr/bin/env", "sh", "-euxvc"]

RUN apk add --no-cache su-exec bash python3 binutils

# Thanks https://github.com/six8/pyinstaller-alpine/blob/develop/Dockerfile
ARG PYINSTALLER_VERSION=3.3.1
RUN apk add --no-cache --virtual .deps ca-certificates gcc zlib-dev musl-dev libc-dev pwgen; \
    wget https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py; \
    python3 /tmp/get-pip.py; \
    wget https://github.com/pyinstaller/pyinstaller/archive/v${PYINSTALLER_VERSION}.tar.gz -O /tmp/pyinstaller.tar.gz; \
    cd /tmp; \
    tar xzf /tmp/pyinstaller.tar.gz; \
    cd pyinstaller-${PYINSTALLER_VERSION}/bootloader; \
    python3 ./waf configure --no-lsb all; \
    pip install ..; \
    cd /; \
    rm -rf /tmp/*; \
    apk del .deps

# COPY --from=pipenv /tmp/pipenv /tmp/pipenv
# RUN /tmp/pipenv/get-pipenv; rm -r /tmp/pipenv
# ENV WORKON_HOME=/venv \
#     PIPENV_PIPFILE=/src/Pipfile \
#     # Needed for pipenv shell \
#     PYENV_SHELL=/bin/bash \
#     LC_ALL=en_US.UTF-8 \
#     LANG=en_US.UTF-8
# ADD Pipfile Pipfile.lock /src/
# # Break apart into multiple steps if it gets too big. Manually pick big packages
# # And install them separate RUN commands
# RUN if [ ! -s "${PIPENV_PIPFILE}.lock" ]; then \
#       rm "${PIPENV_PIPFILE}.lock"; \
#     fi; \
#     pipenv install; \
#     # Cleanup and make way for the real /src that will be mounted at runtime
#     rm -r /src

# Allow non-privileged to run gosu (remove this to take root away from user)
RUN chmod u+s /sbin/su-exec; \
    ln -s /sbin/su-exec /sbin/gosu

COPY --from=vsi /vsi /vsi
ADD docker/musl_entrypoint.bsh /

ENTRYPOINT ["/usr/bin/env", "bash", "/musl_entrypoint.bsh"]

CMD ["musl"]
