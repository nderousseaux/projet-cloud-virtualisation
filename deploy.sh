# Déploie l'application en production
# Redirige les logs vers le fichier deploy.log

# On récupère la version de l'application
echo "Récupération de la version de l'application..."
version=$(cat env-file | grep version | cut -d'=' -f2 | tr -d '"')
echo "Récupération de la version de l'application terminée : $version"

# On build les images docker
echo "Build des images docker..."
docker build -t quay.io/cloud-projet/api:$version -f api/Dockerfile.api api/ > deploy.log 2>&1
if [ $? -ne 0 ]; then
	echo "Erreur lors du build de l'image api"
	exit 1
fi
docker build -t quay.io/cloud-projet/worker:$version -f api/Dockerfile.worker api/ >> deploy.log 2>&1
if [ $? -ne 0 ]; then
	echo "Erreur lors du build de l'image worker"
	exit 1
fi
docker build -t quay.io/cloud-projet/web:$version -f web/Dockerfile web/ >> deploy.log 2>&1
if [ $? -ne 0 ]; then
	echo "Erreur lors du build de l'image web"
	exit 1
fi
echo "Build des images docker terminé."

# On push les images sur le registre
echo "Push des images sur le registre..." 
docker push quay.io/cloud-projet/api:$version >> deploy.log 2>&1
if [ $? -ne 0 ]; then
	echo "Erreur lors du push de l'image api"
	exit 1
fi
docker push quay.io/cloud-projet/worker:$version >> deploy.log 2>&1
if [ $? -ne 0 ]; then
	echo "Erreur lors du push de l'image worker"
	exit 1
fi
docker push quay.io/cloud-projet/web:$version >> deploy.log 2>&1
if [ $? -ne 0 ]; then
	echo "Erreur lors du push de l'image web"
	exit 1
fi
echo "Push des images sur le registre terminé."

# On édite les fichiers de configuration des jobs nomad
echo "Configuration des jobs nomad..."
rm -rf deploy/job-courrant
cp -r deploy/nomad-jobs deploy/job-courrant 
sed -i "s|\$version|$version|g" deploy/job-courrant/worker.hcl
sed -i "s|\$version|$version|g" deploy/job-courrant/api.hcl
sed -i "s|\$version|$version|g" deploy/job-courrant/web.hcl
for line in $(cat env-file)
do
	var=$(echo $line | cut -d'=' -f1)
	var='$'$var
	value=$(echo $line | cut -d'=' -f2)
	sed -i "s|$var|$value|g" deploy/job-courrant/worker.hcl
	sed -i "s|$var|$value|g" deploy/job-courrant/api.hcl
	sed -i "s|$var|$value|g" deploy/job-courrant/web.hcl
done
echo "Configuration des jobs nomad terminée."

# On envoie les jobs sur le serveur
echo "Envoi des jobs sur le serveur..."
scp -r deploy/job-courrant krimmeri:~
echo "Envoi des jobs sur le serveur terminé."

# On supprime les jobs locaux
echo "Suppression du dossier job-courrant local..."
rm -rf deploy/job-courrant
echo "Suppression du dossier job-courrant local terminé."

# On lance les jobs sur le serveur
echo "Lancement des jobs sur le serveur..."
ssh krimmeri "nomad job run job-courrant/worker.hcl" >> deploy.log 2>&1
ssh krimmeri "nomad job run job-courrant/api.hcl" >> deploy.log 2>&1
ssh krimmeri "nomad job run job-courrant/web.hcl" >> deploy.log 2>&1
ssh krimmeri "nomad job run job-courrant/haproxy.hcl" >> deploy.log 2>&1
echo "Lancement des jobs sur le serveur terminé."