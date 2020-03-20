spark streaming 을 이용하여 데이터 파이프라인을 구축해본다.  
두 개의 spark streaming 프로그램을 사용한다.  
첫번째 saprk streaming 에서는, netcat 으로 들어오는 단어들을 white space를 기준으로 분리하여 hdfs 에 저장한다.  
두번째 spark streaming 에서는, 첫번째 spark streaming 의 결과값들을 이용하여 word count를 한다.  


1.먼저 netcat 을 설치한다.  

    apt-get install netcat -y  

2.아래 스크립트를 실행시키면, spark streaming 의 checkpointLocation 가 리셋되고, 기존 결과값들이 삭제된다.  
또한 netcat 을 이용한 9999번 TCP 포트가 열린다.  

    ./startPipeline.sh

3.아래 명령어로 첫번째와 두번째 spark streaming을 위한 spark shell 을 가동시킨다.  

    spark-shell --master yarn  

4.첫번째 spark shell 에서 아래 코드를 실행하여 5초 동안 netcat 으로 들어오는 모든 단어들을 white space 기준으로 분리하여 hdfs 에 저장한다.  

    import org.apache.spark.sql.streaming.Trigger
    spark.conf.set("spark.sql.shuffle.partitions", 5)
    val lines = spark.readStream.format("socket").option("host", "localhost").option("port", 9999).load()
    val words = lines.as[String].flatMap(_.split(" "))
    val query = words.writeStream.trigger(Trigger.ProcessingTime("5 seconds")).outputMode("append").format("text").option("path", "/streaming/out").option("checkpointLocation", "/streaming/checkpointLocation").start().awaitTermination()
 
5.두번째 spark shell 에서 아래 코드를 실행하여 10초 동안 첫번째 spark streaming의 결과값들을 모아 word count 연산을 하여 console 에 띄운다.  

    import org.apache.spark.sql.streaming.Trigger
    spark.conf.set("spark.sql.shuffle.partitions", 5)
    val str = spark.readStream.textFile("/streaming/out")
    val wc = str.groupBy("value").count()
    val query = wc.writeStream.trigger(Trigger.ProcessingTime("10 seconds")).outputMode("complete").format("console").start().awaitTermination()

아래는 netcat 을 통해 입력한 input 값이다.  
![](/pipeline-with-hdfs/input.png){:height="50%" width="50%"}

아래는 첫번째 spark streaming 을 거쳐 두 번째 spark streaming 에서 처리된 데이터의 결과값이다.  
![](/pipeline-with-hdfs/result.png){:height="50%" width="50%"}
