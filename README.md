#Cross Youtube Downloader

Youtube downloader that runs on Linux, Mac OSX and Windows.

##How to use

On Linux you can create .sh script in app directory:
~~~~ bash
#!/bin/bash
WEBKIT_LOC="../node-webkit-v0.9.2-linux-x64/" #change to node-webkit path
zip -r app.nw *
mv app.nw $WEBKIT_LOC
cd $WEBKIT_LOC
./nw app.nw
~~~~

Then you can use:
~~~~ bash
./run.sh
~~~~