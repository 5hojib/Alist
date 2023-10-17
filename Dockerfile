FROM alpine

COPY ./content /workdir/

RUN apk add --no-cache curl runit bash tzdata
RUN chmod +x /workdir/service/*/run
RUN sh /workdir/install.sh
RUN rm /workdir/install.sh
RUN ln -s /workdir/service/* /etc/service/

ENV PORT=3000
ENV TZ=UTC

EXPOSE 3000

ENTRYPOINT ["runsvdir", "/etc/service"]
