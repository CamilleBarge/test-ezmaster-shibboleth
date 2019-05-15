
build:
	docker build -t camillebarge/shibboleth-sp --build-arg http_proxy --build-arg https_proxy .
