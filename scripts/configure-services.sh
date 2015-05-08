#!/bin/bash

apt-get install -fy redis-tools

DATASTORE=$1
if [ "$DATASTORE" == "" ]
then
	DATASTORE="redis"
fi

CONTROLLER=`docker ps -a | grep controller | awk '{print $1}'`
ROUTER=`docker ps -a | grep router | awk '{print $1}'`
REDIS=`docker ps -a | grep redis | awk '{print $1}'`
MYSQL=`docker ps -a | grep mysql | awk '{print $1}'`
RABBITMQ=`docker ps -a | grep rabbitmq | awk '{print $1}'`

cd /services/controller
sudo docker build -t paas-controller .

cd /services/router 
sudo docker build -t paas-router .

if [ "$REDIS" == "" ]
then
	docker run -p 6379:6379 -m 64m --name redis -d redis
	sleep 2
	redis-cli sadd hosts 192.168.0.240
else
	#If stopped start it
	START_CHECK=`docker ps | grep redis`
	if [ "$START_CHECK" == "" ]
	then
		docker start $REDIS
	fi
fi

if [ "$MYSQL" == "" ]
then
	docker run -p 3306:3306 -m 64m --name mysql -d tutum/mysql
	sleep 10 
	docker exec -i mysql mysql -e "create database paas"
	docker exec -i mysql mysql -e "grant all on *.* to 'root'@'%' identified by 'dev' with grant option" 
	docker exec -i mysql mysql -e "flush privileges"
else
       #If stopped start it
        START_CHECK=`docker ps | grep mysql`
        if [ "$START_CHECK" == "" ]
        then
                docker start $MYSQL 
        fi
fi

if [ "$RABBITMQ" == "" ]
then
	RABBITMQ=`docker run -p 5672:5672 -p 15672:15672 -m 128m --name rabbitmq -d tutum/rabbitmq`
	sleep 5
	#Now get password and setup rabbitmq
	USER_DETAILS=""
	while [ "$USER_DETAILS" == "" ]
	do
		USER_DETAILS=`docker logs $RABBITMQ | grep curl | awk '{print $3}'`
		sleep 2
	done
	curl -XPUT -u $USER_DETAILS -H 'Content-type: application/json' http://localhost:15672/api/users/paas -d '{ "password": "paas", "tags": "administator" }'
	curl -XPUT -u $USER_DETAILS -H 'Content-type: application/json' http://localhost:15672/api/vhosts/paas
	curl -XPUT -u $USER_DETAILS -H 'Content-type: application/json' http://localhost:15672/api/permissions/paas/paas -d '{"scope":"paas","configure":".*","write":".*","read":".*"}'
	curl -XPUT -u $USER_DETAILS -H 'Content-type: application/json' http://localhost:15672/api/permissions/paas/admin -d '{"scope":"paas","configure":".*","write":".*","read":".*"}'
	curl -XPUT -u $USER_DETAILS -H 'Content-type: application/json' http://localhost:15672/api/exchanges/paas/paas -d '{"type":"topic","auto_delete":true,"durable":true,"arguments":[]}'
	
else
	START_CHECK=`docker ps | grep rabbit`
	if [ "$START_CHECK" == "" ]
	then
		docker start $RABBITMQ
	fi

fi

if [ "$CONTROLLER" != "" ]
then
	docker rm -f $CONTROLLER
fi
docker run -d --name controller -m 256m -e DATASTORE=$DATASTORE -e LOG_LEVEL=DEBUG -e RABBITMQ_URI="amqp://paas:paas@192.168.0.240:5672/paas" -e REDIS_HOST="192.168.0.240" -e SQL_ADDRESS="mysql://root:dev@192.168.0.240:3306/paas" -p 8000:8000 paas-controller

if [ "$ROUTER" != "" ]
then
	docker rm -f $ROUTER
fi
docker run -d --name router -m 64m -e RABBITMQ_URI="amqp://paas:paas@192.168.0.240:5672/paas" -p 80:80 -p 8004:8000 paas-router
