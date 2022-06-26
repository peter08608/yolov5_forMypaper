import cv2
import threading
import time

def record() :
	cap = cv2.VideoCapture(1,cv2.CAP_DSHOW)
	# 使用 XVID 編碼
	fourcc = cv2.VideoWriter_fourcc(*'XVID')

	# 建立 VideoWriter 物件，輸出影片至 output.avi
	# FPS 值為 60.0，解析度為 640x360
	out = cv2.VideoWriter(r'D:\record\output1.avi', fourcc, 60.0, (1280, 720))
	start = time.time()
	while(cap.isOpened()):
		ret, frame = cap.read()
		if ret == True:
			# 寫入影格
			out.write(frame)
		print(time.time() - start)
		if (time.time() - start) > 30:
			out.release()
			break

def display() :
	cap = cv2.VideoCapture(1,cv2.CAP_DSHOW)
	cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
	cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 360)
	while(cap.isOpened()):
		
		ret, frame = cap.read()
		if ret == True:
			cv2.imshow('frame',frame)
		if cv2.waitKey(1) & 0xFF == ord('q'):
			break
	cap.release()
	cv2.destroyAllWindows()
		
if __name__ == '__main__':
	t = threading.Thread(target=display)  #建立執行緒
	t.start()  #執行
	
	d = threading.Thread(target=record)  #建立執行緒
	d.start()
		
