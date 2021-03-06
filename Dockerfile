FROM brandoncabael/docker-ruby-2.6

LABEL maintainer "Brandon Cabael <brandon.cabael@gmail.com>"

ENV EDITOR vim

RUN mkdir -p /scripts

ENV INSTALL_PATH /app
RUN mkdir -p $INSTALL_PATH
WORKDIR $INSTALL_PATH

ENV SOPS_SHA 6b1d245c59c46b0f7c1f5b9fa789e0236bdcb44b0602ca1a7cadb6d0aac64c3c
ENV NODE_SHA 01c4605f2b4ea81c1c01d26fe8496571f840e468e782c6421619627487fc525f

ADD https://github.com/mozilla/sops/releases/download/3.0.5/sops_3.0.4_amd64.deb /tmp/sops.deb
ADD https://deb.nodesource.com/setup_8.x /tmp/node.sh

RUN set -ex && \
      # Verify downloaded sops.deb SHA
      echo "$SOPS_SHA /tmp/sops.deb" | sha256sum -c - && \
      # Verify downloaded node.sh SHA
      echo "$NODE_SHA /tmp/node.sh" | sha256sum -c - && \
      # Update apt-get and start install cmd
      apt-get update && apt-get install -qq -y --no-install-recommends \
      # Basic required packages for all rails images
      build-essential git vim gnupg2 && \
      # Install sops from downloaded .deb file
      dpkg -i /tmp/sops.deb && \
      # Install node (only installs 8.x apt repo & key)
      cat /tmp/node.sh | bash && \
      # Run install again for nodejs (after running node.sh, this will install 8.x)
      apt-get install -qq -y -f --no-install-recommends nodejs && \
      # Update bundler gem
      gem install bundler && \
      # Remove tmp install files
      rm /tmp/sops.deb && \
      rm /tmp/node.sh

RUN set -ex && \
      # Placeholder for conditional packages (changes based on variant, generated by update.sh)
      apt-get install -qq -y --no-install-recommends libpq-dev ghostscript libvips libvips-dev graphviz

COPY vimrc /root/.vimrc

COPY *.sh /scripts/

ENTRYPOINT [ "/scripts/docker-entrypoint.sh" ]

CMD bundle exec puma -C config/puma.rb