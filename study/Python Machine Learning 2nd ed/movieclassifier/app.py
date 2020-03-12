# 메인 애플리케이션 app.py 구현
# update added version

from flask import Flask, render_template, request
from wtforms import Form, TextAreaField, validators
import pickle
import sqlite3
import os
import numpy as np

# 로컬 디렉터리에서 HashingVectorizer를 임포트합니다
from vectorizer import vect

# 로컬 디렉터리에서 업데이트 함수를 임포트합니다
from update import update_model

app = Flask(__name__)

######## 분류기 준비
cur_dir = os.path.dirname(__file__)
clf = pickle.load(open(os.path.join(cur_dir, 'pkl_objects', 'classifier.pkl'), 'rb'))
db = os.path.join(cur_dir, 'reviews.sqlite')

def classify(document):
    label = {0: 'negative', 1: 'positive'}
    X = vect.transform([document])
    y = clf.predict(X)[0]
    proba = np.max(clf.predict_proba(X))
    return label[y], proba

def train(document, y):
    X = vect.transform([document])
    clf.partial_fit(X, [y])
    
def sqlite_entry(path, document, y):
    conn = sqlite3.connect(path)
    c = conn.cursor()
    c.execute('''INSERT INTO review_db (review, sentiment, date)
               VALUES (?, ?, DATETIME('now'))''', (document, y))
    conn.commit()
    conn.close()
    
    
######## 플라스크
class ReviewForm(Form):
    moviereview = TextAreaField('', [validators.DataRequired(),
                                     validators.length(min=15)])  # 최소 15글자 이상 입력
    
@app.route('/')
def index():
    form = ReviewForm(request.form)
    return render_template('reviewform.html', form=form)  # reviewform.html 파일로 출력

@app.route('/results', methods=['POST'])
def results():
    form = ReviewForm(request.form)
    if request.method == 'POST' and form.validate():
        review = request.form['moviereview']
        y, proba = classify(review)
        return render_template('results.html',  # results.html 파일에 분류 결과 출력
                               content=review,
                               prediction=y,
                               probability=round(proba*100, 2))
    return render_template('reviewform.html', form=form)

@app.route('/thanks', methods=['POST'])
def feedback():
    feedback = request.form['feedback_button']
    review = request.form['review']
    prediction = request.form['prediction']  # results.html 템풀랏에서 전달된 예측 클래스 레이블
    inv_label = {'negative': 0, 'positive': 1}  # 정수 클래스 레이블로 변환
    y = inv_label[prediction]
    if feedback == 'Incorrect':
        y = int(not(y))
    train(review, y)  # 분류기 업데이트
    sqlite_entry(db, review, y)  # SQLite 데이터베이스에 새로운 레코드로 피드백 추가
    return render_template('thanks.html')  # thanks.html 템플릿 출력

if __name__ == '__main__':
    clf = update_model(db_path=db,
                       model=clf,
                       batch_size=10000)
    app.run()  # 테스트 후 debug=True 삭제
