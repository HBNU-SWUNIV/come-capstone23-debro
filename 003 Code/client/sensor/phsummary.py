import spidev
import time
import statistics

PHSensorPin = 3  # dissolved oxygen sensor analog output pin to Raspberry Pi
VREF = 5.0  # reference voltage for ADC, set according to your ADC
OFFSET = 0.00  # zero drift compensation
SCOUNT = 30  # sum of sample points
analogBuffer = [0] * SCOUNT  # store the analog value in the array, read from ADC

# MCP3208 SPI 설정
spi = spidev.SpiDev()
spi.open(0, 0)  # SPI 버스 0, 디바이스 0번 사용
spi.max_speed_hz = 1000000

def read_adc(channel):
    # MCP3208 칩으로 데이터 전송
    # 시작 비트(1), 채널과 모드 설정 비트, 더미 비트를 포함한 총 3바이트 전송
    # 읽어온 데이터는 12비트로 구성되어 있음
    if channel > 7 or channel < 0:
        return -1

    adc = spi.xfer2([6 | (channel & 4) >> 2, (channel & 3) << 6, 0])
    data = ((adc[1] & 15) << 8) + adc[2]

    return data

def get_median_num(b_array):
    b_array.sort()
    length = len(b_array)
    if length % 2 == 1:
        median = b_array[length // 2]
    else:
        median = (b_array[length // 2] + b_array[length // 2 - 1]) / 2
    return median

def read_ph_value():
    analog_buffer = []
    while True:
        start_time = time.time()
        analog_buffer.append(read_adc(PHSensorPin))
        if len(analog_buffer) == SCOUNT:
            median_voltage = get_median_num(analog_buffer) * VREF / 1024.0
            ph_value = 3.5 * median_voltage +g OFFSET
            analog_buffer.clear()
            return ph_value
        elapsed_time = time.time() - start_time
        if elapsed_time < 0.03:
            time.sleep(0.03 - elapsed_time)

if __name__ == '__main__':
    while True:
        ph_value = read_ph_value()
        print("pH value:", ph_value)
        time.sleep(1)
