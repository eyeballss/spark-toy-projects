linux terminal 에서 iostat 으로 나오는, 초당 read  값을 누계해본다.  

1.먼저 iostat 을 설치한다.  


    apt-get install sysstat -y  

2.아래 명령어로 나온 iostat 의 결과를 file 로 저장한다.  


    iostat 1 1 > temp

3.temp file을 hdfs(/streaming/data/) 에 넣는다.

4.아래 명령어로 spark shell 을 가동시킨다.  
 

    spark-shell --master yarn  

5.shell 이 가동되면 아래 코드를 통해 초당 read 데이터를 누계해본다.  


    spark.conf.set("spark.sql.shuffle.partitions", 5)
    val str = spark.readStream.textFile("/streaming/data/")
    val sda = str.filter(col("value").startsWith("sda"))
    val sep=sda.map{x => val split = x.split("\\s+"); (split(0), split(2).toDouble, split(3).toDouble, split(4).toDouble, split(5).toDouble)}
    val acc = sep.groupBy("_1").sum("_3").drop("_1")
    val query = acc.writeStream.outputMode("complete").format("console").start().awaitTermination()
 
아래는 실시간으로 누계되는 모습이다.
![](/real-time-io-monitoring/acc.png){:height="50%" width="50%"}
