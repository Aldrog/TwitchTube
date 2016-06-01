TEMPLATE = app
TARGET = TwitchTube

load(ubuntu-click)

include(common.pri)

# specify the manifest file, this file is required for click
# packaging and for the IDE to create runconfigurations
UBUNTU_MANIFEST_FILE=ubuntu/manifest.json.in

# specify translation domain, this must be equal with the
# app name in the manifest file
UBUNTU_TRANSLATION_DOMAIN="twitchtube-ubuntu.aldrog"

DEFINES += OS_UBUNTU

RESOURCES += ubuntu-ui/TwitchTube.qrc

QML_FILES += $$files(ubuntu-ui/*.qml,true) \
             $$files(ubuntu-ui/*.js,true)
             
CONF_FILES += ubuntu/TwitchTube.apparmor \
              ubuntu/TwitchTube.png

OTHER_FILES += $${CONF_FILES} \
               $${QML_FILES} \
               ubuntu/TwitchTube.desktop

#specify where the config files are installed to
config_files.path = /TwitchTube
config_files.files += $${CONF_FILES}
INSTALLS += config_files

#install the desktop file, a translated version is 
#automatically created in the build directory
desktop_file.path = /TwitchTube
desktop_file.files = $$OUT_PWD/ubuntu/TwitchTube.desktop
desktop_file.CONFIG += no_check_exist
INSTALLS+=desktop_file

# Default rules for deployment.
target.path = $${UBUNTU_CLICK_BINARY_PATH}
INSTALLS += target
