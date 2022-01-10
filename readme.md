#Asynchronus Event Handling using Microservices and Kafka Live Project
### Author: Martin Hermosilla

``` 
  Usage: ./setup.sh [start|stop|status|bootstrap|create_topics|alter_topics]

  options:
    start|stop <all|kafka|zookeeper> starts/stop zookeeper and/or kafka.
          if sub-command is ommited all is assumed
    bootstrap: executes "start all", "create_topics" and "alter_topics" with 3 days retention
    create_topics: create the topics
    alter_topics: alter existing topics (with 3 days retention)
    status <all|kafka|zookeeper> show if zookeeper and/or kafka is running.
          if sub-command is ommited all is assumed

```

### To start Zookeeper you can run the command:

```
#./setup.sh start zookeeper
```

### To start Kafka you can run the command:

```
#./setup.sh start kafka
```

### To create the topics and modify the retention policy

```
#./setup.sh create_topics
```

### There is a single command to start Zookeeper, Kafka and create the topics and modify them

```
#./setup.sh bootstrap
```

