%--------------------------BEGIN NOTE------------------------------%
% University of Virginia
%--------------------------END NOTE--------------------------------%
% ARGUMENTS:
%
% INPUTS: AMSR2 nc files
%
% DESCRIPTION:
% Same code for the AMSR2 descending data
%
% REVISION HISTORY: 
% 9 Jul 2020 Hyunglok Kim; initial specification
%-----------------------------------------------------------------%

clear; clc
ifp='/project/hydrosense/RS_RAW_Data/AMSR2/LPRM_AMSR2_L3_A/';
ofp='/project/hydrosense/matlab/mat/AMSR2/LPRM_AMSR2_L3_A/';

for year_=2019:2019
    
    [~, cmdout]=system(['find ',ifp,' -iname "*_',num2str(year_),'*"']);
    t=strfind(cmdout, ifp);
    
    list_AMSR2_w=[];list_AMSR2_or=[];
    name_length=t(2)-t(1)+1;
    for i=1:numel(t)
        list_AMSR2_w{i,1}=cmdout(t(i):t(i)+name_length-3);
        list_AMSR2_or{i,1}=list_AMSR2_w{i}(strlength(ifp)+1:end);
    end
    
    nof=numel(list_AMSR2_or); %number of file per year/ can be less than 365/366
    
    data_doy=[];
    for i=1:nof
        temp=list_AMSR2_or{i};
        data_doy(i,1)=date2doy(datenum(str2double(temp(40:43)),str2double(temp(44:45)),str2double(temp(46:47))));
    end
    
     nod=date2doy(datenum((year_),12,31)); %number of day in certain year     

     
     list_AMSR2=cell(nod,1);
     for i=1:numel(t)
         list_AMSR2{data_doy(i),1}=list_AMSR2_or{i};
     end

     if numel(data_doy)>nod
         disp('more than 2 data in the same day')
         break;
     end
     
      t_lat=ncread([ifp, list_AMSR2{data_doy(1)}], 'Latitude');
      t_lon=ncread([ifp, list_AMSR2{data_doy(1)}], 'Longitude');
      [lon,lat]=meshgrid(t_lon, t_lat);
      clearvars t_lat t_lon
      nan_frame=single(nan(size(lat,1), size(lat,2)));     
      nan_frame_3d=single(nan(size(lat,1), size(lat,2), nod));
      AMSR2_SM_c1=nan_frame_3d;
      AMSR2_SM_c2=nan_frame_3d;
      AMSR2_SM_x=nan_frame_3d;
      t_file=[];
      for doy=1:nod
          disp([num2str(year_), '.',num2str(doy)])
          if ~isempty(list_AMSR2{doy})
              t_file=[ifp, list_AMSR2{doy}];
              temp_or_SM=ncread(t_file, 'soil_moisture_c1');
              AMSR2_SM_c1(:,:,doy)=single(temp_or_SM);
              temp_or_SM=ncread(t_file, 'soil_moisture_c2');
              AMSR2_SM_c2(:,:,doy)=single(temp_or_SM);
              temp_or_SM=ncread(t_file, 'soil_moisture_x');
              AMSR2_SM_x(:,:,doy)=single(temp_or_SM);
              temp_or_mask=ncread(t_file, 'mask');
              AMSR2_mask(:,:,doy)=single(temp_or_mask);
          else
              disp([num2str(year_), '.',num2str(doy),'>>no data'])
              AMSR2_SM_c1(:,:,doy)=nan_frame;
              AMSR2_SM_c2(:,:,doy)=nan_frame;
              AMSR2_SM_x(:,:,doy)=nan_frame;
              AMSR2_mask(:,:,doy)=nan_frame; 
          end
      end

      save([ofp,num2str(year_),'_AMSR2_SM_c1.mat'],'AMSR2_SM_c1', 'lat','lon', '-v7.3')
      clearvars AMSR2_SM_c1
      save([ofp,num2str(year_),'_AMSR2_SM_c2.mat'],'AMSR2_SM_c2', 'lat','lon', '-v7.3')
      clearvars AMSR2_SM_c2
      save([ofp,num2str(year_),'_AMSR2_SM_x.mat'],'AMSR2_SM_x', 'lat','lon', '-v7.3')
      clearvars AMSR2_SM_x
      
      AMSR2_mask=nan_frame_3d;
      t_file=[];
      for doy=1:nod
          disp([num2str(year_), '.',num2str(doy)])
          if ~isempty(list_AMSR2{doy})
              t_file=[ifp, list_AMSR2{doy}];              
              temp_or_mask=ncread(t_file, 'mask');
              AMSR2_mask(:,:,doy)=single(temp_or_mask);
          else
              disp([num2str(year_), '.',num2str(doy),'>>no data'])              
              AMSR2_mask(:,:,doy)=nan_frame; 
          end
      end

      save([ofp,num2str(year_),'_AMSR2_mask.mat'],'AMSR2_mask', 'lat','lon', '-v7.3')
      clearvars AMSR2_mask
end

