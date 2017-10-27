# Download base image ubuntu 16.04
FROM blitznote/debootstrap-amd64:16.04
# Update Software repository
RUN echo 'Acquire::HTTP::Proxy "http://172.17.0.1:3142";' >> /etc/apt/apt.conf.d/01proxy \
 && apt-get update
# install depedencies
RUN apt-get install  --no-install-recommends -y qemu-kvm libvirt-bin bridge-utils cpu-checker locales \
                                                python-pip python-setuptools python-wheel && \
    pip install --upgrade pip && \
    pip install supervisor && \
    pip install supervisor-stdout
# install docker-ce and GNS3-server
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN apt-get install -y gnupg2 dirmngr && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A2E3EF7B
RUN echo "deb https://download.docker.com/linux/ubuntu xenial stable" >> /etc/apt/sources.list && \
    echo "deb http://ppa.launchpad.net/gns3/ppa/ubuntu xenial main" >> /etc/apt/sources.list
RUN apt-get update && apt-get install -y docker-ce gns3-server
# cleanup
RUN apt-get -y autoremove && apt-get clean
RUN locale-gen en_US.UTF-8
# setup supervisord
ENV supervisor_conf /etc/supervisor/supervisord.conf
COPY supervisord.conf ${supervisor_conf}

CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf", "--nodaemon"]

EXPOSE 3080
