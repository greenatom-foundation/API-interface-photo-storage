import imghdr
import os
import uuid
import base64
from flask import Flask, render_template, request, \
    jsonify, send_from_directory  # redirect, url_for, abort, send_file
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
                          " PK_ID           VARCHAR(60) NOT NULL,"
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


@app.route('/get', methods=['POST'])
def get_data():
    requestData = request.get_json()
    interestedID = requestData['id']  # TODO: логическая загвоздка - мы получаем картинку по id или по названию? Показывать id небезопасно, а значит пользователь не должен его ззнать, тем временем название изображения не гарантирует его уникальность
    query = list(db.engine.execute("SELECT PK_ID, PV_PATH, V_NAME FROM T_LINK WHERE PK_ID = '{}'".format(interestedID)).fetchall())
    # print('data: ' + str(query))
    if len(query) != 0:
        return jsonify({'id': query[0][0], 'name': query[0][2]})  # , 'file': base64.encodebytes(open(query[0][1], mode='rb').read()).decode('utf-8')
    return 'Empty query', 200


@app.route('/', methods=['POST'])
def upload_files():
    if request.method == 'POST':
        uploaded_file = request.files['file']
        filename = secure_filename(uploaded_file.filename)
        if filename != '':
            file_ext = os.path.splitext(filename)[1]
            if file_ext not in app.config['UPLOAD_EXTENSIONS'] or \
                    file_ext != validate_image(uploaded_file.stream):
                return "Invalid image", 400
            lnk = str(uuid.uuid4())
            # print(lnk)
            #region Самая "долгая" часть программы, которую имеет смысл ускорять
            db.engine.execute("INSERT INTO T_LINK(PK_ID, PV_PATH, V_NAME) VALUES('{}', '{}', '{}')".format(lnk,
                                                                                                           os.path.join(
                                                                                                               app.config[
                                                                                                                   'UPLOAD_PATH'],
                                                                                                               lnk+file_ext),
                                                                                                           filename))
            uploaded_file.save(os.path.join(app.config['UPLOAD_PATH'], lnk+file_ext))
            #endregion
        return '', 204
    return 'Bad request: Unimplemented method', 400

@app.route('/display', methods=['POST', 'GET'])
def display():
    if request.method == 'POST':
        id = request.form["id"]
        print("idp", id)
    else:
        id = request.args.get('id')
        print("idg", id)
    filename = str(id)

    query = list(db.engine.execute("SELECT PK_ID, PV_PATH, V_NAME FROM T_LINK WHERE PK_ID = '{}'".format(id)).fetchall())
    if len(query) != 0:
        filename = str(filename) + str(os.path.splitext(query[0][2])[-1])
        return render_template('upload.html', filename = filename)
    else:
        return render_template('upload.html')

@app.route('/uploads/<filename>')
def send_file(filename):
    return send_from_directory('uploads', filename)





'''
@app.route('/uploads/<filename>')
def upload(filename):
    return send_from_directory(app.config['UPLOAD_PATH'], filename)
'''


if __name__ == "__main__":
    app.run(host='0.0.0.0')
