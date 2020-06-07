FROM golang:latest as builder
WORKDIR /app
COPY server .
RUN go mod download && CGO_ENABLED=0 GOOS=linux go build main.go

FROM alpine:latest
WORKDIR app
COPY --from=builder app/main .
EXPOSE 3000
CMD ["./main"]
