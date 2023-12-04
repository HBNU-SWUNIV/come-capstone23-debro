import os
import datetime


def capture_image():
    # 저장 경로 설정
    save_directory = "./debro/image" 
    
    # 현재 날짜와 시간으로 파일 이름 생성
    current_time = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    file_name = f"image_{current_time}.jpg"

<<<<<<< HEAD
    os.system(f"libcamera-still -t 1 -o {save_directory}/{file_name}")
=======
    os.system(f"libcamera-still -t 1 -o {save_directory}/{file_name} --vflip") # 카메라가 거꾸로 설치되어 있어 vflip 사용. 정방향일 경우 해당 부분 삭제
>>>>>>> 67538fb (init_client_reupload)
    
    return(file_name)
    



