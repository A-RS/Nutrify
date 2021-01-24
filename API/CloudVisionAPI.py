import io
import os
import base64
import cv2
import numpy as np

# Imports the Google Cloud client library
from google.cloud import vision

class CloudVisionAPI:
    def __init__(self):
        self.client = vision.ImageAnnotatorClient()

    def get_image_labels(self, imgStream: str):
        """
        1. decode the base64 encoded image stream first

        2. send the image to cloud vision API at Google cloud

        3. wait for the result from cloud vision API

        4. return the result to the client (cell phone)
        """
        # step 1
        nparr = np.fromstring(base64.b64decode(imgStream), np.uint8)
        frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        cv2.imwrite("request_image.jpg", frame)

        file_name = os.path.abspath('request_image.jpg')
        # Loads the image into memory
        with io.open(file_name, 'rb') as image_file:
            content = image_file.read()

        # step 2 
        image = vision.Image(content=content)
        response = self.client.label_detection(image=image)
        labels = response.label_annotations
        print('Labels:')
        label_descriptions = []
        for label in labels:
            print(label.description)
            label_descriptions.append(label.description)
        return label_descriptions


