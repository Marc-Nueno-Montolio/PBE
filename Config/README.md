# Config
## 1.Configuració de la Raspberry Pi.
### 1.1 Descàrrega i planxat de la imatge a la SD.
#### Opció A: Utilitzar Raspberry Pi Imager
Per començar ràpid vaig fer servir l'eina [Raspberry Pi Imager](https://www.raspberrypi.org/software/)
#### Opció B: CLI

## 2.Configuració de la Raspberry PI en mode headless.
El primer que sen's proposa al projecte és configurar la raspberry pi en mode headless per treballar amb facilitat.
Hem de:
- [x] Habilitar el servei SSH
- [x] Connectarnos a una xarxa wifi sense utilitzar cap interfície gràfica
- [x] Assignar una IP estàtica a la Raspberry
	
### 2.1 Configuració headdless inicial
Abans de connectar la Raspberry Pi, i un cop planxada la imatge s'han de modificar alguns fitxers a la partició `/boot`

Per habilitar el servei ssh he creat la carpeta `ssh` dins de la partició boot de la targeta SSD.

Per connectar la Raspberry Pi a la xarxa Wifi he creat l'arxiu `wpa_supplicant.conf `dins de la partició `/boot`. Aquest fitxer més tard al encendre la Raspberry Pi es copiarà a `etc/wpa_supplicant/wpa_supplicant.conf`. El contingut de l'arxiu és el següent:
```
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
	 
network={
	ssid="vodafoneE200"
	psk="***********"
}
```

Seguidament, a l'altra partició de la targeta SD, he editat l'arxiu `etc/dhcpcd.conf`. Aquest arxiu s'encarrega d'assignar una direcció estàtica a la Raspberry Pi. La configuració que he afegit és:
```
# CONFIGURACIO PER A PBE:
interface wlan0
static ip_address=192.168.0.222/24
static routers=192.168.0.1
static domain_name_servers=192.168.0.1      

```
Un cop fet això he reiniciat la Raspberry Pi i al cap d'uns instants m'he connectat per ssh fent servir les credencials següents:

| Usuari| Password|
| ----------- | ----------- |
| pi | raspberry |

`ssh pi@192.168.0.222`


Així he comprovat que la connexió headless per SSH funciona. Tot i això hi ha un problema: Encara que em puc connectar per ssh, semblsa ser que la connexió a Internet no funciona...

Figura1: Fent ping a google.es no obtenim resposta

Tot i això, es pot veure que la Raspberry Pi sí que pot accedir a internet, en concret als nameservers de google.

Figura2: Resposta ping 8.8.8.8

La solució a aquest problema és afegir 8.8.8.8 (o qualsevol servidor dns global) als servidors de noms, dins de `dchpcd.conf`

`static domain_name_servers=192.168.0.1 8.8.8.8`

Aleshores, després de reiniciar la Raspberry Pi, ja tenim connexió.

Figura3: Raspberry Pi connectada a Internet.


### 2.2 Afegir més xarxes a la configuració headless
És interessant configurar la Raspberry Pi amb diverses xarxes wifi, ja que així quan no es treballa des del lloc habitual, es pot fer servir un hotspot com el telèfon mòbil per tal de connectar-se en mode headless també.
Per fer això he editat l'arxiu `wpa_supplicant.conf`

```
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=ES
	 
network={
	ssid="iPhone de M"
	psk="********”
	priority=30
	id_str="Hotspot iPhone"
}

network={
	ssid="*****"
	psk="**********"
	priority=10
	id_str="Wifi Casa"
}

```
A més s’ha d’editar també `dhcpcd.conf` ja que a la nova xarxa, la configuració  IP serà diferent.

Primer s’ha de parar el servei: `sudo systemctl stop dhcpcd`
Un cop fet això podem editar el fitxer de configuració utilitzant el paràmetre ssid per a cada xarxa:
```
# CONFIGURACIO PER A PBE:
interface wlan0
#Treball a casa
ssid vodafoneE200
static ip_address=192.168.0.222/24
static routers=192.168.0.1
static domain_name_servers=192.168.0.1 8.8.8.8
 
#Treball amb hotspot mòvil:
ssid iPhone de Marc
static ip_address=172.20.10.2/28
static routers=192.172.20.10.1
static domain_name_servers=172.20.10.1 8.8.8.8
```

Finalment només ens queda reiniciar el servei: `sudo systemctl daemon-reload && sudo systemctl start dhcpcd`
Una comanda interessant és: `wpa_cli list_networks` ja que permet veure quines xarxes tenim configurades.

Figura4: Habilitar interfície VNC amb raspi-config

### 2.3 Servidor VNC
Per treballar amb un entorn gràfic es fara servir un servidor vnc i el seu visor corresponent. En concret utilitzarem realVNC, i seguirem la guía de configuració que es pot trobar a: [realVNC](https://help.realvnc.com/hc/en-us/articles/360002249917-VNC-Connect-and-Raspberry-Pi#setting-up-your-raspberry-pi-0-0)

Per instalar el servidor VNC he utilitzat les següents comandes:
```
sudo apt-get update 
sudo apt-get install realvnc-vnc-server 
````
Un cop realitzada la instalació, hem d'habilitar l'interfície VNC. Això es pot fer amb la comanda `sudo raspi-config`. Amb això ja tenim tota la configuració del servidor VNC realitzada. Només cal reiniciar la Raspberry Pi i connectar-nos amb l'aplicació client.

### 2.4 Utilitat per mostrar la xarxa i l'adreça en una pantalla LCD

Ja disposava d'una pantalla OLED SSD1306 d'un projecte anterior, així que he pensat que seria una bona idea fer una petita utilitat que mostrés l'adreça IP de la Raspberry Pi i la xarxa a la que està connectada per tal de facilitar el treball.

Per fer això he utilitzat la gema [SSD1306](https://github.com/zeiv/SSD1306-ruby).
Aquesta gema necessita que instal·lem primer [rmagick](https://github.com/rmagick/rmagick). Per instalar-la he executat la següent comanda: `sudo apt-get install libmagickwand-dev` Un cop fet això he instalat la gema rmagick fent servir `gem install rmagick`

Ara ja es pot instalar SSD1306-ruby fent: `gem install SSD1306`

Ara el que s’ha de fer és configurar la raspberry per tal que el kernel carregui els mòduls necessaris per la comunicació I2C. 
Això es pot fer amb la comanda raspi-config
   
Un cop habilitada la interfície i2c s’ha de trobar l’adreça del backpack del display. Això es pot fer fàcilment amb el programa i2c-tools. Primer, però s’ha d’instalar: `sudo apt-get install i2c-tools`

Es pot veure que l’ID del LCD és el 03xC.

Amb la pantalla OLED funcionanat he creat l'script [OLED_info.rb](https://github.com/Marc-Nueno-Montolio/PBE/blob/main/Config/OLED_info.rb) que mostra la informació a la pantalla.

Només queda fer que l’script s’executi al iniciar la raspberry.En concret, volem executar aquesta comanda: ruby /home/pi/PBE/Config/OLED_info.rb &
Per fer això s’ha de crear un arxiu de tipus systemd (servei).
Es crea l’arxiu OLEDInfo.service amb sudo touch /lib/systemd/system/OLEDInfo.service
El contingut de l’arxiu és el següent:

````
[Unit]
Description=Lcd Network Info Service
After=network.target
[Service]
Type=simple
ExecStart=ruby /home/pi/PBE/Config/OLED_info.rb&
Restart=always

[Install]
WantedBy=multi-user.target

```
Finalment s’habilita el servei amb la comanda `sudo systemctl enable OLEDInfo.service`

````
Created symlink /etc/systemd/system/multi-user.target.wants/OLEDInfo.service → /lib/systemd/system/OLEDInfo.service.
````

Un cop fet tot això ja es té el servei headless configurat i a més es pot saber a quina xarxa està connectada la Raspberry Pi a partir de la pantlla OLED, com es pot veure a la imatge següent:
