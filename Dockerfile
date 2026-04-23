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

# Now Gunicorn will be able to see the 'config' folder right next to it!
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "config.wsgi:application"]