# centos7_base_box
base box for islandora vagrant built on centos7


#### log into the VM
vagrant ssh

#### to finish what vagrant could not since it can't reboot
sudo shutdown -r now
# wait several minutes and log into the VM
vagrant ssh

#### check for left over install directories in /tmp
remove the ones for gsearch, solr, fcrepo, fits

this will make the final base box size much smaller

#### zero out the drive to save space

-sudo dd if=/dev/zero of=/EMPTY bs=1M
-sudo rm -f /EMPTY

#### exit out to centos7_base_box directory
-exit

#### run this from inside the base box directory,
it will save a copy of the modified box. (first, edit version number!!!!)

 vagrant package --output c7vbb-0.1.x.box

#### move the box file 

to a server that the islandora vagrant instance

can access when it starts up.
