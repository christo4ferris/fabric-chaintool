
VERSION ?= 0.1_SNAPSHOT

NAME=obcc
LEIN = $(shell which lein || echo ./lein)
BINDIR ?= /usr/bin
JAR = target/uberjar/$(NAME)-$(VERSION)-standalone.jar
SCRIPT = src/scripts/obcc
PROPSDIR = target/properties
PROPS = $(PROPSDIR)/application.properties

SRCS += $(shell find src/$(NAME) -name "*.clj")

all: compile

$(PROPSDIR):
	@mkdir -p $@

$(PROPS): $(PROPSDIR) application.properties.in Makefile
	@echo "Creating application.properties"
	@echo "! DO NOT EDIT!!!" > $@
	@echo "! auto-generated by Makefile.  Edit application.properties.in instead" >> $@
	cat application.properties.in \
	  | sed 's|_VERSION_|$(VERSION)|' \
	  >> $@

project.clj: project.clj.in Makefile $(PROPS)
	@echo "Creating project.clj"
	@echo "; DO NOT EDIT!!!" > project.clj
	@echo "; auto-generated by Makefile.  Edit project.clj.in instead" >> project.clj
	cat project.clj.in \
	  | sed 's|_VERSION_|$(VERSION)|' \
	  | sed 's|_PROPSDIR_|$(PROPSDIR)|' \
	  >> project.clj

compile: project.clj $(PROPS) $(SRCS) Makefile
	@$(LEIN) compile

$(JAR): compile
	@$(LEIN) uberjar

$(PREFIX)$(BINDIR):
	mkdir -p $@

install: $(JAR) $(PREFIX)$(BINDIR) $(SCRIPT)
	cp $(JAR) $(PREFIX)$(BINDIR)/$(NAME).jar
	cp $(SCRIPT) $(PREFIX)$(BINDIR)

clean:
	@echo "Cleaning up.."
	-@rm -rf target
	-@rm -f *~
	-@rm -f project.clj 

