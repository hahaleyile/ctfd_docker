# FROM python:3.9-alpine AS compiler
# sed -i 's?\(https://\).*\(/alpine.*\)?\1mirrors.aliyun.com\2?g' /etc/apk/repositories



FROM python:3.9-alpine

ENV TZ="Asia/Shanghai"

WORKDIR /opt

RUN \
    python -m venv venv && \
    source venv/bin/activate && \
    apk --update --no-cache add python3-dev libffi-dev gcc musl-dev make libevent-dev build-base && \
    pip install wheel --no-cache-dir && \
    pip install gevent==20.9.0 --no-cache-dir && \
    apk add --no-cache git go && \
    git clone --depth=1 https://github.com/CTFd/CTFd.git

ENV PATH="/opt/venv/bin:$PATH"

RUN pip install -r CTFd/requirements.txt