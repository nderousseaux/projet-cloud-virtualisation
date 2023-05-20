# Projet pour l'UE « Cloud et Virtualisation »

Sujet : [`./sujet/`](./sujet/README.md)

Backend / worker : [`./api/`](./api/README.md)

Frontend : [`./web/`](./web/README.md)

## Test en local

### Définir les variables d'environnement

```
cp .env.exemple .env
```

Puis éditer le fichier `.env`, avec les valeurs nécessaires

```
AWS_ACCESS_KEY_ID=minioadmin
AWS_SECRET_ACCESS_KEY=minioadmin
S3_BUCKET_NAME=images
CELERY_BROKER_URL=redis://db:6379/0
S3_ENDPOINT_URL=http://minio:9000
```

Et changer le fichier `web/public/config.json` :

```
{
  "endpoint": "http://localhost:8081"
}
```

### Lancer le docker compose

```
docker compose up --env-file .env
```

## Déployement

Si la machine krimmeri est accessible via l'alias `krimmeri` et que le repo docker `Quay.io/cloud-projet` est enregistré, il suffit de lancer le script `deploy.sh`.

Le fichier `env-file` donnera les variables d'environnement, un nouveau numéro de version déclanchera un déployement de la nouvelle version.
