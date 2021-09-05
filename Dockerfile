############################
# STEP 1 building executable file
############################

FROM golang@sha256:2bfab88e0f862d5c980fa877c9aa4d9d402fff013242fe5c19463357aec79114 as builder


# Create an unprivileged user
ENV USER=nonpriv
ENV UID=10006 

RUN adduser \    
    --disabled-password \    
    --gecos "" \    
    --home "/blackhole" \    
    --shell "/sbin/nologin" \    
    --no-create-home \    
    --uid "${UID}" \    
    "${USER}"


WORKDIR /go/src/app 
COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o /go/bin/main


############################
# STEP 2 build a small image
############################
FROM scratch

# Import the user file from the builder.
COPY --from=builder /etc/passwd /etc/passwd

# Copy static executable from builder.
COPY --from=builder /go/bin/main /main

# Use an unprivileged user.
USER nonpriv

# Exposing port 8080
EXPOSE 8080

# Run the hello binary.
CMD ["/main"]