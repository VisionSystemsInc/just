FROM vsiri/recipe:pipenv as pipenv
FROM vsiri/recipe:vsi as vsi

FROM alpine:3.8

SHELL ["/usr/bin/env", "sh", "-euxvc"]

RUN apk add --no-cache su-exec tini bash python3 binutils

COPY --from=pipenv /tmp/pipenv /tmp/pipenv
RUN /tmp/pipenv/get-pipenv; rm -r /tmp/pipenv
ENV WORKON_HOME=/venv \
    PIPENV_PIPFILE=/src/Pipfile \
    # Needed for pipenv shell \
    PYENV_SHELL=/bin/bash \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8
ADD Pipfile Pipfile.lock /src/
# Break apart into multiple steps if it gets too big. Manually pick big packages
# And install them separate RUN commands
RUN if [ ! -s Pipfile.lock ]; then \
      pipenv lock; \
    fi; \
    pipenv install; \
    # Cleanup and make way for the real /src that will be mounted at runtime
    rm -r /src

# Allow non-privileged to run gosu (remove this to take root away from user)
RUN chmod u+s /sbin/su-exec; \
    ln -s /sbin/su-exec /sbin/gosu

COPY --from=vsi /vsi /vsi
ADD docker/linux_entrypoint.bsh /

ENTRYPOINT ["/sbin/tini", "/usr/bin/env", "bash", "/linux_entrypoint.bsh"]

CMD ["linux"]
