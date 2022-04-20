FROM golang:1.18.0 AS builder
WORKDIR /app
COPY go.mod ./
COPY go.sum ./
RUN go mod download
COPY main.go ./
COPY backup ./backup/
RUN CGO_ENABLED=0 GOOS=linux go build -a -o app .

FROM registry.access.redhat.com/ubi8/ubi-micro:8.5-833
WORKDIR /app
RUN chown -R 1001:0 /app && \
    chmod -R g=u /app
COPY --from=builder /app /app/
USER 1001
CMD ["./app"]