%--------------------------BEGIN NOTE------------------------------%
% University of Virginia
%--------------------------END NOTE--------------------------------%
% ARGUMENTS:
%
% INPUTS: SMOS nc files
%
% DESCRIPTION:
% Same code for the SMOS descending data
%
% REVISION HISTORY: 
% 9 Jul 2020 Hyunglok Kim; initial specification
%-----------------------------------------------------------------%

clear; clc
ifp='/project/hydrosense/RS_RAW_Data/SMOS_IC/SMOS_IC_ASC/';
ofp='/project/hydrosense/matlab/mat/SMOS/SMOS_IC/SMOS_IC_ASC/';

for year_=2019:2019
    
    [~, cmdout]=system(['find ',ifp,' -iname "*_',num2str(year_),'*"']);
    t=strfind(cmdout, ifp);
    
    list_SMOS_w=[];list_SMOS_or=[];
    name_length=t(2)-t(1)+1;
    for i=1:numel(t)
        list_SMOS_w{i,1}=cmdout(t(i):t(i)+name_length-3);
        list_SMOS_or{i,1}=list_SMOS_w{i}(strlength(ifp)+1:end);
    end
    
    nof=numel(list_SMOS_or); %number of file per year/ can be less than 365/366
    
    data_doy=[];
    for i=1:nof
        temp=list_SMOS_or{i};
        data_doy(i,1)=date2doy(datenum(str2double(temp(31:34)),str2double(temp(35:36)),str2double(temp(37:38))));
    end
    
     nod=date2doy(datenum((year_),12,31)); %number of day in certain year     

     
     list_SMOS=cell(nod,1);
     for i=1:numel(t)
         list_SMOS{data_doy(i),1}=list_SMOS_or{i};
     end

     if numel(data_doy)>nod
         disp('more than 2 data in the same day')
         break;
     end
     
       t_lat=flipud(ncread([ifp, list_SMOS{data_doy(1)}], 'lat'));
       t_lon=ncread([ifp, list_SMOS{data_doy(1)}], 'lon');
       [lon,lat]=meshgrid(t_lon, t_lat);
       clearvars t_lat t_lon
       nan_frame=single(nan(size(lat,1), size(lat,2)));     
       nan_frame_3d=single(nan(size(lat,1), size(lat,2), nod));
       SMOS_SM=nan_frame_3d;

       t_file=[];
       for doy=1:nod
           disp([num2str(year_), '.',num2str(doy)])
           if ~isempty(list_SMOS{doy})
                              t_file=[ifp, list_SMOS{doy}];
               temp_or_SM=imrotate(ncread(t_file, 'Soil_Moisture'),90);
               temp_or_RMSE=imrotate(ncread(t_file, 'RMSE'),90); %RFI
               temp_or_SM(temp_or_RMSE>8)=nan;
               
               temp_or_SF=imrotate(ncread(t_file, 'Scene_Flags'),90); %topo, water, urban, ice, temp.
               temp_or_SM(temp_or_SF>1)=nan;
               
               temp_or_SM(temp_or_SM>0.6)=nan;               
               SMOS_SM(:,:,doy)=single(temp_or_SM);
           else
               disp([num2str(year_), '.',num2str(doy),'>>no data'])
               SMOS_SM(:,:,doy)=nan_frame;
           end
       end

       save([ofp,num2str(year_),'_SMOS_SM.mat'],'SMOS_SM', 'lat','lon', '-v7.3')

end

