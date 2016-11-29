#
# Ubuntu Dockerfile
#
# https://github.com/dockerfile/ubuntu
#

# Pull base image.
FROM ubuntu:16.04

# Install.
RUN  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list
RUN  apt-get update
RUN  apt-get -y upgrade
RUN  echo "deb http://cran.rstudio.com/bin/linux/ubuntu xenial/" | tee -a /etc/apt/sources.list
RUN  apt-get update
RUN  apt-get install -y r-base r-base-dev --allow-unauthenticated
RUN  apt-get install -y build-essential
RUN  apt-get install -y software-properties-common
RUN  apt-get install -y byobu curl git htop man unzip vim wget
RUN  apt-get install -y gcc g++ python python-dev mercurial bzr gdb valgrind gsl-bin libgsl0-dev flex bison tcpdump sqlite sqlite3 libsqlite3-dev libxml2 libxml2-dev libgtk2.0-0 libgtk2.0-dev uncrustify doxygen graphviz imagemagick texlive texlive-latex-extra texlive-generic-extra texlive-generic-recommended texinfo dia texlive texlive-latex-extra texlive-extra-utils texlive-generic-recommended texi2html python-pygraphviz python-kiwi python-pygoocanvas libgoocanvas-dev python-pygccxml
RUN  cd && \
    mkdir ns3 && \
    cd ns3/ && \
    wget https://www.nsnam.org/release/ns-allinone-3.26.tar.bz2 && \
    tar xjf ns-allinone-3.26.tar.bz2 && \
    cd ns-allinone-3.26/ && \
    python build.py --enable-examples --enable-tests && \
    cd ns-3.26/ && \
    ./waf -d debug --enable-examples --enable-tests configure && \
    ./waf

RUN  rm -rf /var/lib/apt/lists/*

ADD script.sh /run.sh


CMD ["sh", "run.sh"]
# CMD ["bash"]
