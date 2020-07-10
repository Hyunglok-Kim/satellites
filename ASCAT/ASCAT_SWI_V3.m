%--------------------------BEGIN NOTE------------------------------%
% University of Virginia
%--------------------------END NOTE--------------------------------%
% ARGUMENTS:
%
% INPUTS: ASCAT nc files
%
% DESCRIPTION:
%
% REVISION HISTORY: 
% 9 Jul 2020 Hyunglok Kim; initial specification
%-----------------------------------------------------------------%
clear; clc
ifp='/project/hydrosense/RS_RAW_Data/ASCAT_SWI_V3/';
ofp='/project/hydrosense/matlab/mat/ASCAT/ASCAT_SWI_V3/';

for year_=2019:2019
    
    [~, cmdout]=system(['find ',ifp,' -iname "*_',num2str(year_),'*"']);
    t=strfind(cmdout, ifp);
    
    list_ASCAT_w=[];list_ASCAT_or=[];
    name_length=t(2)-t(1)+1;
    for i=1:numel(t)
        list_ASCAT_w{i,1}=cmdout(t(i):t(i)+name_length-3);
        list_ASCAT_or{i,1}=list_ASCAT_w{i}(strlength(ifp)+1:end);
    end
    
    nof=numel(list_ASCAT_or); %number of file per year/ can be less than 365/366
    
    data_doy=[];
    for i=1:nof
        temp=list_ASCAT_or{i};
        data_doy(i,1)=date2doy(datenum(str2double(temp(22:25)),str2double(temp(26:27)),str2double(temp(28:29))));
    end
    
    nod=date2doy(datenum((year_),12,31)); %number of day in certain year    
    list_ASCAT=cell(nod,1);
    for i=1:numel(t)
        list_ASCAT{data_doy(i),1}=list_ASCAT_or{i};
    end
    
     t_lat=ncread([ifp, list_ASCAT{data_doy(1)}], 'lat');
     t_lon=ncread([ifp, list_ASCAT{data_doy(1)}], 'lon');
     [lon,lat]=meshgrid(t_lon, t_lat);
     clearvars t_lat t_lon
     nan_frame=single(nan(size(lat,1), size(lat,2)));     
     nan_frame_3d=single(nan(size(lat,1), size(lat,2), nod));
     ASCAT_SM=nan_frame_3d;
     t_file=[];
     for doy=1:nod
         disp([num2str(year_), '.',num2str(doy)])
         if ~isempty(list_ASCAT{doy})
             t_file=[ifp, list_ASCAT{doy}];
             temp_or_SM_am=ncread(t_file, 'SWI_001')';
             ASCAT_SM(:,:,doy)=single(temp_or_SM_am);

         else
             disp([num2str(year_), '.',num2str(doy),'>>no data'])
             ASCAT_SM(:,:,doy)=nan_frame;

         end
     end

     save([ofp,num2str(year_),'_ASCAT_SM.mat'],'ASCAT_SM', 'lat','lon', '-v7.3')
     %clearvars ASCAT_SM
     
     ASCAT_QFLAG=nan_frame_3d;
     t_file=[];
     for doy=1:nod
         disp([num2str(year_), '.',num2str(doy)])
         if ~isempty(list_ASCAT{doy})
             t_file=[ifp, list_ASCAT{doy}];
             temp_or_QFLAG=ncread(t_file,'QFLAG_001')';             
             ASCAT_QFLAG(:,:,doy)=single(temp_or_QFLAG);
         else
             disp([num2str(year_), '.',num2str(doy),'>>no data'])
             ASCAT_QFLAG(:,:,doy)=nan_frame;
         end
     end
     
     save([ofp,num2str(year_),'_ASCAT_QFLAG.mat'],'ASCAT_QFLAG', 'lat','lon','-v7.3')
     
     ASCAT_SSF=nan_frame_3d;
     t_file=[];
     for doy=1:nod
         disp([num2str(year_), '.',num2str(doy)])
         if ~isempty(list_ASCAT{doy})
             t_file=[ifp, list_ASCAT{doy}];
             temp_or_SSF=ncread(t_file, 'SSF')';             
             ASCAT_SSF(:,:,doy)=single(temp_or_SSF);
         else
             disp([num2str(year_), '.',num2str(doy),'>>no data'])
             ASCAT_SSF(:,:,doy)=nan_frame;
         end
     end
     
     save([ofp,num2str(year_),'_ASCAT_SSF.mat'],'ASCAT_SSF', 'lat','lon','-v7.3')
     clearvars ASCAT_SSF

end
