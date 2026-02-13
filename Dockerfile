FROM python:3.12-slim

# 1. Optimasi Python agar tidak menulis .pyc dan log langsung muncul
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# 2. Security: Buat user non-root
RUN addgroup --system app && adduser --system --ingroup app app \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/**

WORKDIR /app

# 3. Install dependencies lebih awal agar bisa di-cache oleh Docker
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# 4. Copy source code
COPY app ./app

# 5. Beri izin folder ke user app (opsional jika butuh tulis file)
RUN chown -R app:app /app

# 6. Pindah ke user non-privileged
USER app

EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]