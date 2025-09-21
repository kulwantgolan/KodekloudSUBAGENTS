FROM python:3.12

# Install system dependencies (some unnecessary)
RUN apt-get update && \
    apt-get install -y \
    curl \
    git \
    vim \
    nano \
    htop \
    tree \
    build-essential
    # Not cleaning apt cache - adds ~100MB

# Copy EVERYTHING including unnecessary files
COPY . /app
WORKDIR /app

RUN pip install --upgrade pip setuptools wheel

# Install ALL Python packages (many unnecessary for a simple Flask app)
RUN pip install \
    flask==2.3.3 \
    requests==2.31.0 \
    boto3==1.28.57 \
    pandas==2.2.2 \
    numpy==1.26.4 \
    scikit-learn==1.4.2 \
    matplotlib==3.8.4 \
    jupyter==1.0.0 \
    pytest==7.4.0 \
    black==23.7.0 \
    pylint==2.17.5

# Running as root (security issue)
# No .dockerignore (copying .env, __pycache__, .git, etc.)
# No multi-stage build
# Using full python:3.12 instead of python:3.12-slim

EXPOSE 8080
CMD ["python", "app.py"]

# This creates a ~2GB image that can be reduced to ~150MB!