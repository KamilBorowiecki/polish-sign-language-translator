import cv2
import base64
import io
import mediapipe as mp
from PIL import Image, ImageOps
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
    mp_holistic = mp.solutions.holistic
    mp_drawing = mp.solutions.drawing_utils
    b = io.BytesIO(base64.b64decode(data_image))
    pimg = Image.open(b)
    pimg = pimg.rotate(-90, expand=True)

    def mediapipe_detection(image, model):
        image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB) # COLOR CONVERSION (OPENCV)BGR TO (MEDIAPIPE)RGB
        image.flags.writeable = False                  # Image is no longer writeable
        results = model.process(image)                 # Make prediction
        image.flags.writeable = True                   # Image is now writeable 
        image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR) # COLOR COVERSION (MEDIAPIPE)RGB TO (OPENCV)BGR
        return image, results
    
    def draw_styled_landmarks(image, results):
        mp_drawing.draw_landmarks(image, results.face_landmarks, mp_holistic.FACEMESH_CONTOURS, 
                                mp_drawing.DrawingSpec(color=(80,110,10), thickness=1, circle_radius=1), 
                                mp_drawing.DrawingSpec(color=(80,256,121), thickness=1, circle_radius=1)
                                ) 
        # Draw pose 
        mp_drawing.draw_landmarks(image, results.pose_landmarks, mp_holistic.POSE_CONNECTIONS,
                                mp_drawing.DrawingSpec(color=(80,22,10), thickness=2, circle_radius=4), 
                                mp_drawing.DrawingSpec(color=(80,44,121), thickness=2, circle_radius=2)
                                ) 
        # Draw left hand 
        mp_drawing.draw_landmarks(image, results.left_hand_landmarks, mp_holistic.HAND_CONNECTIONS, 
                                mp_drawing.DrawingSpec(color=(121,22,76), thickness=2, circle_radius=4), 
                                mp_drawing.DrawingSpec(color=(121,44,250), thickness=2, circle_radius=2)
                                ) 
        # Draw right hand  
        mp_drawing.draw_landmarks(image, results.right_hand_landmarks, mp_holistic.HAND_CONNECTIONS, 
                                mp_drawing.DrawingSpec(color=(245,117,66), thickness=2, circle_radius=4), 
                                mp_drawing.DrawingSpec(color=(245,66,230), thickness=2, circle_radius=2)
                                ) 

    # DO WHATEVER IMAGE PROCESSING HERE{
    with mp_holistic.Holistic(min_detection_confidence=0.5, min_tracking_confidence=0.5) as holistic:
        frame = cv2.cvtColor(np.array(pimg), cv2.COLOR_RGB2BGR)
        image, results = mediapipe_detection(frame, holistic)
        draw_styled_landmarks(image, results)
        imgencode = cv2.imencode('.jpg', image)[1]
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