import spidev
import time
import RPi.GPIO as GPIO

# SPI 인터페이스 설정
spi = spidev.SpiDev()
spi.open(0, 0)  # SPI 버스 0, 디바이스 0에 연결되어 있다고 가정합니다.
spi.max_speed_hz = 1000000  # 최대 전송 속도 설정 (1MHz)

# SPI 통신으로 MCP3208 칩의 0번 채널에서 ADC 값을 읽어오는 함수
def readChannel(channel):
    if channel < 0 or channel > 7:
        raise ValueError('Channel must be between 0 and 7.')

    # MCP3208 칩으로 데이터 전송
    # 시작 비트(1), 채널과 모드 설정 비트, 더미 비트를 포함한 총 3바이트 전송
    # 읽어온 데이터는 12비트로 구성되어 있음
    adc = spi.xfer2([ 6 | (channel&4) >> 2, (channel&3)<<6, 0])
    data = ((adc[1]&15) << 8) + adc[2]

    return data

def get_pH_value():
    channel = 3  # pH 센서를 연결한 아날로그 핀 번호

    adc_value = readChannel(channel)
    voltage = adc_value * (5.0 / 4095) # 아날로그 값을 전압으로 변환
    pH_value = 3.5 * voltage  # pH 값을 계산

    return pH_value

try:
    while True:
        oe = 20
        GPIO.setmode(GPIO.BCM)
        GPIO.setup(oe, GPIO.OUT)
        GPIO.output(oe, GPIO.HIGH)
        
        # 3번 채널에서 ADC 값을 읽어와서 출력
        channel = 3
        adc_value = readChannel(channel)
        print(adc_value)
        print(f"Channel {channel}: {get_pH_value()}")

        time.sleep(1)  # 1초 대기

except KeyboardInterrupt:
    spi.close()
    GPIO.cleanup()
    print("Keyboard Interrupt!")