FROM cgr.dev/chainguard/go@sha256:c87a8cf30c9a4e58df04712e1bb0b98d8d0421cc924e88f6fca4a6fabf45c6b4 as builder

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

FROM cgr.dev/chainguard/static@sha256:a432665213f109d5e48111316030eecc5191654cf02a5b66ac6c5d6b310a5511

# USER root

COPY --from=builder /build/bin/software /software

ENTRYPOINT ["/software"]
