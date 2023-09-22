import RPi.GPIO as GPIO
RED = 4
GPIO.setmode(GPIO.BCM)
GPIO.setup(RED, GPIO.OUT)
try:
    while True:
        GPIO.output(RED, GPIO.HIGH)
except KeyboardInterrupt:
    GPIO.cleanup()
    print ('end')