import boto3
import os

access_key = 'AKIAZJGVIYOUWRY6H2YX'
secret_key = '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'
    
def upload_image(file_name):
    # AWS 인증 정보 설정
    
    file_key = f'plant_image/{file_name}'
    local_file = f'/home/teamdebro/debro/image/detect_image/{file_name}'
    # S3 클라이언트 생성
    s3_client = boto3.client(service_name="s3",
                            region_name="ap-northeast-2", 
                            aws_access_key_id=access_key, 
                            aws_secret_access_key=secret_key)

    # 파일 업로드
    try:
        s3_client.upload_file(local_file, "capston-bucket", file_key)
        print("이미지 업로드 완료:", file_key)
    except Exception as e:
        print("이미지 업로드 실패:", str(e))
