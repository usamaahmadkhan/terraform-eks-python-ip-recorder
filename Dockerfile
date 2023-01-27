FROM python:3.12.0a4-alpine3.17

COPY requirements.txt /
RUN pip3 install -r /requirements.txt

COPY gunicorn.sh /
WORKDIR /app
COPY main.py /app
COPY html /app/html

ENTRYPOINT ["/gunicorn.sh"]