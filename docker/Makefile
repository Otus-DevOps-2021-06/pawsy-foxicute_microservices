CURRENT_PATH := $(shell pwd)

# Тестовая комманда
current-path:
	@echo $(CURRENT_PATH)

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

# Вместо felitsia можно использовать переменную которая берется при логине в Docker.
# С помощью этой команды получим список наших образов и можно реализовать пуш образов из этого списка.
# Пока что не могу реализовать. Ибо везде разный синтаксис использования Makefile и часть не работает...
docker-list:
	@docker ps | awk '{print $$2}' | sed '/felitsia/!d'

#push-images:
#	@for i in ui post-py comment; \
#	  do cd .. && cd src/$$i && pwd && docker push $(USERNAME)/ && ./docker_build.sh && cd ..; \
#	    done
