import Adafruit_DHT
import spidev

# DHT22 센서 핀 번호
sensor_pin = 4

# MCP3208 SPI 설정
spi = spidev.SpiDev()
spi.open(0, 0)  # SPI 버스 0, 디바이스 0번 사용
spi.max_speed_hz = 1000000

# ADC 값을 읽어오는 함수
def read_adc(channel):
    # MCP3208 칩으로 데이터 전송
    # 시작 비트(1), 채널과 모드 설정 비트, 더미 비트를 포함한 총 3바이트 전송
    # 읽어온 데이터는 12비트로 구성되어 있음   
    if channel > 7 or channel < 0:
        return -1

    adc = spi.xfer2([ 6 | (channel&4) >> 2, (channel&3)<<6, 0])
    data = ((adc[1]&15) << 8) + adc[2]
    
    return data
# 퍼센테이지 변환 함수, fc28의 경우 값이 낮을 수록 수분이 많다는 뜻
def convert_to_percentage(adc_value):
    max_adc_value = 4095  # ADC의 최대값
    percentage = 100.0-((adc_value*100)/max_adc_value)
    return percentage

# 온습도 센서 값을 읽어오는 함수
def read_dht22():
    humidity, temperature = Adafruit_DHT.read_retry(Adafruit_DHT.DHT22, sensor_pin)
    return humidity, temperature

#pH 센서 값을 읽어 오는 함수
## 값에 오류 있음 사용 주의
def get_pH_value(channel):
    # channel = pH 센서를 연결한 adc 번호

    adc_value = read_adc(channel)
    voltage = adc_value * (5.0 / 4095) # 아날로그 값을 전압으로 변환
    pH_value = 3.5 * voltage  # pH 값을 계산

    return pH_value
