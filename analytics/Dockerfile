# Slim Python base matching the app's deps (Flask 3, SQLAlchemy 2, psycopg2-binary).
FROM public.ecr.aws/docker/library/python:3.10-slim

WORKDIR /app

# Install Python dependencies first so this layer is cached unless requirements change.
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy the analytics application source code.
COPY . .

# The Flask analytics API listens on 5153 (APP_PORT).
EXPOSE 5153

CMD ["python", "app.py"]
