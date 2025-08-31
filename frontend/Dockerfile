FROM node:12.12.0-alpine
WORKDIR /frontend-src/

COPY package.json /frontend-src
COPY package-lock.json /frontend-src
RUN npm install
COPY src/ /frontend-src/src
COPY Gulpfile.js /frontend-src
RUN npm run gulp
RUN mv /frontend-src/build /nullchan-frontend
RUN cp -r /frontend-src/node_modules /nullchan-frontend/
WORKDIR /nullchan-frontend
COPY entrypoint.sh /nullchan-frontend
EXPOSE 3000
ENTRYPOINT ["sh", "./entrypoint.sh"]
