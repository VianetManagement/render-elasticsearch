# Use the official Elasticsearch Docker image
FROM docker.elastic.co/elasticsearch/elasticsearch:7.16.1@sha256:1000eae211ce9e3fcd1850928eea4ee45a0a5173154df954f7b4c7a093b849f8

# Set the working directory
WORKDIR /usr/share/elasticsearch

# Install the necessary dependencies for SSL setup
USER root
RUN bin/elasticsearch-certutil cert --silent --pem --out /usr/share/elasticsearch/config/certificates.zip

# Unzip the certificates
RUN unzip /usr/share/elasticsearch/config/certificates.zip -d /usr/share/elasticsearch/config

# Copy custom elasticsearch.yml configuration
COPY --chown=1000:0 config/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml

# Add SSL configurations to elasticsearch.yml using 'tee'
RUN echo '
xpack.security.enabled: true
xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.verification_mode: certificate
xpack.security.transport.ssl.key: /usr/share/elasticsearch/config/elastic-certificates/elastic-certificates.key
xpack.security.transport.ssl.certificate: /usr/share/elasticsearch/config/elastic-certificates/elastic-certificates.crt
xpack.security.transport.ssl.certificate_authorities: /usr/share/elasticsearch/config/elastic-certificates/ca.crt
' | tee -a /usr/share/elasticsearch/config/elasticsearch.yml

# Allow Elasticsearch to create `elasticsearch.keystore`
RUN chmod g+ws /usr/share/elasticsearch/config

# Set the correct user for running Elasticsearch
USER 1000:0

# Expose the default Elasticsearch ports
EXPOSE 9200 9300

# Start Elasticsearch
CMD ["bin/elasticsearch"]
