FROM python:3.12-slim

COPY token-validator.py /usr/local/bin
COPY requirements.txt /tmp

RUN pip install --no-cache-dir -r /tmp/requirements.txt

CMD ["python", "/usr/local/bin/token-validator.py"]
