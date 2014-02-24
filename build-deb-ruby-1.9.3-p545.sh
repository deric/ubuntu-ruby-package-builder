#!/bin/sh

# Builds on Ubuntu saucy.
version=1.9.3
patch=p545
rubyversion=$version-$patch
rubysrc=ruby-$rubyversion.tar.bz2
checksum=4743c1dc48491070bae8fc8b423bc1a7
destdir=/tmp/install-$rubyversion

sudo apt-get -y install libssl-dev libreadline-dev zlib1g-dev libyaml-dev libgdbm-dev libffi-dev libncurses5-dev wget

if [ ! -f $rubysrc ]; then
  wget -q ftp://ftp.ruby-lang.org/pub/ruby/1.9/$rubysrc
fi

if [ "$(md5sum $rubysrc | cut -b1-32)" != "$checksum" ]; then
  echo "Checksum mismatch!"
  exit 1
fi

echo "Unpacking $rubysrc"
tar -jxf $rubysrc
cd ruby-$rubyversion
./configure --prefix=/usr/local --disable-install-doc --enable-shared && make && make install DESTDIR=$destdir

cd ..
gem list -i fpm || sudo gem install fpm
fpm -s dir -t deb -n ruby$version -v $rubyversion -C $destdir \
  -p ruby-VERSION_ARCH.deb -d "libstdc++6 (>= 4.4.3)" \
  -d "libc6 (>= 2.6)" -d "libffi6 (>= 3.0.10)" -d "libgdbm3 (>= 1.8.3)" \
  -d "libncurses5 (>= 5.7)" -d "libreadline6 (>= 6.1)" \
  -d "libssl1.0.0 (>= 1.0.1)" -d "zlib1g (>= 1:1.2.2)" \
  -d "libyaml-0-2 (>= 0.1.4-2)" \
  usr/local/bin usr/local/lib usr/local/share/man usr/local/include

rm -r $destdir
