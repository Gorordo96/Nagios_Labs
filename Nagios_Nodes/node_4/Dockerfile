FROM ubuntu:20.04

RUN apt update && \
    apt install -y lsb-release ssh wget curl ca-certificates gnupg2 && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" | tee /etc/apt/sources.list.d/postgresql-pgdg.list > /dev/null && \
    apt update && apt install -y postgresql-10

CMD exec /bin/bash -c "service postgresql start && trap : TERM INT; sleep infinity & wait"