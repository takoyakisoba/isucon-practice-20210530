.PHONY: gogo services/stop logs/truncate app/build services/start bench kataribe
gogo: services/stop logs/truncate app/build services/start bench

services/stop:
	sudo systemctl stop nginx
	ssh app2 "sudo supervisorctl stop isucon-app"
	sudo systemctl stop mysqld

logs/truncate:
	sudo truncate --size 0 /var/log/nginx/access.log
	sudo truncate --size 0 /var/log/nginx/error.log
	sudo truncate --size 0 /var/lib/mysql/mysql-slow.log
	ssh app2 "sudo truncate --size 0 /var/log/isucon-app.log"

app/build:
	ssh app2 "cd /opt/isucon-practice-20210530/app && make build"

services/start:
	sudo systemctl start mysqld
	ssh app2 "sudo supervisorctl start isucon-app"
	sudo systemctl start nginx

bench: workload=2
bench: init=/home/isucon/qualifier_bench/init.sh
bench:
	sudo /home/isucon/qualifier_bench/bin/bench benchmark --workload ${workload} --init ${init}

kataribe:
	sudo cat /var/log/nginx/access.log | kataribe -conf kataribe.toml


# 開発用
.PHONY: up down logs
up:
	docker-compose up -d --build

down:
	docker-compose down

logs:
	docker-compose logs -f

