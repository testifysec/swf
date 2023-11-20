FROM cgr.dev/chainguard/go:latest as builder

ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT=""
ARG LDFLAGS

ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=${TARGETOS} \
    GOARCH=${TARGETARCH} \
    GOARM=${TARGETVARIANT}

WORKDIR /build

COPY . .

RUN go build -o bin/software

FROM cgr.dev/chainguard/static:latest

# USER root

COPY --from=builder /build/bin/software /software

ENTRYPOINT ["/software"]
