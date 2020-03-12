# app.py 파일 생성

from flask import Flask, render_template

app = Flask(__name__)  # 새로운 플라스크 인스턴스 __name__ 으로 초기화
@app.route('/')  # 라우트 데코레이터: 특정 URL이 index함수를 실행하도록 지정

# templates 폴더 아래에 있는 HTML 파일 화면에 출력
def index():
    return render_template('first_app.html')

# 파이썬 인터프리터에 의해 직접 실행될 때만 run 메서드 사용
if __name__ == '__main__':
    app.run()  # 애플리케이션 실행
