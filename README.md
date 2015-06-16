### PAAS Service

#Components

- controller ( this is the main controller which holds the api, monitor and logger)
- router ( this is the routing engine for the paas )

Documentation for each component can be found under the individual folders

#Glue

There are 2 pieces that drive the paas, a redis server for maintaining config and
a rabbitmq service for communication between services

#Development/Test Pre-Requisites
- Virtualbox
- Vagrant
- Python 2.7
- Python virtualenv

#Testing

To create a test environment run ```make vagrant```, this will create a vagrant 
machine, and generate the docker containers for the components that are required.
These include
- Router
- Rabbitmq Service
- Redis Service
- Controller

Once they are up and running the controller will be available on http://192.168.0.240:8000/web

#Component Documentation

There is additional documentation under the controller and router folder about each component and how to use them
