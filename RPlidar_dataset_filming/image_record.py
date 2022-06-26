#!/usr/bin/env python3
'''Records scans to a given file in the form of numpy array.
Usage example:

$ ./record_scans.py out.npy'''
# -*- coding: UTF-8 -*-
import sys
import numpy as np
from rplidar import RPLidar
import cv2
import time
import threading
import os
import winsound

PORT_NAME = 'COM3'
path = r'J:'
cam_path = ''
T_F = False
shutdown_cam = False


def run_lidar(path):
    '''Main function'''
    lidar = RPLidar(PORT_NAME)
    data = []
    f = open(path, 'w')
    
    angle_begin = 321
    angle_end = 28
    angle_mid = 39
    
    angle_mid_front = 354
    angle_mid_back = 174
    
    txt = ''
    times_set = 50
    
    try:
        print('Recording measurments... Press Crl+C to stop.')
        times = 0
        for scan in lidar.iter_scans():
            #print(scan)
            min_angle = 370.0
            min_dis = 9999999999999999999.9
            for angle in range(len(scan)) :   #find the shortest distance
                if ( scan[angle][2] < min_dis ) and ((scan[angle][1] > 219) or (scan[angle][1] < 129)) :
                    min_dis = scan[angle][2]
                    min_angle = scan[angle][1]
                    min_angle = min_angle + angle_mid
                    if min_angle > 174 :
                        min_angle = min_angle - 360
                    
                
            for test in range(len(scan)) :
                
                if ( scan[test][1] > angle_begin ) or ( scan[test][1] < angle_end ):
                    scan_normalization = scan[test][1] + angle_mid
                    if scan_normalization > 360 :
                        scan_normalization = scan_normalization - 360
                    
                    result = 90 - (min_angle - scan_normalization)
                    if result > 90 :
                        result = 90 - (scan_normalization - min_angle)
                        result = 180 - result
                    if (result > 180) or (result < 0):
                        print("Out of Angle!!!")
                        break
                    #txt = txt+str(scan[test][1])+' '+str(scan[test][2])+' '+str(final_angle)+'\n'
                    """
                    scan[test][1] : 原始角度
                    scan[test][2] : 原始角度測得的距離
                    scan_normalization : 正規化原始角度，使之由321~28變為0~67
                    result : 目標圖至觀測者與牆壁間的夾角
                    min_angle : 觀測者與牆壁垂直角度並經正規化後
                    min_dis : 觀測者與牆壁垂直距離
                    """
                    txt = txt + str('%f' % scan[test][1])+' '+str('%f' % scan[test][2])+' '+str('%f' % scan_normalization)+' '+str('%f' % result)+' '+str('%f' % min_angle)+' '+str('%f' % min_dis)+'\n'
                    #print(txt)
            times = times + 1
            if times > times_set :
                f.write(txt)
                f.close()
                break
            #print(len(scan))
            #data.append(np.array(scan))
        
    except KeyboardInterrupt:
        print('Stoping.')
    lidar.stop()
    lidar.disconnect()
    #np.save(path, np.array(data))
def run_cam():
	WIDTH = 1280
	HEIGHT = 720
	cap = cv2.VideoCapture(2,cv2.CAP_DSHOW)
	cap.set(cv2.CAP_PROP_FRAME_WIDTH, WIDTH)
	cap.set(cv2.CAP_PROP_FRAME_HEIGHT, HEIGHT)
	fourcc = cv2.VideoWriter_fourcc(*'XVID')
    #out = cv2.VideoWriter(FILENAME, fourcc, FPS, (WIDTH, HEIGHT))
    
	global T_F
	global shutdown_cam
	global cam_path
	
	while True:
		ret, img = cap.read()
		if ret:
			#out.write(img)
			cv2.namedWindow('Camera', cv2.WINDOW_NORMAL)
			cv2.resizeWindow('Camera',640,360)
			cv2.imshow('Camera', img)
            
			if T_F == True :
				cv2.imwrite(cam_path, img)
				T_F = False
            
			if (cv2.waitKey(5) & 0xFF == ord('q')) or shutdown_cam:
				cap.release()
				break
		else:
			print('Cant`t grab the camera!')
			break
    #out.release()
	cv2.destroyAllWindows()

if __name__ == '__main__':
	t = threading.Thread(target=run_cam)  #建立執行緒
	t.start()  #執行
	i = 1201 #image and label name.
	try:
		while True:
			p = '第'+str(i)+'次，繼續請按ENTER。'
			input(p)
			cam_path = os.path.join(path,'image',str(i).zfill(5)+'.jpg')
			T_F = True

			RP_path = os.path.join(path,'label',str(i).zfill(5)+'.txt')
			run_lidar(RP_path)
		
			i = i + 1
			winsound.PlaySound('alert', winsound.SND_ASYNC)
			time.sleep(3)
	except KeyboardInterrupt:	
		shutdown_cam = True
		t.join() 

	
    
