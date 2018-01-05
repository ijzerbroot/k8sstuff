# https://github.com/elastic/kibana-docker

FROM docker.elastic.co/kibana/kibana-oss:6.1.1
#FROM docker.elastic.co/kibana/kibana:5.6.4

RUN kibana-plugin install https://github.com/sivasamyk/logtrail/releases/download/v0.1.24/logtrail-6.1.1-0.1.24.zip

ADD logtrail.json /usr/share/kibana/plugins/logtrail/logtrail.json
# Add your kibana plugins setup here
# Example: RUN kibana-plugin install <name|url>
#RUN kibana-plugin install x-pack
#RUN kibana-plugin install https://github.com/sirensolutions/sentinl/releases/download/tag-6.0.0/sentinl-v6.0.0.zip
