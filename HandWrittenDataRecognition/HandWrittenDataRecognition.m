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


%��������ȫ�ֱ���  
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

global cntBuf;%0-9��ѵ�����ĸ���������
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
% GUI���Ͻ�ͼ��ĸ��ģ�����GUI��TagΪfigure1������OpeningFcn�����
h = handles.figure1; %��������
newIcon = javax.swing.ImageIcon('hehe.jpg')
figFrame = get(h,'JavaFrame'); %ȡ��Figure��JavaFrame��
figFrame.setFigureIcon(newIcon); %�޸�ͼ��
% load test.mat
% --- Outputs from this function are returned to the command line.
function varargout = HandWrittenDataRecognition_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%ʶ��_��ť
% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% set(handles.edit2,'String','6');
global LearnBuf;
global delta;
global cntBuf;%0-9��ѵ�����ĸ���������
% % % % % % % % %����һ�ַǳ���׾�ķ�����ȡ��axes�����д����ͼ...��
% % % % % % % % 
% % % % % % % % h=get(handles.axes1,'children');
% % % % % % % % figure('visible','off');
% % % % % % % % axes;
% % % % % % % % 
% % % % % % % % %ȥ���߿��x-y��ĳ߱�
% % % % % % % % axis off
% % % % % % % % copyobj(h,gca);
% % % % % % % % set(gca, 'position', [0 0 1 1 ]);
% % % % % % % % saveas(gcf,'tmp/tmp.png','png');
pix=getframe(handles.axes1);
% % % % imwrite(pix.cdata,'tmp/tmp.png','png');
% % % % A = imread('tmp/tmp.png');
A = pix.cdata;
A = rgb2gray(A);%ȡ�Ҷ�
A = im2bw(A,.8);%�˴���0.8��ֵ����ĥ
% figure 

%0Ϊ�� 1Ϊ��

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
            counter = counter * temp;%ÿ�����������ĸ�����ˣ����ر�Ҷ˹�㷨��
        end
    end
    counter = counter * ( cntBuf( i ) / sum(cntBuf));%�������
    Pwitch = [ Pwitch , counter ];
end
[m,i] = max(Pwitch);

[NewLineData ,oldIndex]=sort(Pwitch);%������������

set(handles.edit2,'String',num2str(oldIndex(end     ) - 1));
set(handles.edit3,'String',num2str(oldIndex(end - 1 ) - 1));
set(handles.edit4,'String',num2str(oldIndex(end - 2 ) - 1));
set(handles.edit5,'String',num2str(oldIndex(end - 3 ) - 1));

% ////////////////////////////////////////////
% set(handles.edit2,'String',num2str(i-1));
% index_m=find(t==t(end));%�ҵ����ֵռ�е�λ��
% firstData = index_m(1);
% target=t(index_m(1)-1)%�ҵ��ڶ����ֵ����ʾ
% index(t==target)%��ʾ�ڶ����ֵ��ԭ������λ��
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

%����ƶ�
% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%������������Ҫ��ʵʱ��ʾ��������
% p=get(gca,'CurrentPoint') ;%��þ��
% msgstr = sprintf('x = %3.3f; y = %3.3f',p(1,1),p(1,2)); %���λ��
% xianshi= uicontrol('style','text','position',[100 100 100 20],'string',msgstr);

global Xmin Xmax Ymin Ymax;
%����˶��¼�����Ӧ  
global ButtonDown pos1;  
if ButtonDown == 1  
%     pos = get(handles.axes1, 'CurrentPoint');%��ȡ���ڵ�ǰλ��  
    pos = get(handles.axes1, 'CurrentPoint');%��ȡ���嵱ǰλ�� 
    %pos
    %pos1
    %	([�������꣬�յ������],[��������꣬�յ�������])
    x1 = pos1(1, 1); y1 = pos1(1,2);
    x2 = pos(1, 1); y2 = pos(1,2);
    %���������⣬�Ͳ�Ҫ������
    if ( x2 < Xmin || x2 > Xmax ) || ( y2 < Ymin || y2 > Ymax ) 
        return;
    else
        line([x1 x2], [y1 y2], 'LineWidth', 2);%����  
        pos1 = pos;%���� 
    end

end  

%��갴��
% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
%���»ص�����
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%��갴��̧�����Ӧ�¼�  
global ButtonDown pos1;  
if(strcmp(get(hObject,'SelectionType'),'normal'))%�ж���갴�µ����ͣ�mormalΪ���  
    ButtonDown=1;
    pos1=get(handles.axes1,'CurrentPoint');%��ȡ������������λ��  
else (strcmp(get(hObject,'SelectionType'),'normal'))%�ж���갴�µ����ͣ�mormalΪ���  
end  

%���̧��
% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
%̧��ص����� 
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%��갴��̧�����Ӧ�¼�  
global ButtonDown;  
ButtonDown = 0;

%���
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%��ջ�ͼ��ʶ����
set(handles.edit1,'String','');
set(handles.edit2,'String','');
set(handles.edit3,'String','');
set(handles.edit4,'String','');
set(handles.edit5,'String','');
axes(handles.axes1);
cla reset
axes1_init();





%����洢
% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% % % % % % 
% % % % % % h=get(handles.axes1,'children');
% % % % % % figure('visible','off');
% % % % % % axes;
% % % % % % %ȥ���߿��x-y��ĳ߱�
% % % % % % %axis off
% % % % % % copyobj(h,gca);
% % % % % % %ȥ���߿��x-y��ĳ߱�
% % % % % % set(gca, 'position', [0 0 1 1 ]);
pix=getframe(handles.axes1);


inputNum = get(handles.edit1,'String');
fileType = 'png';
SameNameNum = [];
DIR = 'pre/';
i =0;
if isempty(inputNum)
    %�����֣�����
    errordlg('�������ͼƬ����������');
else
    while 1
        name = [DIR inputNum '_pre' SameNameNum '.png'];
        tmp = exist(name,'file');  %'file'����ָ�����ļ������Ƿ���ڴ��ļ���
        if tmp == 2  %���ڴ��ļ���
            i= i + 1;
            SameNameNum = sprintf('(%d)',i);
        else %�����ڣ�����ʹ�ô��ļ����������洢
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



%�ලѧϰ
% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%�ල��0-9ѧϰ
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
helpdlg('�ලѵ���ɹ���','��ʾ');  

%��ʼ��axes����
% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1
%axis([0 0 200 100]);
axis square %������̶ȱ�����

axes1_init()

%��ʼ������ĸ�ʽ
function axes1_init()
global Xmin Xmax Ymin Ymax;
% matlab�е�ylim([4 78]��y���������趨��Χ[4,78]��
%���û����С
ylim([ Ymin Ymax ]);
xlim([ Xmin Xmax ]);
%������label
set(gca,'XTick',[]);
set(gca,'YTick',[]);

% ����ױ���������
set(gca,'XColor',[1 1 1])
set(gca,'YColor',[1 1 1])

%�����������������ĸ���
function num = CalcProb( img )
theimg = img;
num = [ 0 0 0 0 0 0 0 0 ];%��ʼ��������
[ imgH imgV ] = size( img );
HalfImgH = floor(imgH / 2);
HalfImgV = floor(imgV / 2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%����һ��
for i = 1 : imgV
    %ͳ������·���ϵĺڵ�
    if i < HalfImgV
       % ��6��������
       if theimg(HalfImgH,i) == 0
           num(6) = num(6) + 1;
       end
    else
       % ��2��������
       if theimg(HalfImgH,i) == 0
           num(2) = num(2) + 1;
       end
    end
    %������
    %%%%%%%%%%%%%%%%%%%%%%%theimg(HalfImgH,i) = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%����һ��
for i = 1 : imgH
    %ͳ������·���ϵĺڵ�
    if i < HalfImgH
       % ��8��������
       if theimg(i,HalfImgV) == 0
           num(8) = num(8) + 1;
       end
    else
       % ��4��������
       if theimg(i,HalfImgV) == 0
           num(4) = num(4) + 1;
       end
    end
    %������
    %%%%%%%%%%%%%%%%%%%%%%%theimg(i,HalfImgV) = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%����һƲ
if imgH > imgV
    %����һ����ͼ��
    delta = imgV/imgH; %б��Ϊ�߱ȿ�
    for i = 1 : imgH
        %Ѱ������
        temp = floor(delta * i);
        if temp < 1 
            temp = 1;
        elseif temp > imgV 
            temp = imgV;
        end
        %ͳ������·���ϵĺڵ�
        if i < HalfImgH
           % ��1��������
           if theimg(i,imgV + 1 - temp ) == 0
               num(1) = num(1) + 1;
           end
        else
           % ��5��������
           if theimg(i,imgV + 1 - temp ) == 0
               num(5) = num(5) + 1;
           end
        end
        %������
        %%%%%%%%%%%%%%%%%%%%%%%theimg(i,imgV + 1 - temp ) = 0;
    end
else
    %����һ����ͼ��
    delta = imgH/imgV; %б��Ϊ�߱ȿ�
    for i = 1 : imgV
        %Ѱ������
        temp = floor(delta * i);
        if temp < 1 
            temp = 1;
        elseif temp > imgH 
            temp = imgH;
        end
        %ͳ������·���ϵĺڵ�
        if i < HalfImgV
           % ��5��������
           if theimg(imgH + 1 - temp,i ) == 0
               num(5) = num(5) + 1;
           end
        else
           % ��1��������
           if theimg(imgH + 1 - temp,i ) == 0
               num(1) = num(1) + 1;
           end
        end
        %������
        %%%%%%%%%%%%%%%%%%%%%%%theimg(imgH + 1 - temp,i ) = 0;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%����һ��
if imgH > imgV
    %����һ����ͼ��
    delta = imgV/imgH; %б��Ϊ�߱ȿ�
    for i = 1 : imgH
        %�������
        temp = floor(delta * i);
        if temp < 1 
            temp = 1;
        elseif temp > imgV 
            temp = imgV;
        end
        %ͳ������·���ϵĺڵ�
        if i < HalfImgH
           % ��7��������
           if theimg(i,temp ) == 0
               num(7) = num(7) + 1;
           end
        else
           % ��3��������
           if theimg(i,temp ) == 0
               num(3) = num(3) + 1;
           end
        end
        %������
        %%%%%%%%%%%%%%%%%%%%%%%theimg(i,temp ) = 0;
    end
else
    %����һ����ͼ��
    delta = imgH/imgV; %б��Ϊ�߱ȿ�
    for i = 1 : imgV
        %�������
        temp = floor(delta * i);
        if temp < 1 
            temp = 1;
        elseif temp > imgH 
            temp = imgH;
        end
        %ͳ������·���ϵĺڵ�
        if i < HalfImgV
           % ��7��������
           if theimg(temp,i ) == 0
               num(7) = num(7) + 1;
           end
        else
           % ��3��������
           if theimg(temp,i ) == 0
               num(3) = num(3) + 1;
           end
        end
        %������
        %%%%%%%%%%%%%%%%%%%%%%%theimg(temp,i ) = 0;
    end
end
% imshow(theimg);


%��ͼ�����ʶ��������
function theimg = DrawRecogLine( img )
theimg = img;
[ imgH ,imgV ] = size( img );
HalfImgH = floor(imgH / 2);
HalfImgV = floor(imgV / 2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%����һ��
for i = 1 : imgV
    %������
    theimg(HalfImgH,i) = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%����һ��
for i = 1 : imgH
    %������
    theimg(i,HalfImgV) = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%����һƲ
if imgH > imgV
    %����һ����ͼ��
    delta = imgV/imgH; %б��Ϊ�߱ȿ�
    for i = 1 : imgH
        %Ѱ������
        temp = floor(delta * i);
        if temp < 1 
            temp = 1;
        elseif temp > imgV 
            temp = imgV;
        end
        %������
        theimg(i,imgV + 1 - temp ) = 0;
    end
else
    %����һ����ͼ��
    delta = imgH/imgV; %б��Ϊ�߱ȿ�
    for i = 1 : imgV
        %Ѱ������
        temp = floor(delta * i);
        if temp < 1 
            temp = 1;
        elseif temp > imgH 
            temp = imgH;
        end
        %������
        theimg(imgH + 1 - temp,i ) = 0;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%����һ��
if imgH > imgV
    %����һ����ͼ��
    delta = imgV/imgH; %б��Ϊ�߱ȿ�
    for i = 1 : imgH
        %�������
        temp = floor(delta * i);
        if temp < 1 
            temp = 1;
        elseif temp > imgV 
            temp = imgV;
        end
        %������
        theimg(i,temp ) = 0;
    end
else
    %����һ����ͼ��
    delta = imgH/imgV; %б��Ϊ�߱ȿ�
    for i = 1 : imgV
        %�������
        temp = floor(delta * i);
        if temp < 1 
            temp = 1;
        elseif temp > imgH 
            temp = imgH;
        end
        %������
        theimg(temp,i ) = 0;
    end
end

%��ȡiѵ��ͼƬ�Ⲣ������������
function  [ out cnt ] = ReadAndCalcProb( num )
out = [];
cnt = 0;%ѵ�����ĸ���
inputNum = num2str(num);
fileType = 'png';
SameNameNum = [];
DIR = 'pre/';
i =0;
noImgNum = 0;
while noImgNum < 5
    name = [DIR inputNum '_pre' SameNameNum '.png'];
    tmp = exist(name,'file');  %'file'����ָ�����ļ������Ƿ���ڴ��ļ���
    if tmp == 2  %���ڴ��ļ���
        cnt = cnt + 1;
        A = imread(name);
        A = rgb2gray(A);%ȡ�Ҷ�
        A = im2bw(A,.8);%�˴���0.8��ֵ����ĥ
        %imshow(A);
        %CalcProb(A)
        out = [ out ; CalcProb(A) ];
    else %�����ڣ�����ʹ�ô��ļ����������洢
        noImgNum = noImgNum + 1;
        %5�β��Ҷ��޴��ļ���
    end
    i = i + 1;
    SameNameNum = sprintf('(%d)',i);
end
% save afile.txt -ascii out
% save test.mat  %�ѵ�ǰ�����ռ�����б������浽test.mat



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
