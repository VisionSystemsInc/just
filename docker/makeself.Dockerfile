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
    apk del .deps

COPY --from=gosu /usr/local/bin/gosu /usr/local/bin/gosu
# Allow non-privileged to run gosu (remove this to take root away from user)
RUN chmod u+s /usr/local/bin/gosu

COPY --from=vsi /vsi /vsi
ADD docker/make_entrypoint.bsh /

ENTRYPOINT ["bash", "/make_entrypoint.bsh"]

CMD ["makeself"]
