# Use the official Python 3.8 slim image as base
FROM python:3.8-slim

# Set the working directory inside the container to /app
WORKDIR /app

# Copy the requirements.txt file from your host to the working directory inside the container
COPY requirements.txt .

# Install the Python dependencies listed in requirements.txt using pip
RUN pip install --no-cache-dir -r requirements.txt

# Copy all files from your host to the working directory inside the container
COPY . .

# Expose port 5000 to allow communication to/from the Flask application running inside the container
EXPOSE 5000

# Run the Gunicorn web server, binding it to all available interfaces on port defined by the $PORT environment variable,
# and specify the entry point of the Flask application (main.py) as 'main:app'
CMD gunicorn --bind 0.0.0.0:$PORT main:app
