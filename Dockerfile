FROM debian:stretch-slim AS Gscfuse
ENV GCSFUSE_REPO gcsfuse-stretch

RUN apt-get update && apt-get install --yes --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
  && echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" \
    | tee /etc/apt/sources.list.d/gcsfuse.list \
  && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
  && apt-get update \
  && apt-get install --yes gcsfuse \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

CMD ["sleep", "3600"]


FROM odoo:13.0

# Run Commands as Root
USER root

# Install most-wanted OCA Modules
RUN apt-get update && apt-get upgrade -y && apt install -y git \
      && git clone --single-branch --branch "13.0" https://github.com/OCA/e-commerce.git /mnt/odoo/OCA/e-commerce \
      && git clone --single-branch --branch "13.0" https://github.com/OCA/partner-contact.git /mnt/odoo/OCA/partner-contact \
      && git clone --single-branch --branch "13.0" https://github.com/OCA/pos.git /mnt/odoo/OCA/pos \
      && git clone --single-branch --branch "13.0" https://github.com/OCA/report-print-send.git /mnt/odoo/OCA/report-print-send \
      && git clone --single-branch --branch "13.0" https://github.com/OCA/sale-workflow.git /mnt/odoo/OCA/sale-workflow \
      && git clone --single-branch --branch "13.0" https://github.com/OCA/server-tools.git /mnt/odoo/OCA/server-tools \
      && git clone --single-branch --branch "13.0" https://github.com/OCA/web.git /mnt/odoo/OCA/web \
      && git clone --single-branch --branch "13.0" https://github.com/OCA/website.git /mnt/odoo/OCA/website \
      && chown odoo: -R /mnt/odoo/OCA \
	  && pip3 install python-barcode xlrd

COPY ./addons/ /mnt/extra-addons

COPY --from=Gscfuse /usr/bin/gcsfuse /usr/bin/gcsfuse 
COPY --from=Gscfuse /bin/fusermount /bin/fusermount 
