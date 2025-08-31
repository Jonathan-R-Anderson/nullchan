FROM ubuntu:20.04 AS dev
WORKDIR /nullchan
ENV DEBIAN_FRONTEND=noninteractive
# backend dependencies/frontend depndencies/uwsgi, python and associated plugins
RUN apt-get update && apt-get -y --no-install-recommends install python3 python3-pip \
	pipenv uwsgi-core uwsgi-plugin-python3 uwsgi-plugin-gevent-python3 python3-gevent nodejs npm
# install static build of ffmpeg and compress with upx
COPY build-helpers/ffmpeg_bootstrap.py /nullchan/build-helpers/
WORKDIR /nullchan/build-helpers
RUN python3 ffmpeg_bootstrap.py && apt-get -y install upx-ucl && \
	chmod +w ../ffmpeg/ffmpeg && \
	upx -9 ../ffmpeg/ffmpeg && apt-get autoremove -y upx-ucl && \
	rm -rf /var/lib/apt/lists/*
WORKDIR /nullchan
COPY Pipfile /nullchan
COPY Pipfile.lock /nullchan
RUN pipenv install --system --deploy
# point NULLCHAN_CFG to the devmode config file
ENV NULLCHAN_CFG=./deploy-configs/devmode.cfg
# build static frontend files
COPY package.json /nullchan
COPY package-lock.json /nullchan
COPY Gulpfile.js /nullchan
COPY scss /nullchan/scss
RUN npm install && npm run gulp && rm -rf node_modules
# build react render sidecar
WORKDIR /nullchan-frontend
COPY frontend/package.json /nullchan-frontend
COPY frontend/package-lock.json /nullchan-frontend
RUN npm install
COPY frontend/src /nullchan-frontend/src
COPY frontend/Gulpfile.js /nullchan-frontend
RUN npm run gulp
RUN cp -r build/* /nullchan-frontend/
COPY frontend/devmode-entrypoint.sh /nullchan-frontend
# TODO: how do we do this when running/deploying without docker?
RUN mkdir -p /nullchan/static/js
RUN cp /nullchan-frontend/build/client-bundle/*.js /nullchan/static/js/
# copy source files over
WORKDIR /nullchan
COPY migrations /nullchan/migrations
COPY *.py /nullchan/
COPY blueprints /nullchan/blueprints
COPY build-helpers/docker-entrypoint.sh /nullchan/build-helpers/
COPY deploy-configs /nullchan/deploy-configs
COPY model /nullchan/model
COPY resources /nullchan/resources
COPY templates /nullchan/templates
COPY ./build-helpers/docker-entrypoint.sh ./docker-entrypoint.sh
# bootstrap dev image
RUN python3 bootstrap.py
EXPOSE 5000

ENTRYPOINT ["sh", "./docker-entrypoint.sh", "devmode"]

FROM dev AS prod
WORKDIR /nullchan
# clean up dev image bootstrapping
RUN rm ./deploy-configs/test.db
RUN rm -r uploads
RUN apt-get -y autoremove npm nodejs
ENV NULLCHAN_CFG=./deploy-configs/nullchan.cfg
# chown and switch users for security purposes
RUN adduser --disabled-login nullchan
RUN chown -R nullchan:nullchan ./
USER nullchan

# expose uWSGI
EXPOSE 3031
ENTRYPOINT ["sh", "./docker-entrypoint.sh"]
