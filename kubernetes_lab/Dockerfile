FROM python:3.8-slim-buster

WORKDIR /app
COPY purchases.json .
COPY requirements.txt requirements.txt
RUN pip install --trusted-host pypi.python.org -r requirements.txt


COPY main.py .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]