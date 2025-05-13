import cv2
import base64
import io
import mediapipe as mp
from PIL import Image, ImageOps
import numpy as np
from flask_socketio import emit, SocketIO
from flask import render_template
from flask import Flask
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Input


app = Flask(__name__, template_folder="templates")
sio = SocketIO(app, cors_allowed_origins="*")

framesWithoutHands = 0
lastWord = ""
sequence = []
sentence = ""
predictions = []
actions = np.array(['dzien', 'dobry', 'kocham', 'ciebie', 'do', 'widziec'])
threshold = 0.60
nowy_rozmiar = (650, 500)
model = Sequential([
    Input(shape=(10,1662)),  
    LSTM(64, return_sequences=True, activation='tanh'),
    LSTM(128, return_sequences=True, activation='tanh'),
    LSTM(64, return_sequences=False, activation='tanh'),
    Dense(64, activation='relu'),
    Dense(32, activation='relu'),
    Dense(actions.shape[0], activation='softmax')  
])
model.load_weights('action_99(10frames).keras')
mp_holistic = mp.solutions.holistic
holistic = mp_holistic.Holistic(min_detection_confidence=0.5, min_tracking_confidence=0.5)
mp_drawing = mp.solutions.drawing_utils
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
    
def extract_keypoints(results):
    pose = np.array([[res.x, res.y, res.z, res.visibility] for res in results.pose_landmarks.landmark]).flatten() if results.pose_landmarks else np.zeros(33*4)
    face = np.array([[res.x, res.y, res.z] for res in results.face_landmarks.landmark]).flatten() if results.face_landmarks else np.zeros(468*3)
    lh = np.array([[res.x, res.y, res.z] for res in results.left_hand_landmarks.landmark]).flatten() if results.left_hand_landmarks else np.zeros(21*3)
    rh = np.array([[res.x, res.y, res.z] for res in results.right_hand_landmarks.landmark]).flatten() if results.right_hand_landmarks else np.zeros(21*3)
    return np.concatenate([pose, face, lh, rh])

@sio.on('connect')
def handle_connect():
    print('Client connected')

@sio.on('image')
# trzeba to bedzie to wrzucic do jakies funkcji najpewniej, 
# gdzie bede sprawdzal czy bylo conajmniej 30 obrazow
# a potem bede detektowal tak jak wczesniej
def image(data_image):
    global sequence, sentence, predictions, framesWithoutHands, lastWord, nowy_rozmiar
    b = io.BytesIO(base64.b64decode(data_image))
    pimg = Image.open(b)
    width, height = pimg.size
    pimg = pimg.crop((0, 0, width-100, height))
    pimg = pimg.rotate(90, expand=True)
    pimg = pimg.resize(nowy_rozmiar)


    # DO WHATEVER IMAGE PROCESSING HERE{
    frame = cv2.cvtColor(np.array(pimg), cv2.COLOR_RGB2BGR)
    image, results = mediapipe_detection(frame, holistic)
    # draw_styled_landmarks(image, results)

    if (not results.left_hand_landmarks) and (not results.right_hand_landmarks):
        framesWithoutHands += 1
        if framesWithoutHands == 10:
            sequence = []
            predictions = []


    else:
        framesWithoutHands = 0
        keypoints = extract_keypoints(results)
        sequence.append(keypoints)
        sequence = sequence[-10:]

        if len(sequence) == 10:
            res = model.predict(np.expand_dims(sequence, axis=0))[0]
            predictions.append(np.argmax(res))

            if np.unique(predictions[-5:])[0]==np.argmax(res): 
                if res[np.argmax(res)] > threshold and lastWord != str(actions[np.argmax(res)]): 
                    lastWord = str(actions[np.argmax(res)])
                    sentence += str(actions[np.argmax(res)])
                    sentence += " "
                    sequence = []
                    predictions = []

    #}
    print("moja zmienna: " + str(sentence))
    _, buffer = cv2.imencode('.jpg', image)
    image_base64 = base64.b64encode(buffer).decode('utf-8')
    emit('image_back', image_base64, broadcast=True)

    if sentence and framesWithoutHands == 10:
        sentence = sentence[:-1]
        emit('response_back', sentence, broadcast=True)
        sentence = ""
        lastWord = ""
        sequence = []
        predictions = []


@app.route('/')
def home():
    print('Mam obraz')
    return render_template('index.html')

if __name__ == "__main__":
    sio.run(app, host='0.0.0.0', port=5000, debug=True)