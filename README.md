#Cross Youtube Downloader

Youtube downloader that runs on Linux, Mac OSX and Windows written in node-webkit.

##Installation
First, download project files. You can do this via:
~~~~ git
git clone https://github.com/Kuzirashi/cross-youtube-downloader.git
~~~~
Then, you need [CoffeeScript](https://github.com/jashkenas/coffee-script) installed. If you have [node package manager](https://github.com/npm/npm) you can satisfy all requirements by running following command from application's folder:
~~~~ bash
npm install
~~~~
You also need [node-webkit](https://github.com/rogerwang/node-webkit)'s prebuilt binary for your OS.

##How to use

You have to zip application's folder and give it `.nw`. Then run it using node-webkit's binary.

On Linux you can create bash(`.sh`) script(you get it when you download project) in application's directory:
~~~~ bash
#!/bin/bash
WEBKIT_LOC="../node-webkit-v0.9.2-linux-x64/" #change to node-webkit path
zip -r app.nw * #create zip file with .nw extension
mv app.nw $WEBKIT_LOC #move .nw file to node-webkit's directory
cd $WEBKIT_LOC #go to node-webkit directory
./nw app.nw #run application
~~~~

Then you can use:
~~~~ bash
./run.sh
~~~~

##License
Cross Youtube Downloader is licensed under [MIT License](https://github.com/Kuzirashi/cross-youtube-downloader/blob/master/LICENSE).

[elementary CSS](https://github.com/nateify/elementary-CSS/) is licensed by Nate Cohen under the [MIT License](http://opensource.org/licenses/MIT)

[elementary Icons](http://danrabbit.deviantart.com/art/elementary-Icons-65437279) are liscensed by [Daniel ForĂŠ](http://danrabbit.deviantart.com/) under the [GPL](http://www.gnu.org/licenses/gpl-3.0.txt)