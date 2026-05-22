FROM alpine:3.20

RUN apk add --no-cache ca-certificates wget

WORKDIR /addon

COPY run.sh /addon/
COPY start_playit.sh /addon/
COPY playit_status_export.sh /addon/

RUN chmod +x /addon/run.sh /addon/start_playit.sh /addon/playit_status_export.sh

EXPOSE 7681

CMD ["/addon/run.sh"]
