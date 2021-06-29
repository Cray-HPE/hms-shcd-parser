# MIT License
#
# (C) Copyright [2020-2021] Hewlett Packard Enterprise Development LP
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

# Dockerfile for building hms-shcd-parser.

# Build base just has the packages installed we need.
FROM arti.dev.cray.com/baseos-docker-master-local/golang:1.16-alpine3.13 AS build-base

RUN set -ex \
    && apk update \
    && apk add build-base

FROM build-base AS base

RUN go env -w GO111MODULE=auto

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

FROM arti.dev.cray.com/baseos-docker-master-local/alpine:3.13
LABEL maintainer="Cray, Inc."
STOPSIGNAL SIGTERM

COPY --from=builder /go/shcd-parser /usr/local/bin

ENV SHCD_FILE="/input/shcd_file.xlsx"
ENV OUTPUT_FILE="/output/hmn_connections.json"

CMD ["sh", "-c", "shcd-parser"]
