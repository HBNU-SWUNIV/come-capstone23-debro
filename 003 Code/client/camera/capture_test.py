import os
import datetime
import cv2

def testcapture_image():
    # 저장 경로 설정
    save_directory = "/home/teamdebro/debro/image" 
    
    # 현재 날짜와 시간으로 파일 이름 생성
    current_time = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    file_name = f"test_{current_time}.jpg"

    # 이미지 캡처 및 저장
    capture = cv2.VideoCapture(0)
    ret, frame = capture.read()
    
    if ret:
        frame = cv2.rotate(frame,cv2.ROTATE_180)
        save_path = os.path.join(save_directory, file_name)
        cv2.imwrite(save_path, frame)
        
        print("이미지 저장 완료:", save_path)
        # 카메라 리소스 해제
        capture.release() 
        cv2.destroyAllWindows()
        return file_name  # mqtt를 위해 파일명 반환
    
    else:
        print("이미지 캡처 실패")
        
        # 카메라 리소스 해제
        capture.release()
        cv2.destroyAllWindows()
        return None
        
        
testcapture_image()