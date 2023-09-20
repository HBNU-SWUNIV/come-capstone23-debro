import requests
import json
import os

# 가상 센서 데이터 생성
sensor_data = {"temperature": 25.4, "humidity": 60.2}

# 데이터를 전송
response = requests.post(url="http://192.168.45.188:5000/data",
                         headers={"Content-Type": "application/json"},
                         data=json.dumps(sensor_data),
                         )

# 응답 출력
print(response.text)