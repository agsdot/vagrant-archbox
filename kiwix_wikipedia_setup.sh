#!/usr/bin/env bash

mkdir -p ~/kiwix
cd ~/kiwix

if [ -f /vagrant/kiwix-0.9+wikipedia_en_for-schools_2013-01.zip ]; then
  # avoid downloading the kiwix wikipedia zip file each and every time if your running this in a vm
  echo "copying file from vagrant directory"
  \cp -r /vagrant/kiwix-0.9+wikipedia_en_for-schools_2013-01.zip ~/kiwix/kiwix-0.9+wikipedia_en_for-schools_2013-01.zip
fi

if [ ! -f ~/kiwix/kiwix-0.9+wikipedia_en_for-schools_2013-01.zip ]; then
  #http://stackoverflow.com/questions/31218477/how-can-only-display-progess-bar-with-wget-in-vagrant-provisioning
  echo "downloading kiwix and wikipedia zipped up"
  #http://download.kiwix.org/portable/wikipedia/
  wget http://download.kiwix.org/portable/wikipedia/kiwix-0.9+wikipedia_en_for-schools_2013-01.zip --progress=bar:force
  echo "done with kiwix and wikipedia zip download"
  unzip -d kiwix-0.9+wikipedia_en_for-schools_2013-01 ~/kiwix/kiwix-0.9+wikipedia_en_for-schools_2013-01.zip
fi

# Can clean up logic later, for this block as well as two preceding ones.
# Just primarily to save time on booting up a vm.
if [ ! -d "~/kiwix/kiwix-0.9+wikipedia_en_for-schools_2013-01" ]; then
  unzip -d kiwix-0.9+wikipedia_en_for-schools_2013-01 ~/kiwix/kiwix-0.9+wikipedia_en_for-schools_2013-01.zip
fi

if [ ! -f ~/kiwix/kiwix-serve ]; then
  echo "download the kiwix-server binary"
  cd ~/kiwix/

  # If not vagrant, i.e. booting up a rpi3
  if [ ! -d /vagrant ]; then
    wget http://pilotfiber.dl.sourceforge.net/project/kiwix/0.9/kiwix-server-0.9-linux-armv5tejl.tar.bz2 --progress=bar:force -O kiwix-server-arm.tar.bz2
    tar xvfj kiwix-server-arm.tar.bz2
  else
    #on vagrant
    wget https://download.kiwix.org/bin/kiwix-linux-x86_64.tar.bz2 --progress=bar:force -O kiwix-linux-x86_64.tar.bz2
    tar xvfj kiwix-linux-x86_64.tar.bz2
    \cp -r ~/kiwix/kiwix/bin/kiwix-* .
    # to manually start it
    #./kiwix-serve --port=8001 ~/kiwix/wikipedia_en_for-schools_2013-01.zim
  fi
fi
echo "done with downloading kiwix-serve binary"

sudo mkdir -p /usr/share/kiwix
sudo \cp ~/kiwix/kiwix-serve /usr/share/kiwix/kiwix-serve
sudo \cp -r ~/kiwix/kiwix-0.9+wikipedia_en_for-schools_2013-01/data/ /usr/share/kiwix/data/

#then use this command to start the server:
#sudo /usr/share/kiwix/kiwix-serve --port=8001 --library /usr/share/kiwix/data/library/wikipedia_en_for_schools_opt_2013.zim.xml

cd ~/vagrant-archbox/setup_files/
#http://uranio-235.github.io/blog/2016/07/31/kiwix-como-servicio/
sudo cp -rf kiwix.service /usr/lib/systemd/system/kiwix.service

echo "systemctl for kiwix"
sudo systemctl enable kiwix
sudo systemctl start kiwix