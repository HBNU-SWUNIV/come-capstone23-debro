import requests
import json

from sensor_module import read_adc, read_dht22, convert_to_percentage

# 서버 정보
url = 'http://hyunul.com/sensor/'
headers = {"Content-Type": "application/json"}

humidity, temperature = read_dht22()
moisture = read_adc(0)
moisture = convert_to_percentage(moisture)



if humidity is not None and temperature is not None:
    data = {
        'humidity': format(humidity,".2f"),
        'temperature': format(temperature,".2f"),
        'moisture': format(moisture,".2f")
    }
    response = requests.post(url, data=json.dumps(data), headers=headers)
    print(response.status_code)
    
    if response.status_code == 200:
        print("데이터 전송 성공")
    else:
        print("데이터 전송 실패")
else:
    print("DHT22 센서 값 읽기 실패")