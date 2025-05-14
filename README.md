# install-packettracer-fedora
Script that allows to install cisco packet tracer app in fedora 

Steps to use: 

1. Download install-packettracer.sh
2. Download Cisco Packet Tracer deb package
3. Run the script in the same folder where deb package is locate.
4. Enjoy


Note: this script looks for packet tracer package by its name "Packet_Tracer822_amd64_signed.deb" if packet tracer version change you might have to change the script to look for your file or change the file name of the deb package to the one mentioned above.

Note 2: Packet tracer app has some issues with some linux desktop environments when using dark mode. If you cant see text labels maybe its because of programm showing text in white color. I fixed this problem by creating an script that forces light mode until packet tracer app is closed.


