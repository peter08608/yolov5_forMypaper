#!/usr/bin/env python3
'''Records measurments to a given file. Usage example:

$ ./record_measurments.py out.txt'''
import sys
from rplidar import RPLidar
import time
import os
import threading
import cv2
import numpy as np


def run_lidar(name, time_set, image_path, label_path, class_set, second_per_frame):
    '''Main function'''
    global img
    global PORT_NAME
    #label set
    time_set = time_set * 60
    time_start = time.time()
    time_start_click = time.time()
    lidar = RPLidar(PORT_NAME)
    name = 1
    outfile = open(os.path.join(label_path,str(class_set)+str('%05d' % name)+'.txt'), 'w')
    cv2.imwrite(os.path.join(image_path,str(class_set)+str('%05d' % name)+'.jpg'), img)
    try:
        print('Recording measurments... Press Crl+C to stop.')
        for measurment in lidar.iter_measurments(max_buf_meas=1000):
            time_now = time.time()
            if time_now-time_start > time_set :
                break
            elif time_now-time_start_click > second_per_frame :
                time_start_click = time.time()
                name += 1
                outfile = open(os.path.join(label_path,str(class_set)+str('%05d' % name)+'.txt'), 'w')
                cv2.imwrite(os.path.join(image_path,str(class_set)+str('%05d' % name)+'.jpg'), img)
            else:
                if (measurment[1] > 13) and (measurment[3] > 100) :
                    outfile.write(str('%.4f' % measurment[2])+' '+str('%.4f' % measurment[3])+ '\n')
    except KeyboardInterrupt:
        print('Stoping.')
    lidar.stop()
    lidar.disconnect()

def run_cam(name, time_set):
    global img
    #image set
    time_set = time_set * 60
    time_start = time.time()
    WIDTH = 1280
    HEIGHT = 720
    cap = cv2.VideoCapture(1,cv2.CAP_DSHOW)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, WIDTH)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, HEIGHT)
    fourcc = cv2.VideoWriter_fourcc(*'XVID')
    cv2.namedWindow('Camera', cv2.WINDOW_NORMAL)
    cv2.resizeWindow('Camera',640,360)
    while True:
        ret, img = cap.read()
        if ret:
            cv2.imshow('Camera', img)
            cv2.waitKey(1)
            if time.time()-time_start > time_set :
                break
        else:
            print('Cant`t grab the camera!')
            break
    cap.release()
    cv2.destroyAllWindows()

def count_down(name, time_set):
    from tqdm import tqdm
    time_set = time_set * 60
    for i in tqdm(range(int(time_set))):
        time.sleep(1)
PORT_NAME = 'COM3'
img = np.zeros(shape=(720,1280))
if __name__ == '__main__':
    #########################################
    #angle range 209 142
    path = r'C:\Users\peter_ex\Documents\test'
    class_set = 1
    second_per_frame = 0.4
    #########################################
    image_path = os.path.join(path,'image')
    label_path = os.path.join(path,'label')
    if not os.path.isdir(image_path):
        os.makedirs(image_path)
    if not os.path.isdir(label_path):
        os.makedirs(label_path)
    time_set = input('要錄製幾分鐘:')
    image_th = threading.Thread(target=run_cam, args = ('camera', float(time_set)))  #建立執行緒
    image_th.start()  #執行
    label_th = threading.Thread(target=run_lidar, args = ('lidar', float(time_set), image_path, label_path, class_set, second_per_frame))  #建立執行緒
    label_th.start()  #執行
    time_th = threading.Thread(target=count_down, args = ('camera', float(time_set)))  #建立執行緒
    time_th.start()  #執行

