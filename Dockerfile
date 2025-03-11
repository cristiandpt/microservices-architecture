FROM python:3.9-slim
ENV PYTHONUNBUFFERED=1
WORKDIR /usr/src/app
COPY . .
RUN pip install --no-cache-dir fastapi uvicorn pydantic redis
EXPOSE 8000
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]