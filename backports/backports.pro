TARGET	   = Backports
QT         = core
CONFIG    += exceptions
TEMPLATE = lib

DEFINES += QT_NO_USING_NAMESPACE QT_NO_FOREACH Q_COMPILER_VARIADIC_TEMPLATES
msvc:equals(QT_ARCH, i386): QMAKE_LFLAGS += /BASE:0x67000000

CONFIG += optimize_full c++11

# QtCore can't be compiled with -Wl,-no-undefined because it uses the "environ"
# variable and on FreeBSD and OpenBSD, this variable is in the final executable itself.
# OpenBSD 6.0 will include environ in libc.
freebsd|openbsd: QMAKE_LFLAGS_NOUNDEF =

HEADERS += \
        global/qrandom.h \
        global/qrandom_p.h \
        global/qglobal.h \
        kernel/qcore_unix_p.h \
        kernel/qdeadlinetimer.h

SOURCES += \
        global/qrandom.cpp \
        kernel/qdeadlinetimer.cpp \
        kernel/qelapsedtimer_unix.cpp \
        kernel/qcore_unix.cpp

unix {
    isEmpty(INSTALL_PREFIX): INSTALL_PREFIX = /usr
    target.path = $$INSTALL_PREFIX/lib
    INSTALLS += target
}

