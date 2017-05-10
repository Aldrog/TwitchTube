QT += qml quick network dbus
CONFIG += c++11

SOURCES += \
    src/main.cpp \
    src/ircchat.cpp \
    src/tools.cpp \
    src/qmlsettings.cpp \
    src/message.cpp \
    src/messagelistmodel.cpp

HEADERS += \
    src/ircchat.h \
    src/tools.h \
    src/qmlsettings.h \
    src/message.h \
    src/messagelistmodel.h

QML_FILES += $$files(qml/*.qml) \
             $$files(qml/js/*.js) \
             $$files(qml/images/*.png)
