FROM python:3.11

WORKDIR /package

COPY ./requirement.txt .

RUN pip install --no-cache-dir -r requirement.txt

COPY ./app.py .

CMD ["python", "app.py"]