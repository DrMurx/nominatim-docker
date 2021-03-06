FROM postgres:10 as buildstage

ENV BUMP 2018073001

RUN apt-get update && \
	apt-get -y install \
		build-essential \
		cmake \
		curl \
		g++ \
		git \
		libboost-all-dev \
        libboost-filesystem-dev \
        libboost-python-dev \
        libboost-system-dev \
        libbz2-dev \
        libexpat1-dev \
        libgeos++-dev \
        libgeos-dev \
        libpq-dev \
        libproj-dev \
        libxml2-dev \
        postgresql-10-postgis-2.4 \
        postgresql-10-postgis-2.4-scripts \
        postgresql-contrib \
        postgresql-server-dev-10 \
        python-pip \
        python3-pip \
		zlib1g-dev

RUN git clone --depth 1 https://github.com/openstreetmap/Nominatim.git

RUN pip3 install osmium
RUN pip install osmium

RUN cd Nominatim && \
	git submodule update --recursive --init

RUN cd Nominatim && \
	mkdir -p build && \
    cd build && \
    cmake .. && \
    make && \
    make install

FROM postgres:10 as runstage
COPY --from=buildstage /usr/local/ /usr/local/
COPY --from=buildstage /Nominatim /Nominatim

RUN apt-get update && \
	apt-get -y install \
		apache2 \
		curl \
		libapache2-mod-php \
		libboost-filesystem1.62.0 \
		libboost-python1.62.0 \
		libboost-system1.62.0 \
		libproj12 \
        postgresql-10-postgis-2.4 \
        postgresql-10-postgis-2.4-scripts \
        postgresql-contrib \
		php-cli \
		php-db \
		php-intl \
		php-pgsql && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /src

RUN chown postgres /Nominatim/build

COPY nominatim-docker-entrypoint.sh /usr/local/bin/

EXPOSE 5432
EXPOSE 80

WORKDIR /Nominatim/build

ENTRYPOINT ["nominatim-docker-entrypoint.sh"]
