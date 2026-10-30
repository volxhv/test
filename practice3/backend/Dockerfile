FROM golang:1.23-alpine AS build
WORKDIR /src
COPY go.mod ./
COPY *.go ./
RUN CGO_ENABLED=0 go build -o /app .
FROM alpine:3.21
RUN apk add --no-cache postgresql-client ca-certificates && adduser -D app
COPY --from=build /app /app
USER app
EXPOSE 8000
CMD ["/app"]
