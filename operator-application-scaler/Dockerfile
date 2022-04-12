FROM golang:1.18.0 AS builder
WORKDIR /app
COPY go.mod ./
COPY go.sum ./
RUN go mod download
COPY main.go ./
COPY scaler ./scaler/
RUN CGO_ENABLED=0 GOOS=linux go build -a -o app .

FROM registry.access.redhat.com/ubi8/ubi-micro:8.5-833
WORKDIR /
COPY --from=builder /app /
CMD ["./app"]