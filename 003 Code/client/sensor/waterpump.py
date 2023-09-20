import RPi.GPIO as GPIO
import time

# 사용할 GPIO 핀 번호 설정
IN1 = 5
IN2 = 6

# GPIO 핀 모드 설정
GPIO.setmode(GPIO.BCM)
GPIO.setup(IN1, GPIO.OUT)
GPIO.setup(IN2, GPIO.OUT)
GPIO.output(IN1, GPIO.LOW)
GPIO.output(IN2, GPIO.LOW)
# 워터 펌프 제어 함수
def control_pump(second):
    # 모터 드라이브를 작동시키기 위해 GPIO 핀 설정
    GPIO.output(IN1, GPIO.HIGH)
    GPIO.output(IN2, GPIO.LOW)
    # 워터 펌프 작동 시간 지정
    time.sleep(second)
    # PWM 정지 및 GPIO 핀 초기화
    GPIO.output(IN1, GPIO.LOW)
    GPIO.output(IN2, GPIO.LOW)

# 워터 펌프 제어 예시: 10초간 동작
control_pump(10)

print('okay')
# GPIO 리소스 해제
GPIO.cleanup()
