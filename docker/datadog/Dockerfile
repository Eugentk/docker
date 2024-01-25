FROM datadog/agent:7
ARG DD_API_KEY
ARG DD_ENV

ENV DD_API_KEY $DD_API_KEY
ENV DD_ENV $DD_ENV

COPY conf.yml /etc/datadog-agent/conf.d/disk.d/conf.yml