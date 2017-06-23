/usr/local/src/critical-stack-intel-amd64.rpm:
  file.managed:
    - source: salt://bro/files/critical-stack-intel-amd64.rpm

extract_critical_stack:
  cmd.run:
    - name: rpm -Uvh /usr/local/src/critical-stack-intel-amd64.rpm

install_critical_stack:
  cmd.run:
    - name: yum -y install critical-stack-intel

epel:
  cmd.run:
    - name: yum -y install epel-release
    - timeout: 400

broreqs:
  cmd.run:
    - name: |
        yum -y install cmake make gcc gcc-c++ flex bison libpcap-devel openssl-devel python-devel swig zlib-devel git
    - timeout: 600

/opt/salt/bro-2.3.2.tar.gz:
  file.managed:
    - source: salt://bro/files/bro-2.3.2.tar.gz
    - unless:
      - ls /opt/salt/bro-2.3.2.tar.gz

bro_extract:
  cmd.run:
    - name: cd /opt && tar -xfvz bro-2.3.2.tar.gz
    - unless:
      - ls /opt/bro-2.3.2

bro_install:
  cmd.run:
    - name: cd /opt/bro-2.3.2/ && ./configure && make && make install
    - timeout: 10000
    - unless:
      - ls /usr/local/bro

/usr/local/bro/etc/node.cfg:
  file.managed:
    - source: salt://bro/files/node.cfg

add_intel_framework:
  cmd.run:
    - name: echo "@load policy/frameworks/intel/seen" > /usr/local/bro/share/bro/site/local.bro
    - unless:
      - grep "intel" /usr/local/bro/share/bro/site/local.bro

modify_intel_api:
  cmd.run:
    - name: critical-stack-intel api key_here

pull_intel_feeds:
  cmd.run:
    - name: critical-stack-intel pull

add_auto_bro_restart:
  cmd.run:
    - name: critical-stack-intel config --set bro.restart=true

broctl_check_and_start:
  cmd.run:
    - name: /usr/local/bro/bin/broctl install && /usr/local/bro/bin/broctl check && /usr/local/bro/bin/broctl restart

critical-stack-intel pull:
  cron.present:
    - user: root
    - hour: 12

