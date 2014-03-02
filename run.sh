#!/bin/bash
WEBKIT_LOC="../node-webkit-v0.9.2-linux-x64/" #change to node-webkit path
zip -r app.nw * #create zip file with .nw extension
mv app.nw $WEBKIT_LOC #move .nw file to node-webkit directory
cd $WEBKIT_LOC #go to node-webkit directory
./nw app.nw #run application