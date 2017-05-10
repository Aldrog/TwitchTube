TARGET = harbour-twitchtube

CONFIG += sailfishapp

DEFINES += OS_SAILFISH

include(common.pri)

IMPLEMENTATION_FILES += $$files(qml-implementations/silica/*.qml,true)

qml_implementation.files = qml-implementations/silica/*
qml_implementation.path = /usr/share/$${TARGET}/qml/implementation
INSTALLS += qml_implementation

CONF_FILES += rpm/harbour-twitchtube.spec \
              rpm/harbour-twitchtube.yaml \
              rpm/harbour-twitchtube.changes

TRANSLATIONS += $$files(translations/*.ts)

OTHER_FILES += $${CONF_FILES} \
               $${IMPLEMENTATION_FILES} \
               $${QML_FILES} \
               harbour-twitchtube.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

