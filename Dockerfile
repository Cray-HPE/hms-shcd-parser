# MIT License
#
# (C) Copyright [2020-2022,2024-2025] Hewlett Packard Enterprise Development LP
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
FROM artifactory.algol60.net/docker.io/library/golang:1.24-alpine AS build-base

RUN set -ex \
    && apk -U upgrade \
    && apk add build-base

FROM build-base AS base

RUN go env -w GO111MODULE=auto

# Copy all the necessary files to the image.
COPY cmd $GOPATH/src/github.com/Cray-HPE/hms-shcd-parser/cmd
COPY pkg $GOPATH/src/github.com/Cray-HPE/hms-shcd-parser/pkg
COPY vendor $GOPATH/src/github.com/Cray-HPE/hms-shcd-parser/vendor

### Build Stage ###

FROM base AS builder

# Now build
RUN set -ex \
    && go build -v -o shcd-parser github.com/Cray-HPE/hms-shcd-parser/cmd/shcd-parser

### Final Stage ###

FROM artifactory.algol60.net/csm-docker/stable/docker.io/library/alpine:3.21
LABEL maintainer="Hewlett Packard Enterprise"
STOPSIGNAL SIGTERM

COPY --from=builder /go/shcd-parser /usr/local/bin

ENV SHCD_FILE="/input/shcd_file.xlsx"
ENV OUTPUT_FILE="/output/hmn_connections.json"

CMD ["sh", "-c", "shcd-parser"]
