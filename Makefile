VERSION?=0.12.0

all: build/RPMS/x86_64/ycsb-mongo-runner-$(VERSION)-1.el7.centos.x86_64.rpm

ycsb-$(VERSION).tar.gz:
	wget -N https://github.com/brianfrankcooper/YCSB/releases/download/$(VERSION)/ycsb-$(VERSION).tar.gz

build/RPMS/x86_64/ycsb-mongo-runner-$(VERSION)-1.el7.centos.x86_64.rpm: ycsb-$(VERSION).tar.gz ycsb-mongo-runner.spec *.sh *.js
	rpmbuild -bb -D "_topdir $(CURDIR)/build" -D "_sourcedir $(CURDIR)" -D "version $(VERSION)" ycsb-mongo-runner.spec

clean:
	rm -rf build ycsb-$(VERSION).tar.gz
