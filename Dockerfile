# Stage 1: Build environment
FROM python:3.11-slim AS builder
WORKDIR /app
COPY app.py .
RUN pip install flask --no-cache-dir

# Stage 2: Runtime image
FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /app /app
# Install flask again in runtime
RUN pip install flask --no-cache-dir
EXPOSE 5000
CMD ["python", "app.py"]
