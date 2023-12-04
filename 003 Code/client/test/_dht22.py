import Adafruit_DHT

# DHT22 센서 핀 번호
sensor_pin = 4


# DHT22 센서에서 값을 읽는 함수
def read_dht22():
    humidity, temperature = Adafruit_DHT.read_retry(Adafruit_DHT.DHT22, sensor_pin)
    return humidity, temperature

humidity, temperature = read_dht22()

print('Temp={0:0.1f}*  Humidity={1:0.1f}%'.format(temperature, humidity))
