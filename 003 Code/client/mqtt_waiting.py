import paho.mqtt.client as mqtt
from datetime import datetime
import camera
import sensor

# MQTT 브로커 정보
broker_address = "58.233.72.16"  # 브로커 주소를 입력
port = 2883 
keepalive = 60 # 60초마다 체크

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
        file = camera.capture_image()
        camera.upload_image(file)
    elif payload == "run waterpump":
        sensor.control_pump(3)

if __name__ == '__main__':
    # MQTT 클라이언트 객체 생성
    client = mqtt.Client()

    # 브로커에 연결할 때 호출될 콜백 함수 설정
    client.on_connect = on_connect
    client.on_message = on_message

    # 브로커에 연결
    client.connect(broker_address, port, keepalive)

    # MQTT 브로커와의 통신을 유지하기 위한 루프 시작
    client.loop_start()

    try:
        while True:
            pass
    except KeyboardInterrupt:
        # Ctrl+C를 누르면 루프 종료 및 연결 닫기
        client.loop_stop()
        client.disconnect()
        
    # mosquitto_sub -h [브로커의 ip] -t [메시지 토픽]
    # mosquitto_pub -h [브로커의 ip] -p [포트] -t [메시지 토픽] -m '[보낼 메시지]'
