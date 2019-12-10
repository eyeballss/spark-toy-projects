#! /bin/bash


COUNTER=1

rm temp*
hdfs dfs -rm /streaming/data/temp*

while [ $COUNTER -le 10 ];
do

        iostat 1 2 | tail -n 15 > "temp$COUNTER"
        hdfs dfs -put "temp$COUNTER" /streaming/data/
        COUNTER=$(($COUNTER+1))
        sleep 3
done

# tail -n 15 인 이유 : 
# iostat 의 처음 결과는 실시간 io를 반영하지 않는다.
# 실시간 io가 반영된, 두번째로 나오는 결과를 streaming 에 넣고 싶었다.
# 두번째 결과만 따로 save 하는 방법을 몰라서 일단 tail 로
# io 결과 크기만큼 잘라 저장했기 때문에 tail -n 15 라는 코드가 사용되었다.
# 후에 더 나은 방법을 간구하여 업데이트 할 예정.
