# Use Python 3.10 Slim as the base image
FROM python:3.10-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set work directory
WORKDIR /opt/app/cloudtalents

# Create the directory for static files
RUN mkdir -p /opt/app/cloudtalents/static

# Create the directory for media files
RUN mkdir -p /opt/app/media/user_images

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    postgresql-client \
    libpq-dev \
    netcat-traditional \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt /opt/app/cloudtalents/
RUN pip install --upgrade pip && \
    pip install -r requirements.txt


# Copy relevant project files to the container
COPY . /opt/app/cloudtalents/

# Run entrypoint script
ENTRYPOINT ["/opt/app/cloudtalents/entrypoint.sh"]
