Ip flotante 

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

Afin d'éviter de partager nos variables d'environnement, elles sont dans un fichier env-file dans deploy uniqement sur krimmeri (l'orchestrateur). Le script deploy met à jour ces variables d'environnement et met à jour les jobs nomad.

Toute la demarche pour déployer est dans le readme.

Si on avait eu plus de temps, le script deploy n'aurait pas subsitué les variables d'environnement (pas ultra secure) mais on aurrait utilisé `vault` lié à nomad pour stockér les variables sensible.

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

```
env {
  PORT    = "${NOMAD_PORT_web}"
  NODE_IP = "${NOMAD_IP_web}"
}
```

Ce morceau de configuration permet à nomad de choisir automatiquement le port et l'ip de l'application web. Il va être enregistré dans consul. Ainsi, on peut lancer plusieurs instances de web et happroxy s'occupera de rediriger les connections ou il faut à l'aide des informations stockés dans consul.

```
 scaling {
      enabled = true
      min = 1
      max = 10
    }
```

Celui là permet d'augmenter le nombre d'instances en cliquant sur un bouton dans l'interface nomad, ensuite haproxy et consul s'occupent du reste comme expliqué dans le paragraphe précédent. 

Pour l'instant le scale up automatique n'est pas encore implémenté.

### C-api

`nomad-jobs/api.hcl`

Same que web

### D - Worker

`nomad-jobs/worker.hcl`

Same que web, mais sans le réseau (il a juste besoin de la fille de message rabitmq)

## TODO: 

- Si jamais cette elmerforst tombe, pas de soucis, grâce à `keepalived` l'ip flottante sera assignée à baggersee, et nomad transferera l'instance haproxy sur baggersee.
- Auto-deploy sur gitlab
- Faire du scale up auto
- Ranger mes scripts
