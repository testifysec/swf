FROM cgr.dev/chainguard/go@sha256:605d81422aba573c17bfd6029a217e94a9575179a98355a99acbb6e028ca883b as builder

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

FROM cgr.dev/chainguard/static@sha256:676e989769aa9a5254fbfe14abb698804674b91c4d574bb33368d87930c5c472

USER root

COPY --from=builder /build/bin/software /software

ENTRYPOINT ["/software"]
