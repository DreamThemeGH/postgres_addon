ARG BUILD_FROM
FROM $BUILD_FROM

RUN apk add --no-cache postgresql15 postgresql15-client


COPY run.sh /
RUN chmod a+x /run.sh

WORKDIR /data

EXPOSE 5432

CMD [ "/run.sh" ]