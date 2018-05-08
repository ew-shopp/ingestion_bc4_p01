FROM python:2
WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
COPY ./app /app

CMD [ "python", "app/main.py" ]


