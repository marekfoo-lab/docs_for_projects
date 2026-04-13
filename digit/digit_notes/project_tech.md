# Configs

https://intragate.ec.europa.eu/jasspr/project_view.php?username=LUNGUEM&number=I199315


## Get to Know

### Jak wygenerowac API do HTML 

fco-public-api.yaml

## Jira

https://citnet.tech.ec.europa.eu/CITnet/bamboo/deploy/viewDeploymentProjectEnvironments.action?id=947060755

https://citnet.tech.ec.europa.eu/CITnet/bamboo/browse/DEVEEV-FBB/

## Logs

Access only from EC laptop 

## MyDB

MySql:admin/admin1234
db:ri-case-dev-mf| ri-case-dev/ri-case-dev

### Bazy developerskie i Testowe 
dev
IP 10.130.137.94 
port: 3306
username: eevidence
pwd  
schema_name ri_case_pl

tst:
IP 10.130.139.60 
port 3306
username: eevidence 
pwd:  
schema backend_pl 

3 bazy trzeba wspierac:
- mariadb - 
- mysql - 

### Cleanup 

## Bruno

- create workspace
- Import collection - uzyc e-delivery.yml z ktorego importuje sie wszystko
- Import globals - right menu - Globals.json

## Intellij

dodac plik env_settings.env do startup aby zaladowal wszystkie zmienne srodowiskowe.

Intelij: crt+shift+v - pokazuje schowek

## Maven

### Build

clean install -Dcheckstyle.skip=true -Dmaven.gitcommitid.skip=true -DskipTests=true -DskipITs=true -Dmaven.compiler.memory=4g -Dmaven.compiler.maxmemory=16g -Djacoco.skip=true -T 8.0C -Dmaven.offline=true -Dfork=true

### Checkstyle

mvn -pl !adapter/secondary/user-repository-port checkstyle:check
Puszczenie checkstyle na całym projekcie (bez User-repo, bo on nie dziedziczy po parencie i wtedy się wykarzacza)

### API

Contract fist approach - From API to Code and DTO: 
-DskipTests=true clean install -pl adapter/primary/rest -am -f pom.xml
Generuje interface uzywane potem do Controlera aby miec polaczenie dokuemntacja kod 
fco-public-api.yaml - recznie pisany i na jego podstawie sa generowane typy generowane takie jak Intefrace dla Controllra oraz DTO's


### Proxy

proxy:http://proxy-t2-bx.welcome.ec.europa.eu:8012
user->internet

## Jaseper Reports

Jak wprowadzic dane do formularza aby zobaczyc jak sie zachowuje?
Aby dodac pole do formularza, nalezy dodac jego zrodlo danych:
- w odpowiednim dataset 
- dodac parameter name="CHECKBOX_CHECKED", wartosc z name jest uzywana w java do mapowania wartosci.

Wysokosc pol - 20px
Zero odstepow pomiedzy kontrolkami
positionType="Float" dla  kind="frame" i kind="textField"

## CI 

CI -> moze byc uruchomione recznie, nie trzeba twrzyc PR.

## GIT 
git checkout -b dev5/fco/feature/DEVEEV-XXX
git push -u origin dev5/fco/feature/DEVEEV-XXX

git branch -D nazwa_brancha
git push origin --delete nazwa_brancha


