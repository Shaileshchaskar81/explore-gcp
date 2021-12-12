FROM python:3.7-slim
RUN pip install flask
WORKDIR /app
COPY firstapp.py /app/firstapp.py
ENTRYPOINT ["python"]
CMD ["/app/firstapp.py"]