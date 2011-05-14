Pig Wrapper sample S4 App
=========================

Introduction
------------
This is a simple demonstration of the use of the Pig wrapper for
S4. It takes a sample S4 application (speech02, available through
[github.com/s4/s4](http://github.com/s4/s4)) and wraps the PEs so they
can be called from Pig running on a Hadoop cluster.  A sample pig
script is also provided to demonstrate the full integration.

In addition to S4, this project also depends on
[S4PigWrapper](https://github.com/jmalkin/S4PigWrapper).

Requirements
------------

* Linux
* Java 1.6
* Maven
* s4-core-0.3-SNAPSHOT
* S4PigWrapper 0.1 and dependent jars
* Pig 0.8 or higher
* Hadoop 0.20 or higher

Build Instructions
------------------

1. Create S4PigExample/lib and S4PigExample/applib directories.

2. Ensure you have built S4PigWrapper and collected the jars. Those
belong in S4PigExample/lib.

3. From your main S4 repository, build speech01:
      ./gradlew s4-example-speech01:jar
   and then copy
   s4-examples/speech01/build/libs/s4-example-speech01-0.3-SNAPSHOT.jar
   to S4PigExample/applib

4. Modify script/run-pig.sh to ensure environment variables are properly set
      - DATAPATH should point to the path containing the data subdirectory
      - If you want script output in the log file, set LOCAL_MODE=1

5. If NOT running in local mode, copy files in data to the correct
HDFS location.
      - The last PE in the data flow writes to stdout, so if you want
        to see the output locally, run in local mode.

6. Go to the script directory

      ./run-pig.sh speech02.pig

7. Output log file is in speech02.pig.log
