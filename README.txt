yolov5-master.zip �D�{��
Labelimg �Ϥ��аO(�䴩yolo�榡)
Dataset_Separate.py ��Ƥ��� train valid test �d��:[5:1:0]

Labelimg�@���ҡA��PascalVOC�אּYolo��Y�i�s��txt�Φ���label

Dataset_Separate.py �i��w�аO�n��image�Plabel�������ۭq��Ҫ���Ƨ��H�ŦXyolov5�Φ�

���O:

Training
python train.py --img 640 --batch 32 --epochs 1000 --data ./Dataset�ܽd/data.yaml --cfg ./models/yolov5s.yaml --weight '' --device 0,1
--img:yolov5�ĥΦ۾A���Ϥ��ؤo�վ�(�ëD����Y��)�A��ĳ�]�w��Q32�㰣���ƭ�
--data:�O�o�ק�data.yaml���]�w�Cnc:���O�� names:���O
--cfg:�H�ƻ�����h�V�m�A�x�责�� s m l x �A���O�t��:��-�C�B��T:����-�ܷ�
--device:�V�m�˸m�A��:--device 0�B--device cpu�B--device 0,1(�i����d�B��)

Detect
python detect.py --source ./sample.jpg --weight ./runs/train/exp/weights/best.pt --device 0,1
--source:��Ƹ��|�A�䴩webcam�Bimage�Bvideo�Bfolder���Ahttps://github.com/ultralytics/yolov5
--weights:�V�m������weight�ɡAbest.pt���Pvalid��Ƨ�����ĪG�̦n���Alast.pt���̫�@���V�m��weight

Train Custom Data:
label�̪�txt�̭����O�Oclass x_center y_center width height
class:���O
x_center y_center:�аO��ؤ��߮y��(x,y)�Ax/��ϼe=x_center�By/��ϰ�=y_center
width height:�аO��ت��e��(w,h)�Aw/��ϼe=width�Bh/��ϰ�=height
https://github.com/ultralytics/yolov5/wiki/Train-Custom-Data

python detect_my.py --source "C:\Users\PeterChuang\Desktop\pokemon_test\test.mp4" --weights ./pokemon_yolov5_weight/best.pt --myweight "./train_run/6-18_resnet50+preteain/train/save/best.pt" --device 0 --nosave

python detect.py --source ../pokemon_pattern/image/00369.jpg --weight ../pokemon_yolov5_weight/best.pt --device 0 --nosave

python detect.py --source ../pokemon_pattern/image --weight ../pokemon_yolov5_weight/best.pt --device cpu --nosave