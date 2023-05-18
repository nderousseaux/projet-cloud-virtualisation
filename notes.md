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

Du coup il est super simple de déployer en local sur ta machine (tout est dans le `readme.md`)

### 2 - Consul 

J'ai paramétré elmerforst et baggersee pour qu'ils soient des noeuds/agents consul/nomad. Les fichiers de configs sont dans `/etc/nomad.d/nomad.hcl` et `/etc/consul.d/consul.hcl` des deux vms.

Ensuite j'ai ajouté des nouveaux noeuds dans consul sur `krimmeri` :

```
consul join baggersee.internal.100do.se
consul join elmerforst.internal.100do.se
```

