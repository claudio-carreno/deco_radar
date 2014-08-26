clear all
clc
nombre_archivo = 'LGA80002.dt';
% nombre_archivo = 'FILE____003.DZT';  
% nombre_archivo = 'FILE____019.DZT'; 
% nombre_archivo = 'FILE____007.DZT'; 
% nombre_archivo = 'FLVOIDS.DZT';
% nombre_archivo = 'DAREA.DZT';
% nombre_archivo = 'FIVTANKS.DZT';
% nombre_archivo = 'COPIPES.DZT';
% nombre_archivo = '5LINE07.DZT';
% nombre_archivo = 'REBAR.DZT'; 
fid = fopen(nombre_archivo,'r');
if(fid > 0)
    disp ('File name: ');
    disp (nombre_archivo);
end

data=fread(fid,10);                 %la lectura se hace en decimal no hexa.
samples_x_scan = bitsll(data(6),8) + data(5);  % 512 o 1024 samples per scan.
bits_x_data = bitsll(data(8),8) + data(7);   % 8 o 16, bits per data

fclose('all');
fid = fopen(nombre_archivo,'r');

%%
if (bits_x_data == 8)
    A=fread(fid,'uint8'); % uint8 si no se especifica
    offset = 2; % 2 * samples_x_scan * (bits_x_data) -> byte = 1024
    header = 1024;
elseif (bits_x_data == 16)
    A=fread(fid,'uint16'); % uint8 si no se especifica
    offset = 1; % 1 * samples_x_scan * (bits_x_data) -> byte = 1024
    header = 512;
else
    disp ('Data error');
    break;
end
%
% Depende de como se lea, el largo del vector será el doble o no -16 bits
% Si el largo se divide en 2 al leer con 16, quiere decir que los 1024
%  de inicio debieran ser 512.
% Del mismo modo los saltos debieran ser de 1024 bytes y no de 512

disp('bits per data: ')
disp(bits_x_data);
pause

[num_filas num_col] = size(A);  %será 512 o 1023 de acuerdo a los bits de lectura
disp('Row number'); disp(num_filas); pause;
disp('Header'); disp(header); pause;
num_filas = num_filas - header; % Se restan los "header" bytes de cabecera
disp('Row number updated'); disp(num_filas); pause;

disp('Scan number:');
scan_number = num_filas / samples_x_scan;
disp(scan_number);
scan_number = (round(scan_number)); % Aproxima al más cercano. 

disp('Scan number rounded:');
disp(scan_number);

pause;
B=zeros(samples_x_scan,scan_number);
disp('Samples per scan ');
disp(samples_x_scan);
pause

for j = 1:scan_number
    
    for i = 1 : samples_x_scan
        B(i,j) = A(header + i + samples_x_scan * (j-1),1);
%         data = (1023 - 511) + 512*j + i
    end
    
end
%--
% Para 16 bits, el primer word del trazo corresponde al identificador
% numérico del trazo 0x0001, 0x0002, 0x0003 ...
%--
% Para 8 bits, el primer word del trazo corresponde a la clave 0xFFFF.

%%
column = 1;
compensated = zeros(samples_x_scan,scan_number);
media = mean(B);
% 

for j=1:scan_number
    for i=1:samples_x_scan
        compensated(i,j) = B(i,j) - media(1,j);
    end
end

plot(compensated((offset + 1):samples_x_scan,column));
% compensated = B(:,column) - media(1,column);
% plot(compensated((offset + 1):samples_x_scan,1));

%%

figure,imagesc(compensated);
colormap(gray);
colorbar;
fclose(fid);
fclose('all');
