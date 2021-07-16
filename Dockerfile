FROM python:3.7-slim-stretch

WORKDIR /aproof-icf-classifier

COPY . /aproof-icf-classifier
RUN pip install -r ./requirements.txt 


ENTRYPOINT ["./src/apply/domain_classification.py]