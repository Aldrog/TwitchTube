TARGET = harbour-twitchtube

CONFIG += sailfishapp

DEFINES += OS_SAILFISH

include(common.pri)

QML_FILES += $$files(qml/*.qml,true) \
             $$files(qml/*.js,true) \
             $$files(qml/*.png,true)

CONF_FILES += rpm/harbour-twitchtube.spec \
              rpm/harbour-twitchtube.yaml \
              rpm/harbour-twitchtube.changes

TRANSLATIONS += $$files(translations/*.ts)

OTHER_FILES += $${CONF_FILES} \
               $${QML_FILES} \
               harbour-twitchtube.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

