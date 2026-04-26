FROM alpine:3.19
RUN apk add --no-cache kmod util-linux
COPY aic8800/ /drv/
COPY run.sh /run.sh
RUN chmod +x /run.sh
ENTRYPOINT []
CMD ["/run.sh"]
