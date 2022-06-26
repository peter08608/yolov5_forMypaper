unit ComMainForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, CPort, CPortCtl,Math, ComCtrls;

type
  Byte1D = array[0..99999] of byte;
  TForm1 = class(TForm)
    ComPort: TComPort;
    Memo: TMemo;
    Panel1: TPanel;
    ComLed1: TComLed;
    ComLed2: TComLed;
    ComLed3: TComLed;
    ComLed4: TComLed;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    ComLed5: TComLed;
    ComLed6: TComLed;
    Label1: TLabel;
    Label6: TLabel;
    SD: TSaveDialog;
    ListBox1: TListBox;
    ComPort1: TComPort;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Timer1: TTimer;
    Image1: TImage;
    Button1: TButton;
    ScrollBox1: TScrollBox;
    XYTR: TTrackBar;
    Panel2: TPanel;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button15: TButton;
    shutDown: TButton;
    autorun: TButton;
    Timer2: TTimer;
    procedure ComPortOpen1(Sender: TObject);
    procedure ComPortClose1(Sender: TObject);
    procedure ComPortOpen(Sender: TObject);
    procedure ComPortClose(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure ComPort1RxChar(Sender: TObject; Count: Integer);
    procedure Button14Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure XYTRChange(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure shutDownClick(Sender: TObject);
    procedure autorunClick(Sender: TObject);
//    procedure auto(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Delay(Msecs:   Integer);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1; ms: TMemorySTream; TCnt: integer; switch:boolean; dagg:integer;   old,newRay:array of array of Integer;  circleNum:Integer;
  timecnt: integer=0;

  pt: ^Byte1D; pont: integer=0;  mw, mh, imw, imh :integer; aheadSec: integer=0;turnSec:integer=0;  count,autoCount:single;   TuROrNot:boolean=false;
  TuLOrNot:boolean=false; aheadOrNot:boolean=false;  TurnAngle:single=0; myTime: single; automSec1: single;
implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
var i:integer; rc: Trect;
begin
    imw:=image1.Width; imh:=image1.Height;
    image1.Picture.Bitmap.Width:=imw;
    image1.Picture.Bitmap.Height:=imh;
    image1.Picture.Bitmap.Canvas.Brush.Color := clBlack;
    rc.Top:=0; rc.Left:=0; rc.Right:=imw; rc.Bottom:=imh;
    image1.Picture.Bitmap.Canvas.FillRect(rc);

    mw:=imw div 2;
    mh:=imh div 2;

    ms:=TMemorySTream.Create;
    TCnt:=0;
    switch:=false;
    setlength(old,image1.Width);
    //for i:=0 to image1.Width-1 do setlength(old[i],image1.Height);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
    ms.Free;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
   if ComPort1.Connected then
   begin
    ComPort1.Close;
    end
  else
  begin
    ms.Clear; ms.Position:=0;
    ComPort1.Open;
    Listbox1.Clear;
  end;
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  ComPort1.ShowSetupDialog;
end;

procedure TForm1.ComPortOpen1(Sender: TObject);
begin
  Button6.Caption := 'Close';
end;


procedure TForm1.ComPortClose1(Sender: TObject);
begin
  if Button6 <> nil then
    Button6.Caption := 'Open';
end;

procedure TForm1.ComPortOpen(Sender: TObject);
begin
  Button4.Caption := 'Close';
end;

procedure TForm1.ComPortClose(Sender: TObject);
begin
  if Button4 <> nil then
    Button4.Caption := 'Open';
end;

procedure TForm1.Button8Click(Sender: TObject);
var
  Str: String;  buf: array[0..100] of byte;   i:integer;
begin
  Listbox1.Items.Clear;

  //**** straight parameter correct ****
  aheadSec:=trunc((aheadSec*0.05694)/XYTR.Position);     //0.05694
  if(aheadOrNot=true) then
  begin
  mw:= mw+round(cos(TurnAngle*pi/180)*aheadSec);
  mh:= mh+round(sin(TurnAngle*pi/180)*aheadSec);
  end;
  
  Memo.Lines.Add('-->'+intTostr(mw));


  ms.Clear; ms.Position:=0;
  comport1.Tag:=0;
  //**** Send Stop ****
  buf[0]:=$a5;
  buf[1]:=$25;
  ComPort1.Write(buf,2);

  sleep(300);
  Comport1.ClearBuffer(true,true);


  //**** Send Start ****
  buf[0]:=$a5;
  buf[1]:=$20;
  ComPort1.Write(buf,2);

  pont:=0;
end;



procedure TForm1.ComPort1RxChar(Sender: TObject; Count: Integer);
var buf: array of byte;   k: integer;
begin
  setlength( buf, count );
  k:=ComPort1.Read(buf[0],count);
  ms.Write( buf[0],k );
  if comport1.tag=0 then
  begin
    timer1.Tag:=0;
    timer1.Enabled:=true;
    comport1.Tag:=1;
  end;

  //Listbox1.Items.add(inttostr(ms.Size));
end;

procedure TForm1.Button14Click(Sender: TObject);
var
  Str: String;  buf: array[0..100] of byte;
begin
  buf[0]:=$a5;
  buf[1]:=$25;
  ComPort1.Write(buf,2);

  timer1.Enabled:=false;
  timer1.Tag:=0;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var sz, k, a, b, c, d, x, y,edgeX,edgeY,x1,y1: integer; buf:array[0..4] of byte;  rc,rcr: TRect;
    angle,angle1, dis , a1 , b1: single;
begin
    if timer1.tag=0 then
    begin
        timer1.tag:=1;
        pt:=ms.Memory;
        if pt[0]=$a5 then
        begin
          if pt[1]=$5a then
          begin
            if pt[2]=$05 then
            begin
              if pt[3]=$40 then
              begin
                if pt[4]=$81 then
                begin
                    pont:=5;
                    //button1.Caption:='Head OK';
                    exit;
                end;
              end;
            end;
          end;
        end;
        exit;
    end
    else
    begin
      k:=ms.Size;
      repeat
        if (k-pont)>=5 then
        begin
         repeat
           repeat
              d:=pt[pont]; b:=d and 3;
              inc(pont);
           until (b=2)or(b=1);
           c:=pt[pont]; b:=c and 1;
         until b=1;
         inc(pont);
         a:=pt[pont]; inc(pont);
         angle:=((c shr 1)+(a shl 7))/64 ;

         //**** turn parameter correct ****
         angle:= angle+TurnAngle;
        // Listbox1.Items.add(floattostr(TurnAngle));
        // Memo.Lines.Add(floatTostr(aheadSec*0.02790698)+'*>'+floatTostr(angle)+'*>'+floatTostr(angle1));

         c:=pt[pont]; inc(pont);
         a:=pt[pont]; inc(pont);
         dis:=( c+(a shl 8) )/4;

         if ((d and $fe)>10) and (dis<3800)  then
         begin
          
           x:= round(cos(angle*pi/180)*dis);
           y:= round(sin(angle*pi/180)*dis);
           x:=trunc( (x/XYTR.Position)+mw );
           y:=trunc( (y/XYTR.Position)+mh );



           if (x>=0)and(x<imw)and(y>=0)and(y<imh) then
           begin
              image1.Canvas.Pen.Color:= $aaaaaa ;     //gray
              image1.Canvas.MoveTo(mw,mh);
              image1.Canvas.LineTo(x,y);

              //image1.Canvas.Pixels[x ,y ]:=$ff;    //red
              image1.Canvas.Brush.Color := $ff;   //red
              rcr.Left:=x-3; rcr.Top:=y-3; rcr.Right:=x+3; rcr.Bottom:=y+3;
              image1.Canvas.Ellipse(rcr);

              image1.Canvas.Brush.Color := $ff00;   //green
              rc.Left:=mw-5; rc.Top:=mh-5; rc.Right:=mw+5; rc.Bottom:=mh+5;
              image1.Canvas.Ellipse(rc);


          (*
           //**** clear the useless color ****
           edgeX:=0;edgeY:=0;
           if( (image1.Canvas.Pixels[x,y]<>$aaaaaa) and ( ((y-mh)<>0) and ((x-mw)<>0) ) ) and (dis>0)then
           begin
            y1:=y-mh;x1:=x-mw;a1:=(y1)/(x1);b1:=mh-(mw*a1);//solve Binary one-time equation
            angle1:=arctan(y1/x1)*360/pi;
            if( (angle1>=0) and (angle1<=90) ) then
            begin
              if(  ((a1*imw)+b1) >0 ) then  //x=imw point of intersection
              begin
               edgeX:=imw; edgeY:= round( (a1*imw)+b1 );
              end
              else                         //y=0 point of intersection
              begin
               edgeX:=round( (0-b1)/a1 ); edgeY:=0;
              end;
            end
            else if( (angle1>90) and (angle1<180) ) then
            begin
              if(  ((a1*0)+b1) >0 ) then  //x=0 point of intersection
              begin
               edgeX:=0; edgeY:= round( (a1*0)+b1 );
              end
              else                         //y=0 point of intersection
              begin
               edgeX:=round( (0-b1)/a1 );edgeY:=0;
              end;
            end
            else if( (angle1>=-180) and (angle1<=-90) ) then
            begin
              if(  ((a1*0)+b1) <mh ) then  //x=0 point of intersection
              begin
               edgeX:=0; edgeY:= round( (a1*0)+b1 );
              end
              else                         //y=imh point of intersection
              begin
               edgeX:=round( (imh-b1)/a1 );edgeY:=imh;
              end;
            end
            else if( (angle1>-90) and (angle1<0) ) then
            begin
              if(  ((a1*imw)+b1) <imh ) then  //x=imw point of intersection
              begin
               edgeX:=imw; edgeY:= round( (a1*imw)+b1 );
              end
              else                         //y=imh point of intersection
              begin
               edgeX:=round( (imh-b1)/a1 );edgeY:=imh;
              end;
            end ;
          
           end;
           image1.Canvas.Pen.Color:= $0 ;     //black
           image1.Canvas.MoveTo(round(cos(angle1*pi/180)*2)+x,round(cos(angle1*pi/180)*2)+y);
           image1.Canvas.LineTo(edgeX,edgeY);
           Listbox1.Items.add(inttostr(edgeX)+','+inttostr(edgeY));
           
           *)
            end;
           end;



        end;
      until (k-pont)<5;

      if k>30000 then  Button14Click(self);
        
    end;
end;
//**** clear the picture ****
procedure TForm1.Button1Click(Sender: TObject);
var rc: Trect;
begin
    mw:=imw div 2;
    mh:=imh div 2;
    image1.Picture.Bitmap.Canvas.Brush.Color := clBlack;
    rc.Top:=0; rc.Left:=0; rc.Right:=imw; rc.Bottom:=imh;
    image1.Picture.Bitmap.Canvas.FillRect(rc);
end;

procedure TForm1.XYTRChange(Sender: TObject);
begin
    PANEL2.Caption:='IMG SCALE: '+inttostr(XYTR.Position);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
      if(SD.Execute=true)  then
      begin
      image1.Picture.SaveToFile(SD.FileName+'.png');
      end;
end;
 //**** irobot control ****
procedure TForm1.Button3Click(Sender: TObject);
var
  Str: String;  buf: array[0..100] of byte;
begin
  count:=time;
  aheadSec:=0;
  turnSec:=0;
  aheadOrNot:=true;
  TuROrNot:=false;
  TuLOrNot:=false;
  buf[0]:= ord('F');    //straight

  ComPort.Write(buf,1);

end;

procedure TForm1.Button9Click(Sender: TObject);
var
  Str: String;  buf: array[0..100] of byte;
begin
  count:=time;
  aheadSec:=0;
  turnSec:=0;
  aheadOrNot:=false;
  TuROrNot:=false;
  TuLOrNot:=true;
  buf[0]:= ord('L');     //left

  ComPort.Write(buf,1);

end;

procedure TForm1.Button10Click(Sender: TObject);
var
  Str: String;  buf: array[0..100] of byte;
begin
  count:=time;
  aheadSec:=0;
  turnSec:=0;
  aheadOrNot:=false;
  TuLOrNot:=false;
  TuROrNot:=true;
  buf[0]:= ord('R');     //right

  ComPort.Write(buf,1);

end;

procedure TForm1.Button11Click(Sender: TObject);
var
  Str: String;  buf: array[0..100] of byte;
begin
  buf[0]:= ord('B');      //back

  ComPort.Write(buf,1);

end;

procedure TForm1.Button12Click(Sender: TObject);
var
  Str: String;  buf: array[0..100] of byte;
begin
  buf[0]:= ord('+');      //speed up

  ComPort.Write(buf,1);

end;

procedure TForm1.Button13Click(Sender: TObject);
var
  Str: String;  buf: array[0..100] of byte;
begin
  buf[0]:= ord('-');      //speed down

  ComPort.Write(buf,1);

end;

procedure TForm1.shutDownClick(Sender: TObject);
var
  Str: String;  buf: array[0..100] of byte;
begin
  buf[0]:= ord('D');     //trun off robot

  ComPort.Write(buf,1);

end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  ComPort.ShowSetupDialog;
end;
//**** connect robot ****
procedure TForm1.Button4Click(Sender: TObject);
begin
  if Sender=Button6 then
   if ComPort1.Connected then
    ComPort1.Close
  else
    ComPort1.Open;
  if Sender=Button4 then
    if ComPort.Connected then
    ComPort.Close
  else
    ComPort.Open;
  end;


procedure TForm1.Button15Click(Sender: TObject);
var
  Str: String;  buf: array[0..100] of byte;  hour,min,sec,msec:word;
begin
 //**** record the time now ****
 count:=time-count;
 decodetime(count,hour,min,sec,msec);
 sec:=sec*1000;
 aheadSec:=round(sec+msec);
 turnSec:=aheadSec;
 Memo.Lines.Add(floatTostr(aheadSec));
 count:=0;
//**** turn parameter correct ****
 if(TuLOrNot=true) then   TurnAngle:=TurnAngle-(turnSec*0.02790698)
 else if(TuROrNot=true) then   TurnAngle:=TurnAngle+(turnSec*0.02790698);

// Button8Click(self);

 buf[0]:= ord('S');

 ComPort.Write(buf,1);

end;
//**** auto scan ****
procedure TForm1.autorunClick(Sender: TObject);
begin
    Timer2.Tag:=0;automSec1:=0;myTime:=0;
   Timer2.Enabled:=Not (Timer2.Enabled);
   Listbox1.Items.add(boolTostr(Timer2.Enabled));
end;

procedure TForm1.Timer2Timer(Sender: TObject);
var
    firstTime:boolean; hour,min,sec,msec:word;  checkTime:single;  automw,automh,automSec,x,y:integer;
    autoAngle,dis:single;
begin
    decodeTime( (Time-myTime), hour, min, sec, msec );
    if Timer2.Tag=0 then
    begin
        Timer2.Tag := 1;
        Button8Click(self);
        myTime := Time;
    end
    else if Timer2.Tag=1 then
    begin
      if ((sec*1000)+msec) > 8000 then
      begin
        Timer2.Tag := 2;
        autoAngle:=TurnAngle-90;dis:=10;
        while autoAngle<(TurnAngle+90) do
        begin
          x:= round(cos(autoAngle*pi/180)*dis);
          y:= round(sin(autoAngle*pi/180)*dis);
          if(image1.Canvas.Pixels[x,y]=$0) then break;
          autoAngle:=autoAngle+0.1;
        end;
        autoAngle:=TurnAngle-autoAngle;
        automSec:=round((abs(autoAngle)+30)/0.02790698);
        automSec1:=automSec;
        if autoAngle>0 then Button10Click(self)
        else if autoAngle <0 then Button9Click(self);
        myTime := Time;
      end;
    end
    else if Timer2.Tag=2 then
    begin
      if ((sec*1000)+msec) > automSec1 then
      begin
        Timer2.Tag:=3;
        mytime:=Time;
        Button15Click(self);
        Button3Click(self);
      end;
    end
    else if Timer2.Tag=3 then
    begin
      if ((sec*1000)+msec) > 5000 then      
      begin
        Button15Click(self);
        Timer2.Tag:=0;
      end;
    end;
    
end;


//**** time count ****
Procedure   TForm1.Delay(Msecs:   Integer);
var  
      firstTickCount   :   real;
begin
      firstTickCount   :=   GetTickCount;
      Repeat
      Until   ((GetTickCount   -   firstTickCount)   >=   longInt(Msecs));
end;

(*
procedure TForm1.auto(Sender: TObject);
var
    firstTime:boolean; hour,min,sec,msec:word;  checkTime:single;  automw,automh,automSec,x,y:integer;
    autoAngle,dis:single;
begin
    Button8Click(self);
    Delay(5000);

    autoAngle:=TurnAngle-90;dis:=10;
    while autoAngle<(TurnAngle+90) do
    begin
     x:= round(cos(autoAngle*pi/180)*dis);
     y:= round(sin(autoAngle*pi/180)*dis);
     if(image1.Canvas.Pixels[x,y]=$0) then break;
     autoAngle:=autoAngle+0.1;
    end;


    autoAngle:=TurnAngle-autoAngle;
    if autoAngle>0 then
    begin
     autoAngle:=abs(autoAngle);
     automSec:=round((autoAngle+30)/0.02790698);
     Button10Click(self);
     Delay(automSec);
     Button15Click(self);
    end
    else if autoAngle <0 then
    begin
     autoAngle:=abs(autoAngle);
     automSec:=round((autoAngle+30)/0.02790698);
     Button9Click(self);
     Delay(automSec);
     Button15Click(self);
    end;


    Button3Click(self);
    Delay( 5000 );

    Timer2.Tag:=0;
end;
  *)


end.

