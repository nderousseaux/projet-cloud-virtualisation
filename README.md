# Projet pour l'UE « Cloud et Virtualisation »

Sujet : [`./sujet/`](./sujet/README.md)

Backend / worker : [`./api/`](./api/README.md)

Frontend : [`./web/`](./web/README.md)

## Déployer en production

### Définir les variables d'environnements

```
cp .env.exemple .env
```

Puis éditer le fichier `.env`, par exemple :

```
ENV AWS_ACCESS_KEY_ID=minioadmin
ENV AWS_SECRET_ACCESS_KEY=minioadmin
ENV S3_BUCKET_NAME=images
```

Lancer le docker compose

```
docker compose up
```
