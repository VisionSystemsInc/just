FROM vsiri/recipe:gosu as gosu
FROM vsiri/recipe:vsi as vsi

FROM alpine:3.8

SHELL ["/usr/bin/env", "sh", "-euxvc"]

RUN apk add --no-cache bash

ARG MAKESELF_VERSION=release-2.4.0

RUN apk add --no-cache --virtual .deps wget tar; \
    mkdir /makeself; \
    cd /makeself; \
    wget https://github.com/megastep/makeself/archive/${MAKESELF_VERSION}/makeself.tar.gz; \
    tar xf makeself.tar.gz --strip-components=1; \
    rm makeself.tar.gz; \

    # Disable arg parsing by makeself executable
    sed '1,/^while true/s|^while true|while false|' "/makeself/makeself-header.sh" > "/makeself/makeself-header_just.sh"; \
    # Make executable quietly extract
    sed -i '1,/^quiet="n"/s|^quiet="n"|quiet="y"|' "/makeself/makeself-header_just.sh"; \

    apk del .deps

COPY --from=gosu /usr/local/bin/gosu /usr/local/bin/gosu
# Allow non-privileged to run gosu (remove this to take root away from user)
RUN chmod u+s /usr/local/bin/gosu

COPY --from=vsi /vsi /vsi
ADD docker/make.Justfile /src/docker/
ADD just.env /src
ENV JUSTFILE=/src/docker/make.Justfile \
    JUST_SETTINGS=/src/just.env

ENTRYPOINT ["bash", "/vsi/linux/just_entrypoint.sh"]

CMD ["makeself"]
