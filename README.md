# 한밭대학교 컴퓨터공학과 Debro팀

**팀 구성**

-   20207121 정우진
-   20171609 김종훈
-   20181589 김효정

## <u>Teamate</u> Project Background

-   ### 필요성

1.  바쁜 현대 라이프스타일

-   현대 사회에서는 업무, 가족, 사회 활동 등 다양한 의무가 눈에 띄게 증가하고 있습니다. 이로 인해 많은 사람들은 자연과 가까운 환경에서의 시간을 제한받게 되었습니다. 스마트 플랜터는 바쁜 현대 라이프스타일에 적합한 식물 관리 솔루션을 제공하여, 쉽고 편리하게 식물을 키울 수 있도록 돕습니다.

2.  원예 활동에 대한 관심 상승

-   요즘 사람들은 건강한 라이프스타일과 환경에 대한 관심이 높아지고 있습니다. 이에 따라 원예 활동에 대한 수요도 상승하고 있으며, 스마트 플랜터는 이러한 트렌드에 부합하여 현대인들이 쉽게 원예를 즐길 수 있도록 돕고 있습니다.

> 이에 따라 스마트 플랜터는 고급 센서, 자동 관수 시스템, 모바일 애플리케이션을 통한 원격 모니터링과 제어 등 다양한 기술을 활용하여 사용자들의 식물 관리 경험을 혁신하고 있습니다. 이를 통해 현대 라이프스타일과 원예 활동의 조화로운 결합을 실현하며, 식물을 키우는 즐거움을 더욱 쉽고 편리하게 제공하고 있습니다.

-   ### 기존 해결책의 문제점

    1. 수동 관리의 어려움: 대부분의 기존 해결책은 사용자가 직접 식물을 관리하고 물을 주는데 의존합니다. 이는 바쁜 일상에서는 식물의 요구를 충족하기 어려울 수 있으며, 긴급한 일정이나 여행 중에는 문제가 발생할 수 있습니다.

    2. 자동화 부족: 몇몇 자동 관리 시스템은 있지만, 이들은 종종 고가로 판매되며 설치와 유지보수가 복잡할 수 있습니다. 또한 이러한 시스템은 사용자가 식물의 상태를 실시간으로 모니터링하고 조절할 수 있는 기능을 제공하지 않을 수 있습니다.

    3. 고가성: 일부 자동화된 원예 시스템은 가격이 비싸서 많은 사람들에게 접근하기 어려울 수 있습니다. 이로 인해 원예 활동을 시작하려는 사람들에게 장벽이 될 수 있습니다.

    4. 기술에 대한 의존: 일부 기존 해결책은 고급 기술에 의존하기 때문에 기술에 익숙하지 않은 사용자에게는 어려울 수 있습니다. 또한 기술적인 문제가 발생할 경우 해결하기 어려울 수 있습니다.

    5. 일회성 솔루션: 일부 기존 자동화 시스템은 특정 종류의 식물이나 환경에만 적합하며, 다양한 식물과 환경에 대응하기 어려울 수 있습니다.

## System Design

-   ### Server

    <img src="https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white"> <img src="https://img.shields.io/badge/MariaDB-1F305F?style=for-the-badge&logo=mariadbfoundation&logoColor=white"> <br>
    <img src="https://img.shields.io/badge/Amazon_EC2-FF9900?style=for-the-badge&logo=amazonec2&logoColor=white"> <img src="https://img.shields.io/badge/Amazon_RDS-527FFF?style=for-the-badge&logo=amazonrds&logoColor=white">

-   ### Client

    <img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white">

-   ### Application

    <img src="https://img.shields.io/badge/Swift-F05138?style=for-the-badge&logo=Swift&logoColor=white">

- ### System Architecture
    - 흐름도는 다음과 같습니다.
![흐름도](https://github.com/HBNU-SWUNIV/come-capstone23-debro/assets/101079472/1c1a2b6a-4efa-4d4a-bf04-32463f23fa71)

    - 
## Case Study

-   ### Description
    -   LG 틔운
        -   자동 온도 조절 시스템
        -   환기 시스템
        -   자동 급수 시스템

## Conclusion

## Project Outcome

-   Client
![client_raspberry](https://github.com/HBNU-SWUNIV/come-capstone23-debro/assets/101079472/f519f12a-bb19-4760-9967-deb7cb4bf78a)
![client_yolo](https://github.com/HBNU-SWUNIV/come-capstone23-debro/assets/101079472/01b98296-948e-41eb-94f3-a99eff6b0e89)

-   Application
    - ### 구현된 기능
        1. **현재 날씨 조회:** 기상청 API를 이용하여 현재 날씨 정보를 조회합니다.
        2. **플랜터의 현재 데이터 조회:** HTTP 통신으로 플랜터의 센서 값과 생장 추이를 실시간으로 조회하는 기능을 개발했습니다.
        3. **이미지 저장 및 조회:** AWS S3를 통해 플랜터의 과거 사진을 저장하고 조회하는 기능을 구현했습니다.
        4. **플랜터 제어:** MQTT 통신을 통해 플랜터의 카메라와 워터펌프 제어 기능을 구현했습니다.
        5. **플랜터 관리:** 애플리케이션 내에서 플랜터를 추가하고 삭제하는 기능을 구현했습니다.

    - ### 애플리케이션 작동 스크린샷
        - **날씨 조회, 플랜터 화면**
            ![launchScreen](https://github.com/HBNU-SWUNIV/come-capstone23-debro/assets/42128057/c4118471-4f47-4a19-8713-578f25c23629)
            ![Main](https://github.com/HBNU-SWUNIV/come-capstone23-debro/assets/42128057/a635dfca-b5c1-4ea3-b836-b99bd8f1468c)
            ![Info1](https://github.com/HBNU-SWUNIV/come-capstone23-debro/assets/42128057/47444607-68fb-48f3-b655-f279ad008b6a)
            ![Info2](https://github.com/HBNU-SWUNIV/come-capstone23-debro/assets/42128057/1b84d961-a7b4-4476-8f04-b1af54a3b50b)
            ![Info3](https://github.com/HBNU-SWUNIV/come-capstone23-debro/assets/42128057/6042c422-cd4a-498c-bd73-c256459c9580)
            ![Info4](https://github.com/HBNU-SWUNIV/come-capstone23-debro/assets/42128057/545f4fd0-51d6-4df6-a72e-45aeb3fce237)
        - **이미지 저장 및 조회 화면**
            ![Pic2](https://github.com/HBNU-SWUNIV/come-capstone23-debro/assets/42128057/64c1bd5b-9b1d-4eea-9494-e1b26dada200)
            ![Pic3](https://github.com/HBNU-SWUNIV/come-capstone23-debro/assets/42128057/e68d0eee-19d7-4da5-94d7-456f24edc889)
            ![Pic4](https://github.com/HBNU-SWUNIV/come-capstone23-debro/assets/42128057/316c246b-3145-45c4-be03-43e5510e8e60)
            ![Pic5](https://github.com/HBNU-SWUNIV/come-capstone23-debro/assets/42128057/ec0ad84f-5ad1-4ff0-9783-f30571e9e1d5)
        - **플랜터 제어 화면**
            ![camera](https://github.com/HBNU-SWUNIV/come-capstone23-debro/assets/42128057/5292c227-3b7a-4d18-acbb-433ad7365925)
            ![water](https://github.com/HBNU-SWUNIV/come-capstone23-debro/assets/42128057/efcdc30d-a2ac-429d-b5a1-49c144ad19ba)
        - **플랜터 등록, 제거 화면**
            ![Reg3](https://github.com/HBNU-SWUNIV/come-capstone23-debro/assets/42128057/cbce397d-bb89-4484-b1ff-efc514420b08)
            ![Reg4](https://github.com/HBNU-SWUNIV/come-capstone23-debro/assets/42128057/ebb38375-5306-4a13-9d03-bd1a21f018cc)
            ![Reg5](https://github.com/HBNU-SWUNIV/come-capstone23-debro/assets/42128057/31d2a999-5776-408d-85ec-97958080355f)
            ![Reg6](https://github.com/HBNU-SWUNIV/come-capstone23-debro/assets/42128057/ef92a88c-ef0c-4785-9810-b89d1620bd4f)
            ![Reg7](https://github.com/HBNU-SWUNIV/come-capstone23-debro/assets/42128057/5f687dbf-11d9-4234-afe6-e73b85e1d1e6)
            ![Reg8](https://github.com/HBNU-SWUNIV/come-capstone23-debro/assets/42128057/7efeb0e1-f725-4136-a1e3-f431388cfdb3)
            ![Del1](https://github.com/HBNU-SWUNIV/come-capstone23-debro/assets/42128057/6153dc3b-ebf8-4d43-932c-ecdcef3ceab0)
            ![Del2](https://github.com/HBNU-SWUNIV/come-capstone23-debro/assets/42128057/8013f03f-afba-4c8e-9d05-3036a67ce121)
            ![Del3_Reg1](https://github.com/HBNU-SWUNIV/come-capstone23-debro/assets/42128057/efcab537-8bdf-459b-9922-b6d722ae92dc)
