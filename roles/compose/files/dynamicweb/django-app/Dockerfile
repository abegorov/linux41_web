ARG PYTHON_VERSION=3.13.0-alpine
FROM python:${PYTHON_VERSION}

ENV APP_ROOT=/app
COPY . "${APP_ROOT}/"
WORKDIR "${APP_ROOT}"
RUN mkdir static; mkdir db; pip install -r requirements.txt

EXPOSE 8000
ENV WORKERS=2
CMD ["/bin/sh", "django-app.sh"]
