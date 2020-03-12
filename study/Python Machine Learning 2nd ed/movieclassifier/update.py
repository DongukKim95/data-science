# 영화 분류기 업데이트
# SQLite 데이터베이스에 수집된 피드백 데이터를 사용하여 예측 모델 업데이트

import pickle
import sqlite3
import numpy as np
import os

# 로컬 디렉터리에서 HashingVectorizer를 임포트합니다
from vectorizer import vect

def update_model(db_path, model, batch_size=10000):
    conn = sqlite3.connect(db_path)
    c = conn.cursor()
    c.execute('SELECT * from review_db')
    
    results = c.fetchmany(batch_size)
    while results:
        data = np.array(result)
        X = data[:, 0]
        y = data[:, 1].astype(int)
        
        classes = np.array([0, 1])
        X_train = vect.transform(X)
        model.partial_fit(X_train, y, classes=classes)
        results = c.fetchmany(batch_size)
        
    conn.close()
    return model

cur_dir = os.path.dirname(__file__)

clf = pickle.load(open(os.path.join(cur_dir, 'pkl_objects', 'classifier.pkl'), 'rb'))
db = os.path.join(cur_dir, 'reviews.sqlite')

# clf = update_model(db_path=db, model=clf, batch_size=10000)

# classifier.pkl 파일을 영구적으로 업데이트하려면
# 다음 코드의 주석을 해제하세요

# pickle.dump(clf, open(os.path.join(cur_dir, 'pkl_objects', 'classifier.pkl'),
#             'wb', protocol=4))
