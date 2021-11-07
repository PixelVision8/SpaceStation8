# Space Station 8
![Pixel Vision 8](https://github.com/PixelVision8/SpaceStation8/workflows/Space%20Station%208/badge.svg)

**Space Station 8** is a `Micro Platformer` created [in 72 hours for Ludum Dare 49](https://ldjam.com) based on a game I used to play on my original Macintosh called [Spacestation Pheta](https://en.wikipedia.org/wiki/Spacestation_Pheta). Space Station 8 is also heavily inspired by [Bitsy](http://make.bitsy.org) and my Fantasy Console, [Pixel Vision 8](https://pixelvision8.com), which I used to create the game.

## Quick Start Guide

I've tried my best to make compiling Space Station 8 from the source as easy as possible. While you can learn more about this in the [docs](https://github.com/PixelVision8/PixelVision8/wik), here is the quickest way to build PV8 from scratch:

> Before you get started, you are going to want to install [.Net 5](https://dotnet.microsoft.com/download/dotnet/5.0), [NodeJS](https://nodejs.org/en/download/), and an IDE like [Visual Studio Code](https://code.visualstudio.com/Download).

1. Clone the main repo `> git clone https://github.com/PixelVision8/PixelVision8.git`
2. Install the NodeJS dependencies `> npm install`
3. Run the default Gulp action `> gulp`
4. Launch the `.dll` manually `dotnet App/bin/Debug/net5.0/SpaceStation8.dll`

If you want to build Space Station 8's executables, you can use the Gulp action `> gulp package`. This will create a new `Releases/Final/` folder, and inside, you'll zip files for Windows, Mac, and Linux. I call the task via a custom GitHub Action to build and upload Space Station 8 releases to this repo.

Finally, you can use Visual Studio Code to debug a build by running one of the custom tasks included in the `.vscode` folder.

### Credits

Space Station was created by Jesse Freeman ([@jessefreeman](http://twitter.com/jessefreeman)) in collaboration with Ben Maksym ([@CastPixel](http://twitter.com/linkerbm)) for art.

### License

Space Station 8 and Pixel Vision 8 is Licensed under the [Microsoft Public License (MS-PL) License](https://opensource.org/licenses/MS-PL). See the [LICENSE file](https://github.com/PixelVision8/PixelVision8/blob/master/LICENSE.txt) in the project root for complete license information.

> Pixel Vision 8 is Copyright (c) 2017-2021 Jesse Freeman. All rights reserved.