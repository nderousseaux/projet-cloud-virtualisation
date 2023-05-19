# Déploie l'application en production -> script à lancer sur le serveur de production

# On supprime le dossier job-courrant
rm -rf job-courrant

# On copie le dossier nomad job dans 
cp -r nomad-jobs job-courrant

# On modfie le fichier de configuration de nomad, on substitue chaque variable par sa valeur trouvée dans env.sh

# Pour chaque ligne de env-file.hcl
for line in $(cat ../env-file)
do
	# On récupère le nom de la variable
	var=$(echo $line | cut -d'=' -f1)
	# On ajoute '$' devant le nom de la variable
	var='$'$var
	# On récupère la valeur de la variable
	value=$(echo $line | cut -d'=' -f2)
	# On remplace la variable par sa valeur dans le fichier de configuration
	# ATTENTION, il y a des / dans les valeurs, il faut donc utiliser un autre séparateur pour sed

	sed -i "s|$var|$value|g" job-courrant/worker.hcl
	sed -i "s|$var|$value|g" job-courrant/api.hcl

	
done

# On déploie les jobs
nomad job run job-courrant/worker.hcl
nomad job run job-courrant/api.hcl
nomad job run job-courrant/web.hcl
nomad job run job-courrant/haproxy.hcl