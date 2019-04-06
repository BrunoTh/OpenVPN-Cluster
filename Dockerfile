FROM kylemanna/openvpn

RUN apk add --no-cache --update python3 socat && \
    pip3 install pipenv && \
    mkdir -p /app

WORKDIR /app

COPY Pipfile /app/Pipfile
COPY Pipfile.lock /app/Pipfile.lock

RUN apk add -t install_dep python3-dev build-base && \
    pipenv install --system --deploy && \
    apk del -r install_dep

COPY learn-address.sh /app/learn-address.sh
COPY route_listener.py /app/route_listener.py

CMD /usr/bin/python3 /app/route_listener.py