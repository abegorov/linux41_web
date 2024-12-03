#!/bin/sh
python manage.py migrate --noinput
python manage.py createsuperuser --noinput
python manage.py collectstatic --noinput
gunicorn --workers=${WORKERS} --bind=0.0.0.0:8000 mysite.wsgi:application
