# 수정된 app.py 파일 생성

from flask import Flask, render_template, request
from wtforms import Form, TextAreaField, validators

app = Flask(__name__)

# 필요한 폼 필드 추가
class HelloForm(Form):  # wtforms.Form 상속
    sayhello = TextAreaField('', [validators.DataRequired()]) 
    
@app.route('/')

# 시작 웹 페이지에 텍스트 필드 추가
def index():
    form = HelloForm(request.form)  # request.form: 사용자가 폼에 입력한 데이터   
    return render_template('first_app.html', form=form)

@app.route('/hello', methods=['POST'])

# HTML 폼으로 전달된 내용 검증한 후 hello.html 페이지를 출력
def hello():
    form = HelloForm(request.form)
    if request.method == 'POST' and form.validate():  # POST 방식 사용
        name = request.form['sayhello']
        return render_template('hello.html', name=name)
    return render_template('first_app.html', form=form)

# 웹 페이지에서 서버로 데이터를 보내는 방법
# 1. GET 방식: URL 뒤에 파라미터를 붙임
# 2. POST 방식: 전송 메시지 본문에 정보를 실음

if __name__ == '__main__':
    app.run(debug=True)  # 플라스크 디버거 활성화
