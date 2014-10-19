# if your db is currently up to date, just run make setup to touch all the files. otherwise start the db from scratch
MIGRATIONS = $(shell ls db/migrate)
RUN_FILES = $(addprefix db/run/,$(MIGRATIONS))
all: db/run migrate db/run/tests_updated
 
db/run:
	mkdir -p db/run
 
migrate: $(RUN_FILES)

db/run/tests_updated: db/run/update_test
	rake db:test:clone 
	touch db/run/tests_updated
 
db/run/%: db/migrate/%
	$(eval VERSION = $(patsubst db/migrate/%,%,$<))
	rake db:migrate:down db:migrate:up VERSION=$(VERSION) --trace
	touch db/run/$(VERSION)
	touch db/run/update_test
 
clean:
	rm db/run/*

setup: db/run
	$(shell ls db/migrate | xargs -I {} touch db/run/{})
	touch db/run/update_test
