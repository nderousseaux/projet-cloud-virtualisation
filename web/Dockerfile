# docker build -t cloud-projet/web .
# docker run -p 3000:3000 cloud-projet/web

# On crée une image de l'application node js
FROM node:18

# On crée un dossier pour l'application
WORKDIR /usr/src/app

# On copie les fichiers package.json et package-lock.json
COPY package*.json ./

# On installe les dépendances
RUN npm ci

# On copie le reste des fichiers
COPY . .

# On expose le port 3000
EXPOSE 3000

# On optimise l'application
RUN npm run build

# On lance l'application
CMD [ "npm", "run", "start"	]
