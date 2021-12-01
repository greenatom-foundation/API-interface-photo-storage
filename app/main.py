import imghdr
import os
import uuid
from flask import Flask, render_template, request, redirect, url_for, abort, \
    send_from_directory, jsonify, Response
from flask_sqlalchemy import SQLAlchemy
from werkzeug.utils import secure_filename


def initDB():
    db_path = os.path.join(os.path.dirname(__file__), 'app.db')
    db_uri = 'sqlite:///{}'.format(db_path)
    db = SQLAlchemy(app)
    db.create_all()
    app.config['SQLALCHEMY_DATABASE_URI'] = db_uri
    if len(list(db.engine.execute("SELECT * FROM sqlite_master where type = 'table'").fetchall())) == 0:
        db.engine.execute("CREATE TABLE T_LINK"
                          "("
                          " PK_ID           VARCHAR(36) NOT NULL,"
                          " PV_PATH         VARCHAR(255) NOT NULL,"
                          " V_NAME          VARCHAR(255) NULL,"
                          " PRIMARY KEY (PK_ID)"
                          ")")
    if not os.path.exists(os.path.join(os.path.dirname(__file__), 'uploads')):
        os.makedirs('uploads')


app = Flask(__name__)
app.config['MAX_CONTENT_LENGTH'] = 2 * 1024 * 1024
app.config['UPLOAD_EXTENSIONS'] = ['.jpg', '.png', '.gif']
app.config['UPLOAD_PATH'] = 'uploads'
db = SQLAlchemy(app)
initDB()


def validate_image(stream):
    header = stream.read(512)
    stream.seek(0)
    format = imghdr.what(None, header)
    if not format:
        return None
    return '.' + (format if format != 'jpeg' else 'jpg')


@app.errorhandler(413)
def too_large(e):
    return "File is too large", 413


@app.route('/')
def index():
    files = os.listdir(app.config['UPLOAD_PATH'])
    return render_template('upload.html', files=files)


@app.route('/', methods=['POST'])
def upload_files():
    uploaded_file = request.files['file']
    filename = secure_filename(uploaded_file.filename)
    if filename != '':
        file_ext = os.path.splitext(filename)[1]
        if file_ext not in app.config['UPLOAD_EXTENSIONS'] or \
                file_ext != validate_image(uploaded_file.stream):
            return "Invalid image", 400
        # print('filename: '+filename)
        lnk = str(uuid.uuid4())
        db.engine.execute("INSERT INTO T_LINK(PK_ID, PV_PATH, V_NAME) VALUES('{}', '{}', '{}')".format(lnk, os.path.join(app.config['UPLOAD_PATH'], lnk), filename))
        uploaded_file.save(os.path.join(app.config['UPLOAD_PATH'], lnk))
        # print('data: ' + str(db.engine.execute('SELECT * FROM T_LINK').fetchall()))
    return '', 204


@app.route('/uploads/<filename>')
def upload(filename):
    return send_from_directory(app.config['UPLOAD_PATH'], filename)


if __name__ == "__main__":
    app.run(host='127.0.0.1')