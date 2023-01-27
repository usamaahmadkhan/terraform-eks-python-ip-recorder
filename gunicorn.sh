#!/bin/sh
PORT="${PORT:-8080}"
gunicorn -w 2 main:app -b 0.0.0.0:$PORT