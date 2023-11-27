import subprocess
import os

def image_detect(file_name):
    
    # detect.py 실행 명령어
    command = f"python3 ./debro/yolo/detect_test.py --source ./debro/image/{file_name} --weights ./debro/yolo/best.pt --project ./debro/image/detect_image --exist-ok"
    
    # 서브프로세스로 실행
    process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    # 실행이 완료될 때까지 대기
    stdout, stderr = process.communicate()

    # stdout를 줄 단위로 분할하여 리스트로 변환
    plant_length = stdout.decode().split('\n')

    # 빈 줄 제거 (선택사항)
    plant_length = [line for line in plant_length if line.strip()]

    # 리스트 정렬 (예: 오름차순)
    if plant_length:
        plant_length.sort()
    
        pheighth = plant_length[-1]
        pheightl = plant_length[0]
    
        return pheighth, pheightl
    
    else:
        print('리스트가 비어있음')
        return None, None

    # 여기서 stdout에는 detect.py의 표준 출력 결과가 포함됩니다.

