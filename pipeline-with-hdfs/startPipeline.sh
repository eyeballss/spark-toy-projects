#! /bin/bash

hdfs dfs -rm -r /streaming/checkpointLocation
hdfs dfs -rm -r /streaming/out/*
hdfs dfs -mkdir /streaming/checkpointLocation
nc -lp 9999
