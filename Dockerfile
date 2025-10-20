# syntax=docker/dockerfile:1

FROM golang:1.23-alpine AS build
WORKDIR /src
COPY main.go .
RUN --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /out/app main.go

FROM alpine:3.20
RUN adduser -D -u 65532 appuser
USER 65532:65532

EXPOSE 8080
ENV APP_VERSION=0.0.0 \
    APP_ENVIRONMENT=None

COPY --from=build /out/app /app

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8080/ >/dev/null 2>&1 || exit 1

ENTRYPOINT ["/app"]

