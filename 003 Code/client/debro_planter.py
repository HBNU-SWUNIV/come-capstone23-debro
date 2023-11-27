from datetime import datetime
import json
import time
import requests
import paho.mqtt.client as mqtt
from threading import Thread

import camera
import sensor
from image_detection import image_detect
## yolov5가 설치되어 있어야 함, 경로 지정 필요

# MQTT 브로커 정보
broker_address = "58.233.72.16"  # 브로커 주소를 입력
port = 2883 
keepalive = 60 # 60초마다 체크

# 서버 정보
# url = 'http://hyunul.com/sensor/'
sensor_url = 'http://hyunul.com/sensor/'
length_url = 'http://hyunul.com/length/'

headers = {"Content-Type": "application/json"}

# MQTT 브로커에 연결하는 콜백 함수
def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("MQTT broker에 연결 완료")
        # 특정 토픽 구독
        client.subscribe("debro/camera")
    else:
        print("Failed to connect, error code:", rc)
        
def on_message(client, userdata, message):
    payload = message.payload.decode("utf-8")
    current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    print(f"{current_time} - called topic: {message.topic}")
    
    print("Message payload:", payload)
    
    # 메시지를 수신하면 실행할 특정 코드를 작성.
    if payload == "run camera":
        try:
            file = camera.capture_image()
            pheighth, pheightl = image_detect(file)
            camera.upload_image(file)
            if pheighth is not None and pheightl is not None:
                length_data = {
                    'pheightH': pheighth,
                    'pheightL': pheightl
                }
                response = requests.post(length_url, data=json.dumps(length_data), headers=headers)
                if response.status_code == 200:
                    print("데이터 전송 성공")
                else:
                    print("데이터 전송 실패")
            else:
                print('측정 실패')
        except Exception as e:
            print('오류 발생: ',e)
        
    elif payload == "run waterpump":
        sensor.control_pump(3)
        
def request_thread():
    
    def send_data():
        humidity, temperature = sensor.read_dht22()
        moisture = sensor.read_adc(0)
        moisture = sensor.convert_to_percentage(moisture)
        #pH = get_pH_value(3)
        
        if humidity is not None and temperature is not None and moisture is not None:
            sensor_data = {
            'humidity': format(humidity,".2f"),
            'temperature': format(temperature,".2f"),
            'moisture': format(moisture,".2f")
            #,'ph': format(pH,".2f")
            }
            response = requests.post(sensor_url, data=json.dumps(sensor_data), headers=headers)
            print(response.status_code)
            
            if response.status_code == 200:
                print("데이터 전송 성공")
            else:
                print("데이터 전송 실패")
        else:
            print("센서 값 읽기 실패")
            print(humidity,temperature,moisture)
    while True:
        send_data()
        time.sleep(600) # 600초 마다 작동
            
if __name__ == '__main__':
    # MQTT 클라이언트 객체 생성
    client = mqtt.Client()

    # 브로커에 연결할 때 호출될 콜백 함수 설정
    client.on_connect = on_connect
    client.on_message = on_message

    # 브로커에 연결
    client.connect(broker_address, port, keepalive)
    
    # 스레드 시작
    thread = Thread(target=request_thread)
    thread.start()

    # MQTT 메세지 수신 대기
    client.loop_forever()   