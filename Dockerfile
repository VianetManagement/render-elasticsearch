# Use the official Elasticsearch Docker image
FROM docker.elastic.co/elasticsearch/elasticsearch:7.16.1@sha256:1000eae211ce9e3fcd1850928eea4ee45a0a5173154df954f7b4c7a093b849f8

# Set the working directory
WORKDIR /usr/share/elasticsearch

# Install necessary dependencies (including unzip)
USER root
RUN apt-get update && apt-get install -y unzip

# Generate SSL certificates using elasticsearch-certutil
RUN bin/elasticsearch-certutil cert --silent --pem --out /usr/share/elasticsearch/config/certificates.zip

# Unzip the certificates and organize them in the correct directory
RUN unzip /usr/share/elasticsearch/config/certificates.zip -d /usr/share/elasticsearch/config/ && \
    mv /usr/share/elasticsearch/config/elastic-certificates.p12 /usr/share/elasticsearch/config/elastic-certificates.zip && \
    mv /usr/share/elasticsearch/config/elastic-certificates.crt /usr/share/elasticsearch/config/elastic-certificates/ && \
    mv /usr/share/elasticsearch/config/elastic-certificates.key /usr/share/elasticsearch/config/elastic-certificates/

# Copy the SSL configuration file into the container
COPY --chown=1000:0 elasticsearch-ssl-config.yml /usr/share/elasticsearch/config/elasticsearch-ssl-config.yml

# Copy the custom elasticsearch.yml configuration file
COPY --chown=1000:0 config/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml

# Optionally, you can append the SSL config from the file to `elasticsearch.yml`
RUN cat /usr/share/elasticsearch/config/elasticsearch-ssl-config.yml >> /usr/share/elasticsearch/config/elasticsearch.yml

# Allow Elasticsearch to create `elasticsearch.keystore`
RUN chmod g+ws /usr/share/elasticsearch/config

# Set the correct user for running Elasticsearch
USER 1000:0

# Expose the default Elasticsearch ports
EXPOSE 9200 9300
