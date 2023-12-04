import requests
import json
import schedule
import time
import signal

import sensor


# 전송 중단시
def stoptransmission(signal, frame):
    global stopflag
    sensor.spi.close()
    stopflag = True
    
def send_data():
    
    humidity, temperature = sensor.read_dht22()
    moisture = sensor.read_adc(0)
    moisture = sensor.convert_to_percentage(moisture)
    #pH = get_pH_value(3)
    
    if humidity is not None and temperature is not None and moisture is not None:
        data = {
        'humidity': format(humidity,".2f"),
        'temperature': format(temperature,".2f"),
        'moisture': format(moisture,".2f")
        #,'ph': format(pH,".2f")
        }
        response = requests.post(url, data=json.dumps(data), headers=headers)
        print(response.status_code)
        
        if response.status_code == 200:
            print("데이터 전송 성공")
        else:
            print("데이터 전송 실패")
            
    elif moisture is None:
        print('FC-28 센서 값 읽기 실패')
    else:
        print("DHT22 센서 값 읽기 실패")
if __name__ == '__main__':
    
    # 서버 정보
    #url = 'http://hyunul.com/sensor/'
    url = 'http://43.201.169.32/sensor/'
    headers = {"Content-Type": "application/json"}

    # 임의 중단 플래그
    stopflag = False

    #시그널 핸들러 등록
    signal.signal(signal.SIGINT, stoptransmission)

    schedule.every(10).seconds.do(send_data)

    while True:
        schedule.run_pending()
        time.sleep(1)
