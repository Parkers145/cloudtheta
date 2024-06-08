# Stage 1: Build the Theta binaries
FROM golang:1.14.1 AS builder

# Set environment variables
ENV GOROOT /usr/local/go
ENV GOPATH /go
ENV PATH $GOPATH/bin:$GOROOT/bin:$PATH
ENV THETA_HOME /go/src/github.com/thetatoken/theta-protocol-ledger

# Create directories
RUN mkdir -p $THETA_HOME

# Clone the Theta repository
RUN git clone https://github.com/thetatoken/theta-protocol-ledger.git $THETA_HOME

# Enable Go modules and build the binaries
WORKDIR $THETA_HOME
RUN go mod download
RUN make install

# Stage 2: Create the final image
FROM ubuntu:bionic

ENV THETA_HOME /etc/theta

# Install necessary packages
RUN apt-get update && apt-get install -y \
    ca-certificates \
	curl \
	openssh-server \
	nano \
	wget \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Copy the binaries from the builder stage
COPY --from=builder /go/bin/theta /usr/local/bin/theta
COPY --from=builder /go/bin/thetacli /usr/local/bin/thetacli

# Create log directory
RUN mkdir -p /var/log

# Install Zinit
RUN curl -fsSL https://github.com/threefoldtech/zinit/releases/download/v0.2.14/zinit -o /usr/local/bin/zinit && chmod +x /usr/local/bin/zinit

# Copy Zinit configurations and start scripts
COPY zinit /etc/zinit

# Copy SSH init script
COPY ssh-init.sh /usr/local/bin/ssh-init.sh
RUN chmod +x /usr/local/bin/ssh-init.sh

# Copy Gaurdian Initiation Script
COPY theta-init.sh /usr/local/bin/theta-init.sh
RUN chmod +x /usr/local/bin/theta-init.sh

# Create the directory for configuration and snapshot
RUN mkdir -p /etc/theta

# Expose necessary ports
EXPOSE  16888 30303 8080 6060 22

# Use Zinit as the init system
ENTRYPOINT ["zinit", "init"]