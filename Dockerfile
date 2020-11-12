# Copyright 2020 Hewlett Packard Enterprise Development LP

# Dockerfile for building hms-shcd-parser.

# Build base just has the packages installed we need.
FROM dtr.dev.cray.com/baseos/golang:1.14-alpine3.12 AS build-base

RUN set -ex \
    && apk update \
    && apk add build-base

FROM build-base AS base

# Copy all the necessary files to the image.
COPY cmd $GOPATH/src/stash.us.cray.com/HMS/hms-shcd-parser/cmd
COPY pkg $GOPATH/src/stash.us.cray.com/HMS/hms-shcd-parser/pkg
COPY vendor $GOPATH/src/stash.us.cray.com/HMS/hms-shcd-parser/vendor

### Build Stage ###

FROM base AS builder

# Now build
RUN set -ex \
    && go build -v -i -o shcd-parser stash.us.cray.com/HMS/hms-shcd-parser/cmd/shcd-parser

### Final Stage ###

FROM dtr.dev.cray.com/baseos/alpine:3.12
LABEL maintainer="Cray, Inc."
STOPSIGNAL SIGTERM

COPY --from=builder /go/shcd-parser /usr/local/bin

ENV SHCD_FILE="/input/shcd_file.xlsx"
ENV OUTPUT_FILE="/output/hmn_connections.json"

CMD ["sh", "-c", "shcd-parser"]