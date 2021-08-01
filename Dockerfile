FROM python:3.9.6-alpine3.13 AS build-step

WORKDIR /app

COPY src/. .

RUN adduser -D speedtest
RUN pip install -r requirements.txt
RUN export ARCHITECTURE=$(uname -m)
RUN if [ "$ARCHITECTURE" == 'armv7l' ]; then export ARCHITECTURE=arm; fi
RUN wget -O /tmp/speedtest.tgz "https://github.com/librespeed/speedtest-cli/releases/download/v1.0.9/librespeed-cli_1.0.9_linux_amd64.tar.gz"
RUN tar zxvf /tmp/speedtest.tgz -C /tmp
RUN cp /tmp/librespeed-cli /usr/local/bin
RUN rm requirements.txt

RUN chown -R speedtest:speedtest /app

USER speedtest

CMD ["python", "-u", "exporter.py"]

HEALTHCHECK --timeout=10s CMD wget --no-verbose --tries=1 --spider http://localhost:${SPEEDTEST_PORT:=9798}/