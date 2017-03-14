# centos7_base_box

## Introduction

base box for islandora vagrant built on centos7

## Requirements

1. [VirtualBox](https://www.virtualbox.org/)
2. [Vagrant](http://www.vagrantup.com)
3. [git](https://git-scm.com/)

## Use

1. `git clone https://github.com/pc37utn/centos7_base_box`
2. `cd islandora_vagrant_base_box`
3. `vagrant up`

## Connect

Note: The supplied links apply only to this local vagrant system. They could vary in other installations. 
* This base box uses the current available centOS 7 packages and updates. 
* to use this base box, a custom copy of islandora_vagrant should be made where the location of tomcat and the apache and tomcat users are different.

In centOS 7
1. tomcat is at /usr/share/tomcat, instead of /usr/share/tomcat7
2. the tomcat user is "tomcat" instead of tomcat7
3. the apache user is "apache", instead of www-data

You can connect to the machine via the browser at [http://localhost:8000](http://localhost:8000).

The default Drupal login details are:
  - username: admin
  - password: islandora

MySQL:
  - username: root
  - password: islandora

[Tomcat Manager:](http://localhost:8080/manager)
  - username: islandora
  - password: islandora

[Fedora:](http://localhost:8080/fedora/) ([Fedora Admin](http://localhost:8080/fedora/admin) | [Fedora Risearch](http://localhost:8080/fedora/risearch) | [Fedora Services](http://localhost:8080/fedora/services/))
  - username: fedoraAdmin
  - password: fedoraAdmin

[GSearch:](http://localhost:8080/fedoragsearch/rest)
  - username: fedoraAdmin
  - password: fedoraAdmin

ssh, scp, rsync:
  - username: vagrant
  - password: vagrant
  - Examples
    - `ssh -p 2222 vagrant@localhost` or `vagrant ssh`
    - `scp -P 2222 somefile.txt vagrant@localhost:/destination/path`
    - `rsync --rsh='ssh -p2222' -av somedir vagrant@localhost:/tmp`

## Procedure to save the box

1. log into the VM
  - vagrant ssh
2. follow the instructions in virtualbox-guest-add-install.txt to add the guest-additions to your VM.

3. finish what vagrant could not, relabeling the selinux entries, (since it cannot reboot itself)
  - sudo shutdown -r now
4. wait several minutes and log into the VM
  - vagrant ssh
5. check for leftover install directories in /tmp
  - remove the ones for gsearch, solr, fcrepo, fits, etc. this will make the final base box size much smaller
6. zero out the virtual drive to save space 
  - sudo dd if=/dev/zero of=/EMPTY bs=1M
  - sudo rm -f /EMPTY
7. exit out to centos7_base_box directory
  - exit
8. run this from inside the base box directory, it will save a copy of the modified box. (first, edit version number!!!!)
  - vagrant package --output c7vbb-0.1.x.box
9. move the box file to a local web server that the devel team and a modified islandora vagrant instance can access when it starts up.

## Maintainers

* [Paul Cummins](https://github.com/pc37utn/)

## Development

Pull requests are welcome, as are use cases and suggestions.

## License

[GPLv3](http://www.gnu.org/licenses/gpl-3.0.txt)
