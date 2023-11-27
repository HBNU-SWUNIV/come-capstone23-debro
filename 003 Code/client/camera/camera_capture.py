import os
import datetime


def capture_image():
    # 저장 경로 설정
    save_directory = "./debro/image" 
    
    # 현재 날짜와 시간으로 파일 이름 생성
    current_time = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    file_name = f"image_{current_time}.jpg"

    os.system(f"libcamera-still -t 1 -o {save_directory}/{file_name}")
    
    return(file_name)
    



