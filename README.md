Motivation
==========

The aim is to create a disposable Hadoop/HBase/Spark stack where you can test your jobs locally or to submit them to the Yarn resource manager. I am using Docker-Machine to build the environment and Docker-Compose to provision it with the required components. Along with the infrastructure, I am check that it works with a sample Scala project that just probes everything is working as expected. Do not expect nothing fancy in that sample project though.

Thanks
------

I got some existing GitHub projects and made some changes to make them work nicely for this environment:

- HADOOP content is based on: https://github.com/sequenceiq/docker-hadoop-ubuntu
- HBASE content is based on a fork I made from: https://github.com/dajobe/hbase-docker
- wait_for_it.sh: https://github.com/vishnubob/wait-for-it  

Prerequisites
-------------

There are the prerequisites that needs to satisfy in order to run it hopefully without issues:

- Mac OS X
- Docker Engine on Local: 18.09.2
- Docker-Machine on Local: 0.16.1
- Docker-Compose on Docker-Machine: 1.25.1

QuickStart
===========================================

Set-up the new docker-machine to run the HBase Cluster. The docker-machine is an isloated environment from the local machine.

```shell
PROFILE=[AWS_PROFILE] ./download-resources.sh
./configure-localenv.sh -v [DOCKER_MACHINE_NAME]
```

Confirm the installation success

```shell
eval $(docker-machine env [DOCKER_MACHINE_NAME])
```

Start cluster

```shell
./hbase-cluster.sh -p start -v [DOCKER_MACHINE_NAME]
```

If everything goes fine, you should access to this URL:

- HDFS WebApp —> http://[DOCKER_MACHINE_NAME]:50070/
- YARN WebApp —> http://[DOCKER_MACHINE_NAME]:8088/cluster/apps
- HBASE WebApp —> http://[DOCKER_MACHINE_NAME]:16010/master-status


HBASE ZooKeeper is running in port `2181`.
Other important port is the NameNode, which is running on port `8020`. You can change this port though.

Important Note: The containers are running with the `host` network mode, which means that containers are using host network interface. There is no isolation between host and containers from a network standpoint.


Tear Down
=========

When tearing down the entire set-up, runs:

```shell
./hbase-cluster.sh -p stop -v [DOCKER_MACHINE_NAME]       
docker-machine rm [DOCKER_MACHINE_NAME]
DOCKER_MACHINE_NAME=[DOCKER_MACHINE_NAME] ./remove-localenv.sh
```

Control the Cluster
=========

* Stop

```shell
./hbase-cluster.sh -p start -v [DOCKER_MACHINE_NAME]
```

* Stop

```shell
./hbase-cluster.sh -p stop -v [DOCKER_MACHINE_NAME]
```

* Start after rebooting the local machine

```shell
./hbase-cluster.sh -p start_after_reboot -v [DOCKER_MACHINE_NAME]
```

* Display logs for the services

```shell
./hbase-cluster.sh -p logs -v [DOCKER_MACHINE_NAME]
```

* Remove the cluster

```shell
./hbase-cluster.sh -p down -v [DOCKER_MACHINE_NAME]
```



Test your local environment
===========================

Right now you have a small cluster running on your machine (inside a virtualbox VM) an accessible from your host. Let's test it works.

Build the sample Scala project
------------------------------

As part of this git repo, you have a test project in `./scala-test` folder. It is a `sbt` Scala project and it contains three small applications:

1. HBaseTest: just creates a table in HBASE, writes a row and deletes it.
2. SparkTest: just execute a Spark job locally
3. SparkInYarnTest: This app is intended to be executed in YARN. More on this later.

First of all, let's build this project. As we are willing to also run one of these apps in Yarn, we should also create a "uber" jar. So we can achieve both targets (build and create the uber jar) by doing:

    $ cd ./scala-test
    $ sbt assembly


Run it from your local host
---------------------------

In order to run it locally and being able to use HBASE, you can do this:

    $ sbt "run-main HBaseTest"

You can also test you can use Spark:

    $ sbt "run-main SparkTest"

Run it from another Docker container
------------------------------------

In order to give a more _dockerish_ way to work with this, I have created a docker that can submit jobs to Yarn. Internally, that jobs can talk to HBASE/HDFS at its will. That docker container is called `launcher` and you can put the uberjars containing the jobs to be launched in the folder `./launcher/uberjars`.

As we had created a uberjar from our scala-test project, let's copy it:

    $ cp ./scala-test/target/scala-2.10/HadoopYarnHbaseTester-assembly-1.0.jar ./launcher/uberjars/


Now, we can submit that job to the Yarn cluster. We can do it by using Docker-Compose, this way:

    $ docker-compose -f docker-compose.yml -f docker-compose.launcher.yml run launcher "run /uberjars/HadoopYarnHbaseTester-assembly-1.0.jar SparkInYarnTest"

This should work without issues. Let's decompose it a bit:

The launcher container is a container that offers a `sbt` entrypoint. By default it is pointing to the Scala project inside the `./launcher/yarn-launcher` folder. That application offers this simple argument list:

    Usage: YarnLauncher <uberJarPath> <mainClass> [args]

And will submit a new job by using a given main class name withing the given uberJarPath.

So by doing `... run launcher "run /uberjars/HadoopYarnHbaseTester-assembly-1.0.jar SparkInYarnTest"` we are basically issuing this command inside the container:

    sbt run /uberjars/HadoopYarnHbaseTester-assembly-1.0.jar SparkInYarnTest

(which defaults to use the only main application it finds, namely `YarnLauncher`). We are running the application `SparkInYarnTest` that we left aside previously.  

You can execute this:

    $ docker-compose -f docker-compose.yml -f docker-compose.launcher.yml run launcher

And an interactive sbt session will start. Executing `run` will point you to the usage help message:

    > run
    [info] Running YarnLauncher
    Missing parameters
    Usage: sbt run <uberJarPath> <mainClass> [args]

    Exception: sbt.TrapExitSecurityException thrown from the UncaughtExceptionHandler in thread "run-main-0"
    ...

Regarding the first part of the command (`docker-compose -f docker-compose.yml -f docker-compose.launcher.yml run launcher ...`), our hadoop/hbase stack belongs to the (default) docker-compose.yml but we can "build" on top of this by means of additional `yml` files. So for things like commands to be executed on the "cluster", we can decouple the services from the utility containers this way.
To sum up, we are running a command from a container (defined in `docker-compose.launcher.yml`) inside the "cluster" (defined by `docker-compose.yml`).

This pattern can be used to compose different kinds of tasks to the environment, like initialize certain HBASE schemes, or setting up some datasets; and putting them in separated docker-compose files, e.g.:

- docker-compose.init_schema.yml
- docker-compose.load_mockdata.yml

You can customize them at your will.

