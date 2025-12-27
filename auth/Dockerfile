# ===== Stage 1: Build =====
FROM golang:alpine AS builder

# Set up working directory
WORKDIR /app

# Copy go.work and modules
COPY src/go.work ./
COPY src/authdb/go.mod ./authdb/
COPY src/main/go.mod ./main/
COPY src/main/go.sum ./main/

# Download dependencies
RUN go work sync && \
    cd main && go mod download

# Copy source code
COPY src/authdb/ ./authdb/
COPY src/main/ ./main/

# Build the application
RUN cd main && go build -o server

# ===== Stage 2: Run =====
FROM debian:bullseye-slim

# Create non-root user
RUN useradd -m appuser

WORKDIR /home/appuser

# Copy built binary from builder
COPY --from=builder /app/main/server .

# Set environment variables (override in docker run)
ENV DB_HOST=localhost
ENV DB_USER=root
ENV DB_PASSWORD=root
ENV DB_NAME=authdb

# Expose the port
EXPOSE 8080

# Use non-root user
USER appuser

# Run the binary
CMD ["./server"]
