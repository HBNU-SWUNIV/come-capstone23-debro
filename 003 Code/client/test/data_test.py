import sensor

#이 파일을 상위 폴더로 이동해야 작동함
humidity, temperature = sensor.read_dht22()
moisture = sensor.read_adc(0)
moisture = sensor.convert_to_percentage(moisture)

data = {
        'humidity': format(humidity,".2f"),
        'temperature': format(temperature,".2f"),
        'moisture': format(moisture,".2f")
    }

print(data)