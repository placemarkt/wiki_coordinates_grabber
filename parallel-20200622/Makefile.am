SUBDIRS = src

test:
	cd testsuite; make 1

upload:
	eval `gpg-agent --daemon`
# make sure $YYYYMMDD is set
	echo $(YYYYMMDD) | grep 20
	cp parallel-$(YYYYMMDD).tar.bz2 parallel-latest.tar.bz2
	cp doc/parallel.directive parallel-$(YYYYMMDD).tar.bz2.directive
	perl -i -pe "s/20\d\d\d\d\d\d/$(YYYYMMDD)/" parallel-*.tar.*directive
	gpg --clearsign --yes parallel-$(YYYYMMDD).tar.bz2.directive

	cp doc/parallel.latest.directive parallel-latest.tar.bz2.directive
	perl -i -pe "s/20\d\d\d\d\d\d/$(YYYYMMDD)/" parallel-latest.tar.*directive
	gpg --clearsign --yes parallel-latest.tar.bz2.directive

	(echo '#!/bin/bash'; \
	 echo; \
	 echo "# To check the signature run:"; \
	 echo "#   echo | gpg"; \
	 echo "#   gpg --auto-key-locate keyserver --keyserver-options auto-key-retrieve parallel-$(YYYYMMDD).tar.bz2.sig"; \
	 echo; \
	 echo "echo | gpg 2>/dev/null"; \
	 echo 'gpg --auto-key-locate keyserver --keyserver-options auto-key-retrieve $$0'; \
	 echo 'exit $$?' ; \
	 echo; \
	 gpg -ab -o - parallel-$(YYYYMMDD).tar.bz2; \
	) > parallel-$(YYYYMMDD).tar.bz2.sig

	(echo '#!/bin/bash'; \
	 echo; \
	 echo "# To check the signature run:"; \
	 echo "#   echo | gpg"; \
	 echo "#   gpg --auto-key-locate keyserver --keyserver-options auto-key-retrieve parallel-latest.tar.bz2.sig"; \
	 echo; \
	 echo "echo | gpg 2>/dev/null"; \
	 echo 'gpg --auto-key-locate keyserver --keyserver-options auto-key-retrieve $$0'; \
	 echo 'exit $$?' ; \
	 echo; \
	 gpg -ab -o - parallel-$(YYYYMMDD).tar.bz2; \
	) > parallel-latest.tar.bz2.sig

	gpg --auto-key-locate keyserver --keyserver-options auto-key-retrieve parallel-latest.tar.bz2.sig
	gpg --auto-key-locate keyserver --keyserver-options auto-key-retrieve parallel-$(YYYYMMDD).tar.bz2.sig

	../ftpsync/src/ftpsync parallel-$(YYYYMMDD).tar.bz2{,.sig,*asc} ftp://ftp-upload.gnu.org/incoming/ftp/
	../ftpsync/src/ftpsync parallel-latest.tar.bz2{,.sig,*asc} ftp://ftp-upload.gnu.org/incoming/ftp/

# This can take 7 minutes
	pushd /tmp; \
	rm -rf /tmp/parallel-$(YYYYMMDD)*; \
	while ! wget https://ftp.gnu.org/gnu/parallel/parallel-$(YYYYMMDD).tar.bz2 ; do sleep 2; done; \
	tar xjvf parallel-$(YYYYMMDD).tar.bz2; \
	cd parallel-$(YYYYMMDD); \
	./configure; \
	make -j && sudo make -j install; \
	pushd; \
	sudo cp /usr/local/bin/parallel /usr/local/bin/parallel-$(YYYYMMDD)

alphaupload:
# Copy of upload
	eval `gpg-agent --daemon`
# make sure $YYYYMMDD is set
	echo $(YYYYMMDD) | grep 20
	cp parallel-$(YYYYMMDD).tar.bz2 parallel-latest.tar.bz2
	cp doc/parallel.directive parallel-$(YYYYMMDD).tar.bz2.directive
	perl -i -pe "s/20\d\d\d\d\d\d/$(YYYYMMDD)/" parallel-*.tar.*directive
	gpg --clearsign --yes parallel-$(YYYYMMDD).tar.bz2.directive

	cp doc/parallel.latest.directive parallel-latest.tar.bz2.directive
	perl -i -pe "s/20\d\d\d\d\d\d/$(YYYYMMDD)/" parallel-latest.tar.*directive
	gpg --clearsign --yes parallel-latest.tar.bz2.directive

	(echo '#!/bin/bash'; \
	 echo; \
	 echo "# To check the signature run:"; \
	 echo "#  echo | gpg"; \
	 echo "#  gpg --auto-key-locate keyserver --keyserver-options auto-key-retrieve parallel-$(YYYYMMDD).tar.bz2.sig"; \
	 echo; \
	 echo "echo | gpg 2>/dev/null"; \
	 echo 'gpg --auto-key-locate keyserver --keyserver-options auto-key-retrieve $$0'; \
	 echo 'exit $$?' ; \
	 echo; \
	 gpg -ab -o - parallel-$(YYYYMMDD).tar.bz2; \
	) > parallel-$(YYYYMMDD).tar.bz2.sig

	(echo '#!/bin/bash'; \
	 echo; \
	 echo "# To check the signature run:"; \
	 echo "#  echo | gpg"; \
	 echo "#  gpg --auto-key-locate keyserver --keyserver-options auto-key-retrieve parallel-latest.tar.bz2.sig"; \
	 echo; \
	 echo "echo | gpg 2>/dev/null"; \
	 echo 'gpg --auto-key-locate keyserver --keyserver-options auto-key-retrieve $$0'; \
	 echo 'exit $$?' ; \
	 echo; \
	 gpg -ab -o - parallel-$(YYYYMMDD).tar.bz2; \
	) > parallel-latest.tar.bz2.sig

	gpg --auto-key-locate keyserver --keyserver-options auto-key-retrieve parallel-latest.tar.bz2.sig
	gpg --auto-key-locate keyserver --keyserver-options auto-key-retrieve parallel-$(YYYYMMDD).tar.bz2.sig

	../ftpsync/src/ftpsync parallel-$(YYYYMMDD).tar.bz2{,.sig,*asc} ftp://ftp-upload.gnu.org/incoming/alpha/

# This can take 7 minutes
	pushd /tmp; \
	rm -rf /tmp/parallel-$(YYYYMMDD)*; \
	while ! wget http://alpha.gnu.org/gnu/parallel/parallel-$(YYYYMMDD).tar.bz2 ; do sleep 2; done; \
	tar xjvf parallel-$(YYYYMMDD).tar.bz2; \
	cd parallel-$(YYYYMMDD); \
	./configure; \
	make -j && sudo make -j install; \
	pushd; \
	sudo cp /usr/local/bin/parallel /usr/local/bin/parallel-$(YYYYMMDD)

monitorman:
# If man page changed: open new pdfman
	inotifywait -qmre MOVED_TO -e CLOSE_WRITE --format %w%f . | parallel -uj1 'echo {=/\.pod$$/ or skip()=};make -j && sudo make install; pdfman {/.} &'

testurls:
	mkdir -p urls
	cd urls && grep -v '(dead)' ../src/* | grep -h -Po 'https?://[^ $$<>")}]+' | perl -pe 's/(&gt|\{).*//;s/\\-/-/g;s/\\n//g;s/&amp;/&/g;s/&#.*//;'"s/'.*//" | grep -Ev 'parallel-(20)?$$|coolwebsite.biz' | sort -u | egrep -v 'example.com|##|\*\(' | parallel -j0 --timeout 33 --bar --tag --joblog joblog --retries 3 neno wget -m -l1 -Q1 '{=$$_=Q($$_)=}'

reconf:
	rm -fr autom4te.cache aclocal.m4 config.h config.h.in config.log Makefile.in missing install-sh
	rm -rf src/Makefile.in
	autoreconf --install -W gnu
	./configure
	make -j
	sudo make install

pack_unpack_and_test_build:
	echo '### Building tar.bz2'
	./configure
	make dist
	make dist-bzip2
	echo "### Unpack parallel-$(YYYYMMDD).tar.bz2"
	cp parallel-$(YYYYMMDD).tar.bz2 /tmp
	cd /tmp && \
	tar xjf parallel-$(YYYYMMDD).tar.bz2 && \
	cd parallel-$(YYYYMMDD) && \
	./configure && make -j && sudo make -j install


EXTRA_DIST = CITATION CREDITS cc-by-sa.txt fdl.txt
