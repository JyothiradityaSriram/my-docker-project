# Base image
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Copy local files into container
COPY . /app
#upgrade pip first
RUN python -m pip install --upgrade pip

# Install dependencies (if any)
RUN pip install --no-cache-dir -r requirements.txt

# Command to run when container starts
CMD ["python", "app.py"]

