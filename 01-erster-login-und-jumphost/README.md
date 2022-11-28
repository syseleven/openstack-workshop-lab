# Erster Login in Openstack und Jumphost

## Übersicht

Mit dieser Anleitung kannst Du eine einzelne Instance mit einem vorinstallierten 
Openstack Client über das Horizon Dashboard (GUI) erstellen.

Dieser "Jumphost" enthält alle erforderlichen Tools, um mit Openstack zu beginnen.

## Ziel

* erstelle eine Jumphost Instance via Horizon (GUI)
* automatisierte Installation des Openstack Clients in der neuen Instance

## Vorbereitung

* Du brauchst die Login Daten für Openstack
  * Benutzername
  * Passwort
  * Project ID
  * Region Name
* grundlegende Kenntnisse zum Umgang mit einem Linux Terminal und SSH

---

### Login

* Rufe die URL https://cloud.syseleven.de im Browser auf

* melde dich mit deinen Zugangsdaten an
  * Domain: `default`
  * User Name: `<Benutzername>`
  * Password: `<Passwort>`
* Klick auf "CONNECT"

![](images/01-login-window.png)

### Region auswählen

* Überprüfe zunächst in welcher Region Du angemeldet bist und wechsle ggf. auf die richtige Region

![](images/02-select-region.png)

### Heat Stack starten

* Klicke auf "Project" --> "Orchestration" --> "Stacks" um den Beispiel-Stack in Horizon zu erstellen
* Klick auf "Launch Stack"

![](images/03-orchestration-stacks.png)

![](images/04-select-stack-template.png)

* Wähle `URL` als **Template Source** aus
* Kopiere die URL des Beispiel-Stacks `https://raw.githubusercontent.com/syseleven/openstack-workshop-lab/main/01-erster-login-und-jumphost/kickstart.yaml`
* und füge sie in das Feld **Template URL** ein
* Wähle `File` als **Environment Source**
* Klick auf **NEXT**
---

![](images/05-launch-stack.png)

* trage in das Feld **Stack Name** den Namen `workshop` ein
* trage dein Openstack Password in das Feld **Password for User ...** ein
* **flavor:** wähle den Flavor `m1.tiny` aus
* **image:** wähle ein beliebiges `Ubuntu Focal 20.04 (...)` Image aus
* **key_name:** wähle den bereits vorhandenen SSH-Key `...-workshop` aus
* Klick auf "LAUNCH"

---

### Überprüfen und Verbinden

* Daraufhin ist der Stack im Status **Create In Progress** oder **Create Complete**
* Klick auf **Compute** --> **Instances**
* beachte die **Floating IP** in der Spalte **IP Address** deiner neuen Instance
* öffne ein Terminal deiner Wahl und log dich via SSH mit dem Benutzernamen `syseleven` in deine Instance ein:
`ssh syseleven@<Floating IP> -i ~/.ssh/<private SSH key>`

**Beachte:** die Bereitstellung aller nötigen Tools im Jumphost kann wenige Minuten dauern

---

### Einrichten und Testen des Openstack Clients

* Kopiere den folgenden Inhalt in dein SSH Terminal und führe ihn aus

```
cat > /home/syseleven/myopenrc << EOL
export OS_AUTH_URL=https://keystone.cloud.syseleven.net:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_INTERFACE=public
export OS_ENDPOINT_TYPE=public
if [ -z "$OS_REGION_NAME" ]; then unset OS_REGION_NAME; fi
export OS_USER_DOMAIN_NAME="Default"
unset OS_TENANT_ID
unset OS_TENANT_NAME
read -p "Please enter your OpenStack Project ID: " OS_PROJECT_ID
export OS_PROJECT_ID
read -p "Please enter your OpenStack Region Name: " OS_REGION_NAME
export OS_REGION_NAME
read -p "Please enter your OpenStack Username: " OS_USERNAME
export OS_USERNAME
read -sp "Please enter your OpenStack Password: " OS_PASSWORD
export OS_PASSWORD
EOL
```

* aktiviere deine Umgebung für den Openstack Client: 

`source /home/syseleven/myopenrc`

* Bitte gib die folgenden Zugangsdaten ein und bestätige jeweils mit **Enter**
  * `Project ID`
  * `Region Name`
  * `Username`
  * `Password` 

---

### Verwenden des Openstack Clients

* Teste nun den Openstack Client: `openstack server list`

Ergebnis: es sollte der soeben eingerichtete Jumphost angezeigt werden