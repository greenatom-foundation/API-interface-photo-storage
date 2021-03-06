import imghdr
import os
import uuid
import base64
from flask import Flask, render_template, request, \
    jsonify, send_from_directory, Response  # redirect, url_for, abort, send_file
from flask_sqlalchemy import SQLAlchemy
from werkzeug.serving import WSGIRequestHandler
from werkzeug.utils import secure_filename
import cv2


app = Flask(__name__)
app.config['MAX_CONTENT_LENGTH'] = 10 * 1024 * 1024
app.config['UPLOAD_EXTENSIONS'] = ['.jpg', '.png', '.gif']
app.config['UPLOAD_PATH'] = 'uploads'
app.config['UPLOAD_PATH_VIDEO'] = 'uploads/video'
db = SQLAlchemy(app)
face_cascade = cv2.CascadeClassifier()
# Load the pretrained model
face_cascade.load(cv2.samples.findFile("static/haarcascade_frontalface_alt.xml"))


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
        db.engine.execute("CREATE TABLE T_LINK_VIDEO"
                          "("
                          " PK_ID           VARCHAR(60) NOT NULL,"
                          " PV_PATH         VARCHAR(255) NOT NULL,"
                          " V_NAME          VARCHAR(255) NULL,"
                          " PRIMARY KEY (PK_ID)"
                          ")")
    if not os.path.exists(os.path.join(os.path.dirname(__file__), 'uploads')):
        os.makedirs('uploads')
    if not os.path.exists(os.path.join(os.path.dirname(__file__), 'uploads/video')):
        os.makedirs('uploads/video')


def getAllData():
    query = list(db.engine.execute("SELECT PK_ID, V_NAME FROM T_LINK ").fetchall())
    return query

def getAllDataVideo():
    query = list(db.engine.execute("SELECT PK_ID, V_NAME FROM T_LINK_VIDEO ").fetchall())
    return query


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


@app.route('/postall', methods=['POST', 'GET'])
def data():
    res = {}
    tmp = getAllData()
    for i in range(len(tmp)):
        res[i] = {}
        res[i]["PK_ID"] = tmp[i]["PK_ID"]
        res[i]["V_NAME"] = tmp[i]["V_NAME"]
    return jsonify(res)

@app.route('/postallvideo', methods=['POST', 'GET'])
def data_video():
    res = {}
    tmp = getAllDataVideo()
    for i in range(len(tmp)):
        res[i] = {}
        res[i]["PK_ID"] = tmp[i]["PK_ID"]
        res[i]["V_NAME"] = tmp[i]["V_NAME"]
    return jsonify(res)

@app.route('/post', methods=['POST'])
def get_data():
    requestData = request.get_json()
    interestedID = requestData['id']
    query = list(db.engine.execute("SELECT PK_ID, PV_PATH, V_NAME FROM T_LINK WHERE PK_ID = '{}'".format(interestedID)).fetchall())
    if len(query) != 0:
        return jsonify({'id': query[0][0], 'name': query[0][2], 'file': base64.b64encode(open(query[0][1], mode='rb').read()).decode('utf-8')})  #
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
            #region ?????????? "????????????" ?????????? ??????????????????, ?????????????? ?????????? ?????????? ????????????????
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


@app.route('/display', methods=['GET'])  # 'POST',
def display():
    _id = request.args.get('id')

    query = list(db.engine.execute("SELECT PK_ID, V_NAME FROM T_LINK WHERE V_NAME = '{}'".format(_id)).fetchall())
    if len(query) != 0:
        filename = str(query[0][0]) + str(os.path.splitext(query[0][1])[-1])
        return render_template('upload.html', filename=filename)
    else:
        query = list(db.engine.execute("SELECT PK_ID, V_NAME FROM T_LINK WHERE PK_ID = '{}'".format(_id)).fetchall())
        if len(query) != 0:
            filename = str(query[0][0]) + str(os.path.splitext(query[0][1])[-1])
            return render_template('upload.html', filename=filename)
        else:
            return render_template('upload.html')


@app.route('/display_video', methods=['GET'])  # 'POST',
def display_video():
    _id = request.args.get('id')

    query = list(db.engine.execute("SELECT PK_ID, V_NAME FROM T_LINK_VIDEO WHERE V_NAME = '{}'".format(_id)).fetchall())
    if len(query) != 0:
        filename = str(query[0][0]) + str(os.path.splitext(query[0][1])[-1])
        return render_template('video.html', filename=filename)
    else:
        query = list(db.engine.execute("SELECT PK_ID, V_NAME FROM T_LINK_VIDEO WHERE PK_ID = '{}'".format(_id)).fetchall())
        if len(query) != 0:
            filename = str(query[0][0]) + str(os.path.splitext(query[0][1])[-1])
            return render_template('video.html', filename=filename)
        else:
            return render_template('video.html')

@app.route('/uploads/<filename>')
def send_file(filename):
    return send_from_directory(app.config['UPLOAD_PATH'], filename)

@app.route('/uploads/video/<filename>')
def send_file_video(filename):
    return send_from_directory(app.config['UPLOAD_PATH_VIDEO'], filename)

@app.route('/get_value', methods=['GET'])  # 'POST',
def get_value():
    query = getAllData()
    if len(query) != 0:
        return render_template('upload.html', value=query, len=len(query))
    else:
        return render_template('upload.html')

@app.route('/get_value_video', methods=['GET'])  # 'POST',
def get_value_video():
    query = getAllDataVideo()
    if len(query) != 0:
        return render_template('video.html', value=query, len=len(query))
    else:
        return render_template('video.html')



@app.route('/video_feed')
def video_feed():
    return Response(gen(), mimetype='multipart/x-mixed-replace; boundary=frame')


def gen():
    i = 0
    #while True:
    #video = cv2.VideoCapture(0)
    video = cv2.VideoCapture('video_2021-12-07_20-56-24_384.mp4')
    while (video.isOpened()):
        success, image = video.read()
        frame_gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        frame_gray = cv2.equalizeHist(frame_gray)

        faces = face_cascade.detectMultiScale(frame_gray)

        for (x, y, w, h) in faces:
            center = (x + w // 2, y + h // 2)
            cv2.putText(image, "X: " + str(center[0]) + " Y: " + str(center[1]), (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 1,
                        (255, 0, 0), 3)
            image = cv2.rectangle(image, (x, y), (x + w, y + h), (0, 255, 0), 2)

            faceROI = frame_gray[y:y + h, x:x + w]
        ret, jpeg = cv2.imencode('.jpg', image)

        frame = jpeg.tobytes()

        if i % 5 == 0:
            lnk = str(uuid.uuid4())
            filename = str(lnk) + '.jpg'
            cv2.imwrite(os.path.join(app.config['UPLOAD_PATH_VIDEO'], filename), image)

            file_ext = os.path.splitext(filename)[1]
            db.engine.execute("INSERT INTO T_LINK_VIDEO(PK_ID, PV_PATH, V_NAME) VALUES('{}', '{}', '{}')".format(lnk,
                                                                                                               os.path.join(
                                                                                                                   app.config[
                                                                                                                       'UPLOAD_PATH_VIDEO'],
                                                                                                                   lnk + file_ext),
                                                                                                               filename))

        i += 1

        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n\r\n')

@app.route('/video')
def video():
    """Video streaming home page."""
    return render_template('video.html')


if __name__ == "__main__":
    WSGIRequestHandler.protocol_version = "HTTP/1.1"
    app.run(host='0.0.0.0', threaded=True)


