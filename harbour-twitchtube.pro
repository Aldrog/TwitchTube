TEMPLATE = subdirs

SUBDIRS += backports QTwitch src

src.depends = backports QTwitch

DISTFILES += rpm/harbour-twitchtube.spec \
             rpm/harbour-twitchtube.yaml \
             rpm/harbour-twitchtube.changes
