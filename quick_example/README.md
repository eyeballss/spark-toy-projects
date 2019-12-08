스파크 공식 홈페이지에 있는 quick example 을 따라하며 기본기를 다져본다.
공식 홈페이지 quick example : https://spark.apache.org/docs/latest/structured-streaming-programming-guide.html#quick-example  

1.먼저 서버에 netcat 을 받는다.  


    apt-get install netcat -y  

2.nc -lp 9999 로 9999번 TCP 포트를 연다.  

3.아래 명령어로 spark shell 을 가동시킨다.  


    spark-shell --master yarn  

4.shell 이 가동되면 아래 명령어를 통해 nc 으로부터 오는 문자들의 word count 를 해본다.  


    spark.conf.set("spark.sql.shuffle.partitions", 5)
    val lines = spark.readStream.format("socket").option("host", "localhost").option("port", 9999).load()
    val words = lines.as[String].flatMap(_.split(" "))
    val wordCounts = words.groupBy("value").count()
    val query = wordCounts.writeStream.outputMode("complete").format("console").start().awaitTermination()  
  
위의 코드에서는 output mode 가 complete 였다.
다른 모드와 비교하며, 결과가 어떻게 나오는지 살펴보자.  

< complete mode 결과 >

![](/quick_example/complete%20mode.png){:height="50%" width="50%"}

< update mode 결과 >

![](/quick_example/update%20mode.png){:height="50%" width="50%"}
