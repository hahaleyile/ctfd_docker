# sed -i 's?\(https://\).*\(/alpine.*\)?\1mirrors.aliyun.com\2?g' /etc/apk/repositories
# ENV GO111MODULE=on
# ENV GOPROXY=https://goproxy.cn

FROM python:3.9-slim-buster AS compile

WORKDIR /opt

RUN \
    python -m venv venv && \
    apt-get update && \
    apt-get install -y --no-install-recommends build-essential python3-dev libffi-dev libssl-dev git && \
    git clone --depth=1 https://github.com/CTFd/CTFd.git

ENV PATH="/opt/venv/bin:$PATH"

RUN venv/bin/pip install -r CTFd/requirements.txt --no-cache-dir && \
    for d in CTFd/CTFd/plugins/*; do \
        if [ -f "$d/requirements.txt" ]; then \
            venv/bin/pip install -r $d/requirements.txt --no-cache-dir; \
        fi; \
    done;


FROM python:3.9-slim-buster

COPY --from=compile /opt/venv /opt/venv
COPY --from=compile /opt/CTFd /app

ENV PATH="/lib64:/opt/venv/bin:$PATH" \
    TZ="Asia/Shanghai" 

WORKDIR /app

RUN adduser --disabled-login --uid 1001 --gecos "" --shell /bin/bash ctfd
RUN mkdir /var/log/CTFd /var/uploads && \
    chmod +x docker-entrypoint.sh && \
    chown -R 1001:1001 CTFd /var/log/CTFd /var/uploads

USER 1001
EXPOSE 8000
ENTRYPOINT ["/bin/bash", "docker-entrypoint.sh"]