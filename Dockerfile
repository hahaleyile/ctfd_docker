# FROM python:3.9-alpine AS compiler
# sed -i 's?\(https://\).*\(/alpine.*\)?\1mirrors.aliyun.com\2?g' /etc/apk/repositories



FROM python:3.9-alpine

ENV TZ="Asia/Shanghai"

WORKDIR /opt

RUN \
    apk add --no-cache libffi-dev musl-dev gcc g++ make file git go && \
    git clone --depth=1 https://github.com/CTFd/CTFd.git && \
    python -m venv venv && \
    pip install wheel && \
    source venv/bin/activate

ENV PATH="/opt/venv/bin:$PATH"

# RUN pip install -r CTFd/requirements.txt
RUN cd CTFd