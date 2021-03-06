# Puzzle01
## 1. Instalació Ruby i llibreries
El primer que he fet és instalar ruby a la Raspberry Pi utilitzant la següent comanda:
`sudo apt install ruby-full build-essential``

Per treballar amb Ruby, tot i que podríem seguir treballant per ssh a la terminal utiltizant nano o amb VNC, per faciliat utilitzaré un IDE molt conegut que es VisualStudioCode de Microsoft. 

### 1.1 Instalació de llibreries i requeriments
El lector que faré servir és el PN532. La seva documentacióes pot trobar a [PN532 Documentation](http://www.elechouse.com/elechouse/images/product/PN532_module_V3/PN532_%20Manual_V3.pdf).
El programare utilitzant UART.

La gema que utilitzaré per comunicar-me amb el lector PN532 és [ruby-nfc](https://github.com/hexdigest/ruby-nfc ).
Per poder utilitzar-la, primer s'han d'instalar les següents llibreries:
- libusb-dev: Per accedir als dispositius usb
- libnfc: Per accedir als dispositius RFID
- libfreefare: Per treballar amb targetes MIFARE


La primera llibreria que he instalat és libusb-dev per fe-ho he utilitzat la següent comanda: `sudo apt-get install libusb-dev`.

Seguidament s'ha d'instalar la llibreria libnfc. Es pot compilara partir del codi font utilitzant make però no he sigut capaç d'instalar-la seguint aquest procediment. Per sort a la [pàgina de documentació de lib-nfc](http://nfc-tools.org/index.php/Libnfc#Using_packaged_libnfc) he trobar una versió pre-empaquetada d'aquesta llibreria. Per instalar-la he fet servir la següent comanda: `sudo apt-get install libnfc-bin libnfc-examples libnfc-pn53x-examples`

Finalment he instalat libfreefare amb la següent comanda: sudo `apt-get install autoconf automake git libtool libssl-dev pkg-config`


Un cop instalades les llibreries he provat que el lector funcioni correctament. Aquí m'he trobat amb el següent problema:
Tot i estar connectat correctament, a l'executar la comanda `nfc-poll` dona un error dient que no es troba cap dispositiu.

El primer que he fet és desabilitar els missatges del shell a través del port serie i habilitar l'interfície serie utilitzant la comanda `sudo raspi-config`


Tot i això, la connexiò serie sembla no funcionar. Després de comprovar el cablejat i la posició dels microinterruptors he començat a buscar documentació a Internet. Finalment he trobat la solució. Amb ajuda de la comanda `dmesg | grep tty` he pogut comprovar de quins ports serie disposo i he editat el fitxer `/etc/nfc/libnfc.conf`amb la següent configuració:

```
# Allow device auto-detection (default: true)
# Note: if this auto-detection is disabled, user has to set manually a device
# configuration using file or environment variable
#allow_autoscan = true

# Allow intrusive auto-detection (default: false)
# Warning: intrusive auto-detection can seriously disturb other devices
# This option is not recommended, user should prefer to add manually his device.
allow_intrusive_scan = false

# Set log level (default: error)
# Valid log levels are (in order of verbosity): 0 (none), 1 (error), 2 (info), 3 (debug)
# Note: if you compiled with --enable-debug option, the default log level is "debug"
log_level = 2

# Manually set default device (no default)
# To set a default device, you must set both name and connstring for your device
# Note: if autoscan is enabled, default device will be the first device available in device list.
device.name = "PN532"
device.connstring = "pn532_uart:/dev/ttyS0"
```

Finalment ja puc llegir targetes RFID amb la Raspberry PI. Utilitzant la comanda `nfc-poll`:

```
nfc-poll uses libnfc 1.7.1
NFC reader: pn532_uart:/dev/ttyS0 opened
NFC device will poll during 30000 ms (20 pollings of 300 ms for 5 modulations)
ISO/IEC 14443A (106 kbps) target:
    ATQA (SENS_RES): 00  04  
       UID (NFCID1): 5c  be  0d  30  
      SAK (SEL_RES): 08  
nfc_initiator_target_is_present: Target Released
Waiting for card removing...done.
```
Un cop instalades totes les llibreries  necessàries ja podem instalar la gema utilitzant el següent codi

### 1.2 Instalació de la gema ruby-nfc
Per instalar la gema ruby-nfc només cal utilitzar la següent comanda: `gem install ruby-nfc`

### 1.3 Codi 
El codi que he creat basant-me en els exemples de la gema ruby-nfc és el següent:
```
require 'ruby-nfc'
class Rfid
    # get all readers available with ruby-nfc gem
    @@readers = NFC::Reader.all
    @@debug = false

    # returns UID in hex format
    def read_uid
        if @@debug
            puts "Available readers: #{@@readers}"
        end
        
        @@readers[0].poll(Mifare::Classic::Tag) do |tag|
            begin
                uid = tag.to_s.split()[0].upcase
                if @@debug
                    puts "#{uid}"
                end
                return uid
            rescue Exception => e
                puts e
            end
        end
    end
end


if __FILE__ == $0
    rf = Rfid. new
    puts "Please login with your university card"
    uid = rf.read_uid
    puts uid
end
```

A l'executarl-lo funciona correctament però primer surt el següent error:
`/usr/lib/ruby/vendor_ruby/ffi/struct_layout_builder.rb:90: warning: constant ::Fixnum is deprecated`
La solució a l'error és actualitzar les gemes fent servir la comanda `gem update`.
