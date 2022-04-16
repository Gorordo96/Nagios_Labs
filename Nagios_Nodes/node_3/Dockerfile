FROM ubuntu:20.04

RUN apt update && apt install -y curl ssh vim wget tar gzip

CMD exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"