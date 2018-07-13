FROM python:2
WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

RUN adduser --uid 1000 --disabled-password sintef

COPY . .
COPY ./app /app
COPY ./app/static/js /app/static/js 
COPY ./app/templates /app/templates

CMD [ "python", "app/main.py" ]


