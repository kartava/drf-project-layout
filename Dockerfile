FROM --platform=linux/amd64 python:3.11-slim
ENV PYTHONUNBUFFERED 1

# Allows docker to cache installed dependencies between builds
COPY ./requirements requirements
COPY ./requirements.txt requirements.txt
RUN pip install -r requirements.txt

# Adds our application code to the image
COPY . code
WORKDIR code

RUN python manage.py collectstatic --noinput

EXPOSE 8000

# Run cron jobs and production server
CMD gunicorn --bind 0.0.0.0:$PORT --access-logfile - apps.asgi:application -k unicorn.workers.UvicornWorker
