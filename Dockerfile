# Dockerfile for CI (tests run by default)
# Minimal, stable runtime focused on running scripts in `scripts/`.
# Keep this Dockerfile stable — changes should be rare and only for env changes.

FROM python:3.11-slim

# Install system deps for building wheels/C-extensions
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# Install Python deps early to leverage cache
COPY requirements.txt /workspace/requirements.txt
RUN python -m pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Copy repository into the image so CI runs without mounting volumes
COPY . /workspace

# Default: run the project's test script (so `docker run --rm <image>` runs tests)
CMD ["/workspace/scripts/test.sh"]
