CURRENT_PATH := $(shell pwd)

# Тестовая комманда
current-path:
	@echo $(args)

# Исполнение файла командой `make docker-login LOGIN=user` после вести пароль.
docker-login:
	@docker login -u $(LOGIN) -p-stdin

# Исполнение файла командой `make docker-login LOGIN=user PASS=123`
docker-login-pass:
	@docker login -u $(LOGIN) -p $(PASS)

# Билд образов
build-images:
	@for i in ui post-py comment; \
	  do cd .. && cd src/$$i && pwd && chmod 755 docker_build.sh && ./docker_build.sh && cd ..; \
	    done
