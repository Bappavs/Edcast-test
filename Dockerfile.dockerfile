# Dockerfile 

# Start from the latest golang base image
FROM golang:latest as builder

# Add Maintainer Info
LABEL maintainer="Vishal"

# Set the Current Working Directory inside the container
WORKDIR /go-calc


# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Copy the source from the current directory to the Working Directory inside the container
COPY . .


######## Start a new stage from scratch #######
FROM alpine:latest  

RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy the Pre-built binary file from the previous stage
COPY --from=builder /go-calc .

# Expose port 8080 to the outside world
EXPOSE 8080

# Command to run the executable
CMD ["./go-calc &"] 