# TwitchTube

Twitch.tv client for Sailfish OS (Ubuntu Touch vesion is in development - see [Ubuntu Touch](#ubuntu-touch)).

## Features
- Navigate by game
- View top channels
- Browse followed channels and games
- Follow and unfollow channels and games
- Search channels
- Chat

## Get TwitchTube

### Jolla Store
The app is available at Jolla Store for both Jolla and Jolla Tablet.

### Prebuilt packages
You can find prebuilt rpm packages for armv7 and i486 architectures on [releases page](https://github.com/Aldrog/TwitchTube/releases).

### Build from source
- Download and install SailfishOS SDK (https://sailfishos.org/develop/sdk-overview/develop-installation-article/).
- git clone https://github.com/Aldrog/TwitchTube.git
- Go to cloned directory and open harbour-twitchtube.pro with SailfishOS IDE
- Choose target(s) and build

## Ubuntu Touch
UT version of TwitchTube is under development. You can look at the current state by opening ubuntu-twitchtube.pro in Ubuntu SDK.

Video playback doesn't work because UT doesn't have [HLS](https://en.wikipedia.org/wiki/HTTP_Live_Streaming) support included at the moment. This is also the reason why I'm giving this a rather low priority.

There're some discussions going about including HLS codec, so the situation is likely to change soon enough.

## Contributing
You can contribute to TwitchTube development by reporting an issue or by sending a pull request. Either is always welcome, though latter might be difficult at the moment as codebase is not in the best state (there're some refactorings planned e.g. [#13](https://github.com/Aldrog/TwitchTube/issues/13)).

## License
This application is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

See LICENSE.md for more information.
