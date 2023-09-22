import os
import datetime
import cv2
from image_uploader import upload_image

def capture_image():
    # 저장 경로 설정
    save_directory = "/home/teamdebro/debro/image" 
    
    # 현재 날짜와 시간으로 파일 이름 생성
    current_time = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    file_name = f"image_{current_time}.jpg"

    # 이미지 캡처 및 저장
    capture = cv2.VideoCapture(0)
    ret, frame = capture.read()
    
    if ret:
        save_path = os.path.join(save_directory, file_name)
        cv2.imwrite(save_path, frame)
        
        upload_image(file_name)
        
        print("이미지 저장 완료:", save_path)
        export_name = file_name
    else:
        print("이미지 캡처 실패")
        
    # 카메라 리소스 해제
    capture.release()
    cv2.destroyAllWindows()


