import cv2
import base64
import io
from PIL import Image
import numpy as np
from flask_socketio import emit, SocketIO
from flask import Flask

app = Flask(__name__, template_folder="templates")
sio = SocketIO(app)

@sio.on('connect')
def handle_connect():
    print('Client connected')

@sio.on('image')
def image(data_image):
    print(f'Otrzymano dane wideo: {data_image}')
    sbuf = io.StringIO()
    sbuf.write(data_image)
    b = io.BytesIO(base64.b64decode(data_image))
    pimg = Image.open(b)

    # DO WHATEVER IMAGE PROCESSING HERE{
    frame = cv2.cvtColor(np.array(pimg), cv2.COLOR_RGB2BGR)
    frame = cv2.flip(frame, flipCode=0)
    imgencode = cv2.imencode('.jpg', frame)[1]
    #}

    stringData = base64.b64encode(imgencode).decode('utf-8')
    b64_src = 'data:image/jpeg;base64,'
    stringData = b64_src + stringData
    emit('response_back', stringData)


@app.route('/')
def home():
    return 'Hello, world!'

if __name__ == "__main__":
    sio.run(app, host='0.0.0.0', port=5000, debug=True)