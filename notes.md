## Ip flotante 

172.16.3.5:8081 :https://homme-de-fer.100do.se/ 

```
ip address add dev vxlan100 172.16.3.5/16
```

## VM1 - Elmerforst

**Ip bastion** : 192.168.70.110

**Ip vxlan :** 172.16.1.10 

**Nom d'hote interne :** elmerforst.internal.100do.se

**Redirection :** 172.16.1.10:8080 -> https://elmerforst.100do.se

## VM2 - baggersee

**Ip bastion** : 192.168.70.101

**Ip vxlan :** 172.16.1.1

**Nom d'hote interne :** baggersee.internal.100do.se

**Redirection :** 172.16.1.1:8080 -> https://baggersee.100do.se

## Orchestrateur - Krimmeri

**Addresse vxlan :** 172.16.1.18 / homme-de-fer.internal.100.do.se

**Interface consul :** https://consul-homme-de-fer.100do.se/

**Interface nomad :** https://nomad-homme-de-fer.100do.se/

## Ce que j'ai fait

### 1 - Docker

J'ai tout conteneurisé. Il y a des Dockerfile dans `api` et dans `web`. Le `docker-compose` est à la racine.

Du coup il est super simple de déployer en local sur ta machine (tout est dans le `readme.md`).

On peut push sur notre repo en buildant (avec la commande qu'il y tout en haut des 3 dockers compose), puis en faisant : `docker push quay.io/cloud-projet/<container>`.

Notre repo docker : https://quay.io/organization/cloud-projet?tab=repos

On se connecte sur chaque vm :

```
docker login quay.io
```

### 2 - Consul 

J'ai paramétré elmerforst et baggersee pour qu'ils soient des noeuds/agents consul/nomad. Les fichiers de configs sont dans `/etc/nomad.d/nomad.hcl` et `/etc/consul.d/consul.hcl` des deux vms.

Ensuite j'ai ajouté des nouveaux noeuds dans consul sur `krimmeri` :

```
consul join baggersee.internal.100do.se
consul join elmerforst.internal.100do.se
```

### 3 - Déployement

### a - Happroxy

On décide de mettre le répartiteur de charge sur elmerforst. On peut voir son job nomad dans `nomad-jobs/haproxy.hcl`. 

```
  affinity {
    attribute = "${node.unique.id}"
    value     = "ae367b9f-487e-2a9f-340e-9396284ee72b"
  }
```

On défini que haproxy devra être préférentiellement sur elmerforst, car elle doit être à un endroit spécifique, mais en cas de problème, nomad devrait automatiquement basculer sur baggersee.

On met l'ip flottante sur elmerforst. Ainsi, homme-de-fer.100do.se redirige vers lui.

Cette configuration :

```frontend http_front
frontend http_front
	 bind *:8081
   default_backend http_back

backend http_back
    balance roundrobin
    server-template cloud 1-10 _web._tcp.service.consul resolvers consul resolve-opts allow-dup-ip resolve-prefer ipv4 check
```

Permet de rediriger les conections entrentes sur 8080 vers une instance de web. L'addresse de cette instance (qui peut être sur l'un ou l'autre des serveur) sera donnée par consul.

### b - Web

On peut voir son job nomad dans `nomad-jobs/web.hcl`.  

## TODO: 

- Faire passer l'ip flottante en ip principale -> Permet de se dirriger sur homme-de-fer -> Fait mais ou pourquoi je ne peux pas me connecter depuis l'extérieur ?
- Faire en sorte de pouvoir lancer plusieurs instances de web (grace à $PORT_NOMAD)
- Faire du scale up auto
- Ajouter les images api/worker et redis

- Si jamais cette elmerforst tombe, pas de soucis, grâce à `keepalived` l'ip flottante sera assignée à baggersee, et nomad transferera l'instance haproxy sur baggersee.
- PAS DE ENV DANS LE FICHIER DE CONFIG -> OU ?
- Auto-deploy sur gitlab
