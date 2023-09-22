from sensor_module import read_adc, read_dht22, convert_to_percentage

humidity, temperature = read_dht22()
moisture = read_adc(0)
moisture = convert_to_percentage(moisture)

data = {
        'humidity': format(humidity,".2f"),
        'temperature': format(temperature,".2f"),
        'moisture': format(moisture,".2f")
    }

print(data)