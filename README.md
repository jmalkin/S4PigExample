Pig Wrapper sample S4 App
=========================

Introduction
------------
This is a simple demonstration of the use of the Pig wrapper for S4. It takes a sample S4 application (speech02, available through [github.com/s4/s4](http://github.com/s4/s4)) and wraps the PEs so they can be called from Pig running on a Hadoop cluster.  A sample pig script is also provided to demonstrate the full integration.

Requirements
------------

* Linux
* Java 1.6
* Maven
* S4 Core
* S4PigWrapper and associated jars
* Pig 0.8 or higher
* Hadoop 0.20 or higher

Build Instructions
------------------

1. Ensure you have built the S4PigWrapper and collected the jars. Those belong in the lib directory.

2. Modify script/run-pig.sh to ensure environment variables are properly set
      - DATAPATH should point to the path containing the data subdirectory
      - If you want script output in the log file, set LOCAL_MODE=1

3. If NOT running in local mode, copy files in data to the correct hdfs location.

4. Go to the script directory

      ./run-pig.sh speech02.pig

5. Output log file is in speech02.pig.log
