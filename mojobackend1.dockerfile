FROM python:3.11-slim as builder

# Set working directory
WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create and activate virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy and install requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -U pip && \
    pip install --no-cache-dir gunicorn && \
    pip install --no-cache-dir -r requirements.txt

FROM python:3.11-slim

WORKDIR /app

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Create non-root user
RUN useradd -r -s /bin/bash -m -d /app nonroot && \
    chown -R nonroot:nonroot /app

# Copy application files
COPY . .
RUN chown -R nonroot:nonroot /app

USER nonroot

# Expose the port
EXPOSE 3000

# Run the application
CMD ["gunicorn", "-b", "0.0.0.0:3000", "--worker-class", "eventlet", "mojo:app"]