FROM vsiri/recipe:gosu as gosu
FROM vsiri/recipe:tini as tini
FROM vsiri/recipe:pipenv as pipenv
FROM vsiri/recipe:vsi as vsi

FROM centos:7

SHELL ["/usr/bin/env", "bash", "-euxvc"]

RUN yum install -y epel-release; \
    yum install -y python36 which; \
    yum clean all

COPY --from=tini /usr/local/bin/tini /usr/local/bin/tini
COPY --from=gosu /usr/local/bin/gosu /usr/local/bin/gosu
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
RUN if [ ! -s "${PIPENV_PIPFILE}.lock" ]; then \
      rm "${PIPENV_PIPFILE}.lock"; \
    fi; \
    pipenv install --python "$(command -v python36)"; \
    # Cleanup and make way for the real /src that will be mounted at runtime
    rm -r /src

# Allow non-privileged to run gosu (remove this to take root away from user)
RUN chmod u+s /usr/local/bin/gosu

COPY --from=vsi /vsi /vsi
ADD docker/linux_entrypoint.bsh /

ENTRYPOINT ["/usr/local/bin/tini", "/usr/bin/env", "bash", "/linux_entrypoint.bsh"]

CMD ["linux"]
