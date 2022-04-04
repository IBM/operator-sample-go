FROM golang:1.18.0 AS builder

WORKDIR /app
COPY go.mod ./
COPY main.go ./
COPY backup/backup.go ./backup/
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build -a -o app .

FROM registry.access.redhat.com/ubi8/ubi-micro:8.5-833
WORKDIR /
COPY --from=builder /app /
CMD ["./app"]