# sed -i 's?\(https://\).*\(/alpine.*\)?\1mirrors.aliyun.com\2?g' /etc/apk/repositories
# ENV GO111MODULE=on
# ENV GOPROXY=https://goproxy.cn

FROM python:3.9-slim-buster AS compiler

WORKDIR /opt

RUN \
    python -m venv venv && \
    source venv/bin/activate && \
    apt-get update && \
    apt-get install -y --no-install-recommends build-essential python3-dev libffi-dev libssl-dev git && \
    git clone --depth=1 https://github.com/CTFd/CTFd.git

ENV PATH="/opt/venv/bin:$PATH"

RUN pip install -r CTFd/requirements.txt --no-cache-dir && \
    for d in CTFd/CTFd/plugins/*; do \
        if [ -f "$d/requirements.txt" ]; then \
            pip install -r $d/requirements.txt --no-cache-dir; \
        fi; \
    done;


FROM python:3.9-alpine

COPY --from=compile /opt/venv /opt/venv
COPY --from=compile /opt/CTFd CTFd

ENV PATH="/opt/venv/bin:$PATH"
ENV TZ="Asia/Shanghai"

WORKDIR /app

RUN adduser -D -u 1001 -g "" -s /bin/sh ctfd
RUN mkdir /var/log/CTFd /var/uploads && \
    chmod +x CTFd/docker-entrypoint.sh && \
    chown -R 1001:1001 CTFd /var/log/CTFd /var/uploads

USER 1001
EXPOSE 8000
ENTRYPOINT ["CTFd/docker-entrypoint.sh"]