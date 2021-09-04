FROM golang@sha256:2bfab88e0f862d5c980fa877c9aa4d9d402fff013242fe5c19463357aec79114 as builder


# Create unprivileged user
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

# Import the user and group files from the builder.
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

# Copy our static executable.
COPY --from=builder /go/bin/main /main

# Use an unprivileged user.
USER nonpriv

# # Exposing port 80
# EXPOSE 80

# Run the hello binary.
CMD ["/main"]