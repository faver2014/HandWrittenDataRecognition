function varargout = HandWrittenDataRecognition(varargin)
% HANDWRITTENDATARECOGNITION MATLAB code for HandWrittenDataRecognition.fig
%      HANDWRITTENDATARECOGNITION, by itself, creates a new HANDWRITTENDATARECOGNITION or raises the existing
%      singleton*.
%
%      H = HANDWRITTENDATARECOGNITION returns the handle to a new HANDWRITTENDATARECOGNITION or the handle to
%      the existing singleton*.
%
%      HANDWRITTENDATARECOGNITION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HANDWRITTENDATARECOGNITION.M with the given input arguments.
%
%      HANDWRITTENDATARECOGNITION('Property','Value',...) creates a new HANDWRITTENDATARECOGNITION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HandWrittenDataRecognition_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HandWrittenDataRecognition_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help HandWrittenDataRecognition

% Last Modified by GUIDE v2.5 04-May-2017 00:01:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HandWrittenDataRecognition_OpeningFcn, ...
                   'gui_OutputFcn',  @HandWrittenDataRecognition_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


%定义两个全局变量  
global ButtonDown pos1;  
global imgx imgy;  
global Xmin Xmax Ymin Ymax;

Xmin = 0;
Xmax = 2;
Ymin = 0;
Ymax = 2;

global LearnBuf;
global delta;
delta = 3;

global cntBuf;%0-9的训练集的个数，数组
% --- Executes just before HandWrittenDataRecognition is made visible.
function HandWrittenDataRecognition_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to HandWrittenDataRecognition (see VARARGIN)

% Choose default command line output for HandWrittenDataRecognition
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes HandWrittenDataRecognition wait for user response (see UIRESUME)
% uiwait(handles.figure1);
LearnBuf = cell(1,10);
% GUI左上角图标的更改，假设GUI的Tag为figure1，在其OpeningFcn里添加
h = handles.figure1; %返回其句柄
newIcon = javax.swing.ImageIcon('hehe.jpg')
figFrame = get(h,'JavaFrame'); %取得Figure的JavaFrame。
figFrame.setFigureIcon(newIcon); %修改图标
% load test.mat
% --- Outputs from this function are returned to the command line.
function varargout = HandWrittenDataRecognition_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%识别_按钮
% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% set(handles.edit2,'String','6');
global LearnBuf;
global delta;
global cntBuf;%0-9的训练集的个数，数组
% % % % % % % % %用了一种非常笨拙的方法来取出axes里的手写输入图...晕
% % % % % % % % 
% % % % % % % % h=get(handles.axes1,'children');
% % % % % % % % figure('visible','off');
% % % % % % % % axes;
% % % % % % % % 
% % % % % % % % %去掉边框和x-y轴的尺标
% % % % % % % % axis off
% % % % % % % % copyobj(h,gca);
% % % % % % % % set(gca, 'position', [0 0 1 1 ]);
% % % % % % % % saveas(gcf,'tmp/tmp.png','png');
pix=getframe(handles.axes1);
% % % % imwrite(pix.cdata,'tmp/tmp.png','png');
% % % % A = imread('tmp/tmp.png');
A = pix.cdata;
A = rgb2gray(A);%取灰度
A = im2bw(A,.8);%此处的0.8阈值靠琢磨
% figure 

%0为黑 1为白

% % % 
% % % num = CalcProb(A);
% % % B = DrawRecogLine(A);
% % % imshow (A);
% % % figure
% % % imshow(B);
thenum = CalcProb(A);
thenum = fix( thenum ./ delta) + 1;
counter = 1;
Pwitch = [];
LearnBuf
for i = 1 : 10
    counter = 1;
    num = LearnBuf{1,i};%(:,:,i);
    for j = 1 : 8
        temp = sum(num(:,j)==thenum(j));
        if temp == 0 
            counter = counter * 0.1;
        else
            counter = counter * temp;%每个独立特征的概率相乘（朴素贝叶斯算法）
        end
    end
    counter = counter * ( cntBuf( i ) / sum(cntBuf));%先验概率
    Pwitch = [ Pwitch , counter ];
end
[m,i] = max(Pwitch);

[NewLineData ,oldIndex]=sort(Pwitch);%向量升序排序

set(handles.edit2,'String',num2str(oldIndex(end     ) - 1));
set(handles.edit3,'String',num2str(oldIndex(end - 1 ) - 1));
set(handles.edit4,'String',num2str(oldIndex(end - 2 ) - 1));
set(handles.edit5,'String',num2str(oldIndex(end - 3 ) - 1));

% ////////////////////////////////////////////
% set(handles.edit2,'String',num2str(i-1));
% index_m=find(t==t(end));%找到最大值占有的位置
% firstData = index_m(1);
% target=t(index_m(1)-1)%找到第二大的值并显示
% index(t==target)%显示第二大的值在原向量的位置
% 
% 
% set(handles.edit2,'String',num2str(i-1));








function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton1.
function pushbutton1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%鼠标移动
% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%以下这三行主要是实时显示鼠标的坐标
% p=get(gca,'CurrentPoint') ;%获得句柄
% msgstr = sprintf('x = %3.3f; y = %3.3f',p(1,1),p(1,2)); %获得位置
% xianshi= uicontrol('style','text','position',[100 100 100 20],'string',msgstr);

global Xmin Xmax Ymin Ymax;
%鼠标运动事件的响应  
global ButtonDown pos1;  
if ButtonDown == 1  
%     pos = get(handles.axes1, 'CurrentPoint');%获取窗口当前位置  
    pos = get(handles.axes1, 'CurrentPoint');%获取画板当前位置 
    %pos
    %pos1
    %	([起点横坐标，终点横坐标],[起点纵坐标，终点纵坐标])
    x1 = pos1(1, 1); y1 = pos1(1,2);
    x2 = pos(1, 1); y2 = pos(1,2);
    %画板区域外，就不要绘制了
    if ( x2 < Xmin || x2 > Xmax ) || ( y2 < Ymin || y2 > Ymax ) 
        return;
    else
        line([x1 x2], [y1 y2], 'LineWidth', 2);%划线  
        pos1 = pos;%更新 
    end

end  

%鼠标按下
% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
%按下回调函数
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%鼠标按键抬起的响应事件  
global ButtonDown pos1;  
if(strcmp(get(hObject,'SelectionType'),'normal'))%判断鼠标按下的类型，mormal为左键  
    ButtonDown=1;
    pos1=get(handles.axes1,'CurrentPoint');%获取坐标轴上鼠标的位置  
else (strcmp(get(hObject,'SelectionType'),'normal'))%判断鼠标按下的类型，mormal为左键  
end  

%鼠标抬起
% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
%抬起回调函数 
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%鼠标按键抬起的响应事件  
global ButtonDown;  
ButtonDown = 0;

%清除
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%清空绘图和识别结果
set(handles.edit1,'String','');
set(handles.edit2,'String','');
set(handles.edit3,'String','');
set(handles.edit4,'String','');
set(handles.edit5,'String','');
axes(handles.axes1);
cla reset
axes1_init();





%先验存储
% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% % % % % % 
% % % % % % h=get(handles.axes1,'children');
% % % % % % figure('visible','off');
% % % % % % axes;
% % % % % % %去掉边框和x-y轴的尺标
% % % % % % %axis off
% % % % % % copyobj(h,gca);
% % % % % % %去掉边框和x-y轴的尺标
% % % % % % set(gca, 'position', [0 0 1 1 ]);
pix=getframe(handles.axes1);


inputNum = get(handles.edit1,'String');
fileType = 'png';
SameNameNum = [];
DIR = 'pre/';
i =0;
if isempty(inputNum)
    %无名字，警告
    errordlg('请输入此图片的先验数字');
else
    while 1
        name = [DIR inputNum '_pre' SameNameNum '.png'];
        tmp = exist(name,'file');  %'file'用于指定按文件搜索是否存在此文件名
        if tmp == 2  %存在此文件名
            i= i + 1;
            SameNameNum = sprintf('(%d)',i);
        else %不存在，即可使用此文件名命名并存储
% % % % %             saveas(gcf,name,fileType);
            imwrite(pix.cdata,name,'png');
            break;
        end
    end
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
inputNum = get(handles.edit2,'String');
set(handles.edit1,'String',inputNum);

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%监督学习
% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%监督从0-9学习
global delta;
global LearnBuf;
global cntBuf;
for i = 0 : 9
%     [ LearnBuf(:,:,i + 1) ,cntBuf( i + 1 ) ] = ReadAndCalcProb(i);
       [ M ,cntBuf( i + 1 ) ] = ReadAndCalcProb(i);
       M = fix( M ./ delta) + 1;
       LearnBuf{1,i + 1} = M;
end
warning('off')
save test.mat
'ok'
helpdlg('监督训练成功！','提示');  

%初始化axes对象
% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1
%axis([0 0 200 100]);
axis square %坐标轴刻度比例等

axes1_init()

%初始化画板的格式
function axes1_init()
global Xmin Xmax Ymin Ymax;
% matlab中的ylim([4 78]：y轴上下限设定范围[4,78]；
%设置画板大小
ylim([ Ymin Ymax ]);
xlim([ Xmin Xmax ]);
%清除间隔label
set(gca,'XTick',[]);
set(gca,'YTick',[]);

% 清除底边两条边线
set(gca,'XColor',[1 1 1])
set(gca,'YColor',[1 1 1])

%计算与决策线条交点的概率
function num = CalcProb( img )
theimg = img;
num = [ 0 0 0 0 0 0 0 0 ];%初始化计数器
[ imgH imgV ] = size( img );
HalfImgH = floor(imgH / 2);
HalfImgV = floor(imgV / 2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%绘制一横
for i = 1 : imgV
    %统计线条路径上的黑点
    if i < HalfImgV
       % 第6条射线上
       if theimg(HalfImgH,i) == 0
           num(6) = num(6) + 1;
       end
    else
       % 第2条射线上
       if theimg(HalfImgH,i) == 0
           num(2) = num(2) + 1;
       end
    end
    %画黑线
    %%%%%%%%%%%%%%%%%%%%%%%theimg(HalfImgH,i) = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%绘制一竖
for i = 1 : imgH
    %统计线条路径上的黑点
    if i < HalfImgH
       % 第8条射线上
       if theimg(i,HalfImgV) == 0
           num(8) = num(8) + 1;
       end
    else
       % 第4条射线上
       if theimg(i,HalfImgV) == 0
           num(4) = num(4) + 1;
       end
    end
    %画黑线
    %%%%%%%%%%%%%%%%%%%%%%%theimg(i,HalfImgV) = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%绘制一撇
if imgH > imgV
    %这是一幅高图像
    delta = imgV/imgH; %斜率为高比宽
    for i = 1 : imgH
        %寻找坐标
        temp = floor(delta * i);
        if temp < 1 
            temp = 1;
        elseif temp > imgV 
            temp = imgV;
        end
        %统计线条路径上的黑点
        if i < HalfImgH
           % 第1条射线上
           if theimg(i,imgV + 1 - temp ) == 0
               num(1) = num(1) + 1;
           end
        else
           % 第5条射线上
           if theimg(i,imgV + 1 - temp ) == 0
               num(5) = num(5) + 1;
           end
        end
        %画黑线
        %%%%%%%%%%%%%%%%%%%%%%%theimg(i,imgV + 1 - temp ) = 0;
    end
else
    %这是一幅宽图像
    delta = imgH/imgV; %斜率为高比宽
    for i = 1 : imgV
        %寻找坐标
        temp = floor(delta * i);
        if temp < 1 
            temp = 1;
        elseif temp > imgH 
            temp = imgH;
        end
        %统计线条路径上的黑点
        if i < HalfImgV
           % 第5条射线上
           if theimg(imgH + 1 - temp,i ) == 0
               num(5) = num(5) + 1;
           end
        else
           % 第1条射线上
           if theimg(imgH + 1 - temp,i ) == 0
               num(1) = num(1) + 1;
           end
        end
        %画黑线
        %%%%%%%%%%%%%%%%%%%%%%%theimg(imgH + 1 - temp,i ) = 0;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%绘制一捺
if imgH > imgV
    %这是一幅高图像
    delta = imgV/imgH; %斜率为高比宽
    for i = 1 : imgH
        %坐标计算
        temp = floor(delta * i);
        if temp < 1 
            temp = 1;
        elseif temp > imgV 
            temp = imgV;
        end
        %统计线条路径上的黑点
        if i < HalfImgH
           % 第7条射线上
           if theimg(i,temp ) == 0
               num(7) = num(7) + 1;
           end
        else
           % 第3条射线上
           if theimg(i,temp ) == 0
               num(3) = num(3) + 1;
           end
        end
        %画黑线
        %%%%%%%%%%%%%%%%%%%%%%%theimg(i,temp ) = 0;
    end
else
    %这是一幅宽图像
    delta = imgH/imgV; %斜率为高比宽
    for i = 1 : imgV
        %坐标计算
        temp = floor(delta * i);
        if temp < 1 
            temp = 1;
        elseif temp > imgH 
            temp = imgH;
        end
        %统计线条路径上的黑点
        if i < HalfImgV
           % 第7条射线上
           if theimg(temp,i ) == 0
               num(7) = num(7) + 1;
           end
        else
           % 第3条射线上
           if theimg(temp,i ) == 0
               num(3) = num(3) + 1;
           end
        end
        %画黑线
        %%%%%%%%%%%%%%%%%%%%%%%theimg(temp,i ) = 0;
    end
end
% imshow(theimg);


%给图像绘制识别辅助线条
function theimg = DrawRecogLine( img )
theimg = img;
[ imgH ,imgV ] = size( img );
HalfImgH = floor(imgH / 2);
HalfImgV = floor(imgV / 2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%绘制一横
for i = 1 : imgV
    %画黑线
    theimg(HalfImgH,i) = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%绘制一竖
for i = 1 : imgH
    %画黑线
    theimg(i,HalfImgV) = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%绘制一撇
if imgH > imgV
    %这是一幅高图像
    delta = imgV/imgH; %斜率为高比宽
    for i = 1 : imgH
        %寻找坐标
        temp = floor(delta * i);
        if temp < 1 
            temp = 1;
        elseif temp > imgV 
            temp = imgV;
        end
        %画黑线
        theimg(i,imgV + 1 - temp ) = 0;
    end
else
    %这是一幅宽图像
    delta = imgH/imgV; %斜率为高比宽
    for i = 1 : imgV
        %寻找坐标
        temp = floor(delta * i);
        if temp < 1 
            temp = 1;
        elseif temp > imgH 
            temp = imgH;
        end
        %画黑线
        theimg(imgH + 1 - temp,i ) = 0;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%绘制一捺
if imgH > imgV
    %这是一幅高图像
    delta = imgV/imgH; %斜率为高比宽
    for i = 1 : imgH
        %坐标计算
        temp = floor(delta * i);
        if temp < 1 
            temp = 1;
        elseif temp > imgV 
            temp = imgV;
        end
        %画黑线
        theimg(i,temp ) = 0;
    end
else
    %这是一幅宽图像
    delta = imgH/imgV; %斜率为高比宽
    for i = 1 : imgV
        %坐标计算
        temp = floor(delta * i);
        if temp < 1 
            temp = 1;
        elseif temp > imgH 
            temp = imgH;
        end
        %画黑线
        theimg(temp,i ) = 0;
    end
end

%读取i训练图片库并生成特征矩阵
function  [ out cnt ] = ReadAndCalcProb( num )
out = [];
cnt = 0;%训练集的个数
inputNum = num2str(num);
fileType = 'png';
SameNameNum = [];
DIR = 'pre/';
i =0;
noImgNum = 0;
while noImgNum < 5
    name = [DIR inputNum '_pre' SameNameNum '.png'];
    tmp = exist(name,'file');  %'file'用于指定按文件搜索是否存在此文件名
    if tmp == 2  %存在此文件名
        cnt = cnt + 1;
        A = imread(name);
        A = rgb2gray(A);%取灰度
        A = im2bw(A,.8);%此处的0.8阈值靠琢磨
        %imshow(A);
        %CalcProb(A)
        out = [ out ; CalcProb(A) ];
    else %不存在，即可使用此文件名命名并存储
        noImgNum = noImgNum + 1;
        %5次查找都无此文件名
    end
    i = i + 1;
    SameNameNum = sprintf('(%d)',i);
end
% save afile.txt -ascii out
% save test.mat  %把当前工作空间的所有变量保存到test.mat



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double
inputNum = get(handles.edit4,'String');
set(handles.edit1,'String',inputNum);

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double
inputNum = get(handles.edit5,'String');
set(handles.edit1,'String',inputNum);

% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
inputNum = get(handles.edit3,'String');
set(handles.edit1,'String',inputNum);
