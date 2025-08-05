# Stage 1: Build environment
FROM python:3.11-slim AS builder
WORKDIR /app
COPY app.py .
RUN pip install flask --no-cache-dir

# Stage 2: Runtime image
FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /app /app
EXPOSE 5000
CMD ["python", "app.py"]
