#!/bin/bash
# contains everything needed to execute chombo in batch mode

if [ $# -lt 1 ]
then
        echo "Usage : $0 operation"
        exit
fi
	
JAR_NAME=/home/pranab/Projects/chombo/target/chombo-1.0.jar
HDFS_BASE_DIR=/user/pranab/vaou
PROP_FILE=/home/pranab/Projects/bin/chombo/etl.properties
HDFS_META_BASE_DIR=/user/pranab/meta

case "$1" in

"genOrder")
	 ./store_order.py createOrders $2 $3 $4 > $5
	 ls -l $5
;;

"loadIncr")
	hadoop fs -rm $HDFS_BASE_DIR/ruag/input/$2
	hadoop fs -put $2 $HDFS_BASE_DIR/ruag/input
	hadoop fs -ls $HDFS_BASE_DIR/ruag/input
;;


"runningAggr")
	echo "running MR RunningAggregator"
	CLASS_NAME=org.chombo.mr.RunningAggregator
	IN_PATH=$HDFS_BASE_DIR/ruag/input
	OUT_PATH=$HDFS_BASE_DIR/ruag/output
	echo "input $IN_PATH output $OUT_PATH"
	hadoop fs -rmr $OUT_PATH
	echo "removed output dir"
	hadoop jar $JAR_NAME  $CLASS_NAME -Dconf.path=$PROP_FILE  $IN_PATH  $OUT_PATH
	hadoop fs -ls $HDFS_BASE_DIR/ruag/output
;;


"replaceAggr")
	hadoop fs -rm $HDFS_BASE_DIR/ruag/input/part-r-00000
	hadoop fs -mv $HDFS_BASE_DIR/ruag/output/part-r-00000 $HDFS_BASE_DIR/ruag/input
	hadoop fs -ls $HDFS_BASE_DIR/ruag/input
;;

"valOutlier")
	echo "running MR OutlierBasedDataValidation"
	CLASS_NAME=org.chombo.mr.OutlierBasedDataValidation
	IN_PATH=$HDFS_BASE_DIR/ruag/input
	OUT_PATH=$HDFS_BASE_DIR/ouva/output
	echo "input $IN_PATH output $OUT_PATH"
	hadoop fs -rmr $OUT_PATH
	echo "removed output dir"
	hadoop jar $JAR_NAME  $CLASS_NAME -Dconf.path=$PROP_FILE  $IN_PATH  $OUT_PATH
	hadoop fs -ls $HDFS_BASE_DIR/ouva/output
;;

"validate")
	echo "running mr ValidationChecker for median"
	CLASS_NAME=org.chombo.mr.ValidationChecker
	IN_PATH=/user/pranab/dava/input
	OUT_PATH=/user/pranab/dava/output
	echo "input $IN_PATH output $OUT_PATH"
	hadoop fs -rmr $OUT_PATH
	echo "removed output dir"
	hadoop fs -rm /user/pranab/output/dava/*
	echo "removed invalid data file"
	hadoop jar $JAR_NAME  $CLASS_NAME -Dconf.path=$PROP_FILE  $IN_PATH  $OUT_PATH
;;

"median")
	echo "running mr NumericalAttrMedian for median"
	CLASS_NAME=org.chombo.mr.NumericalAttrMedian
	IN_PATH=/user/pranab/nuam/input
	OUT_PATH=/user/pranab/nuam/med/output
	echo "input $IN_PATH output $OUT_PATH"
	hadoop fs -rmr $OUT_PATH
	echo "removed output dir"
	hadoop jar $JAR_NAME  $CLASS_NAME -Dconf.path=$PROP_FILE  $IN_PATH  $OUT_PATH
;;

"medAvDev")
	echo "running mr NumericalAttrMedian for median absolute divergence"
	CLASS_NAME=org.chombo.mr.NumericalAttrMedian
	IN_PATH=/user/pranab/nuam/input
	OUT_PATH=/user/pranab/nuam/mad/output
	echo "input $IN_PATH output $OUT_PATH"
	hadoop fs -rmr $OUT_PATH
	echo "removed output dir"
	hadoop jar $JAR_NAME  $CLASS_NAME -Dconf.path=$PROP_FILE  $IN_PATH  $OUT_PATH
;;

*) 
	echo "unknown operation $1"
	;;

esac
