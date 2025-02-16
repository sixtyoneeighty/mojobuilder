FROM debian:12

# Set working directory
WORKDIR /home/nonroot/mojobuilder

# Create a non-root user
RUN groupadd -r nonroot && useradd -r -g nonroot -d /home/nonroot/mojobuilder -s /bin/bash nonroot

# Install dependencies
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y build-essential software-properties-common curl sudo wget git python3 python3-pip python3-venv
RUN apt-get install -y nodejs npm
# Create and activate a virtual environment
RUN python3 -m venv /home/nonroot/mojobuilder/.venv
ENV PATH="/home/nonroot/mojobuilder/.venv/bin:$PATH"

# Copy requirements file and install dependencies inside the virtual environment
COPY requirements.txt /home/nonroot/mojobuilder/
RUN python3 -m pip install --upgrade pip && pip install -r requirements.txt

# Set permissions
RUN chown -R nonroot:nonroot /home/nonroot/mojobuilder
USER nonroot

# Copy application files
COPY . /home/nonroot/mojobuilder/

# Expose the backend port
EXPOSE 3000

# Start the application
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:3000", "your_flask_app:app"]