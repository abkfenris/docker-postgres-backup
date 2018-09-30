FROM google/cloud-sdk:218.0.0-alpine

RUN apk add --no-cache postgresql-client

ADD backup.sh /backup.sh

CMD [ "/bin/bash", "/backup.sh" ]
