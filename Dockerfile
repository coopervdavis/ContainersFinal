FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update && apt-get install -y libpq-dev gcc \
    && rm -rf /var/lib/apt/lists/*

# Assuming requirements.txt is in the root of ch11project
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

# Tell Docker to move into the nested Django project folder
WORKDIR /app/nhl_app

# Tell Docker to move into the nested Django project folder
WORKDIR /app/nhl_app

# Make migrations, apply them to RDS, then start the server
# Make migrations, apply them, load initial data, then start the server
CMD ["sh", "-c", "python manage.py makemigrations nhl_app && python manage.py migrate && python load_data.py && gunicorn --bind 0.0.0.0:8000 config.wsgi:application"]