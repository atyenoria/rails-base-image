default:
	docker build -t atyenoria/rails-base . & docker run -it atyenoria/rails-base zsh
s:
	docker run -it atyenoria/rails-base zsh
b:
	docker build -t atyenoria/rails-base .
u:
	dkcob