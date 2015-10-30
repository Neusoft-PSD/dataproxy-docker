FROM eccenca/baseimage:1.0.0

MAINTAINER Henri Knochenhauer <henri.knochenhauer@eccenca.com>
MAINTAINER René Pietzsch <rene.pietzsch@eccenca.com>

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /

RUN apt-get update && apt-get install -y -qq --no-install-recommends wget unzip python php5-mysql php5-cli php5-cgi openjdk-7-jre-headless openssh-client python-openssl && apt-get clean
RUN wget https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.zip && unzip google-cloud-sdk.zip && rm google-cloud-sdk.zip

ENV CLOUDSDK_PYTHON_SITEPACKAGES 1

RUN google-cloud-sdk/install.sh --usage-reporting=true --path-update=true --bash-completion=true --rc-path=/.bashrc --disable-installation-options
RUN yes | google-cloud-sdk/bin/gcloud components update --quiet app-engine-php  app-engine-java  app-engine-python  app
RUN mkdir /.ssh
RUN mkdir -p /var/log/dataproxy

ENV PATH /google-cloud-sdk/bin:$PATH

VOLUME ["/.config"]

ADD dataproxy /data

EXPOSE 8080
EXPOSE 8000

WORKDIR /data

CMD dev_appserver.py --host 0.0.0.0 --admin_host 0.0.0.0 dataproxy/ 2>&1 | tee -a /var/log/dataproxy/dataproxy.log
