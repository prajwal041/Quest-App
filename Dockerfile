FROM --platform=linux/amd64 node:10
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
EXPOSE 80
CMD ["npm", "start"]