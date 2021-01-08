.PHONY: build start clean 


build: 
	docker build . -t rabbitmq-plugins

start:
	docker network create rabbitmq
	docker run -dit --name rabbit1 --hostname rabbit1 --network rabbitmq -p 5672:5672 -p 15672:15672 -p 1886:1883 -e RABBITMQ_ERLANG_COOKIE='foo bar baz' rabbitmq-plugins
	docker run -dit --name rabbit2 --hostname rabbit2 --network rabbitmq -p 1884:1883 -e RABBITMQ_ERLANG_COOKIE='foo bar baz' rabbitmq-plugins
	sleep 10s
	docker exec -it rabbit2 bash -c 'rabbitmqctl stop_app && rabbitmqctl join_cluster rabbit@rabbit1 && rabbitmqctl start_app && rabbitmqctl cluster_status'
	docker run -dit --name rabbit3 --hostname rabbit3 --network rabbitmq -p 1885:1883 -e RABBITMQ_ERLANG_COOKIE='foo bar baz' rabbitmq-plugins
	sleep 10s
	docker exec -it rabbit3 bash -c 'rabbitmqctl stop_app && rabbitmqctl join_cluster rabbit@rabbit1 && rabbitmqctl start_app && rabbitmqctl cluster_status'
	echo 'visit http://localhost:15672 with username/password guest/guest'

clean:
	docker rm -f rabbit1
	docker rm -f rabbit2
	docker rm -f rabbit3
	docker network rm rabbitmq

# require haproxy "brew install haproxy"
haproxy:
	haproxy -f ./haproxy.cfg

# require node.js, yarn and https://github.com/inovex/mqtt-stresser
monitor:
	yarn start

stress:
	mqtt-stresser-darwin-amd64 -broker  tcp://localhost:1883 -num-clients 50 -num-messages 100 -rampup-delay 1s -rampup-size 10 -global-timeout 30s -timeout 20s





# references
# https://github.com/docker-library/rabbitmq/issues/273#issuecomment-412207393
