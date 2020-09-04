% Make a mat file of CYGNSS UCAR SM data for 36km spatial resolution
clear all; clc
ifp_CYGNSS_UCAR='/project/hydrosense/RS_RAW_Data/CYGNSS/UCAR/';
ofp_CYGNSS_UCAR='/project/hydrosense/matlab/mat/CYGNSS/UCAR/daily/';

load('/sfs/qumulo/qproject/hydrosense/matlab/mat/ease_grid_files/ease_lat_lon_36km.mat')
addpath('/sfs/qumulo/qproject/hydrosense/matlab/libs/SAT_data_related_CODE')
disp('path added')
%%
for year_=2017:2019    
    
    %matlab -nodisplay -nosplash -nodesktop -r "run('/sfs/qumulo/qproject/hydrosense/matlab/libs/SMAP/SMAP_SPL3SMP.m');exit;"
    % make and arrange the list of CYGNSS UCAR data
    [~, cmdout]=system(['find ',ifp_CYGNSS_UCAR,' -iname "*_',num2str(year_),'*" -type f']);
    t=strfind(cmdout, [ifp_CYGNSS_UCAR,num2str(year_),'/']);
    list_CYGNSS_w=[];list_CYGNSS_or=[];
    name_length=t(2)-t(1)+1;
    for i=1:numel(t)
        list_CYGNSS_w{i,1}=cmdout(t(i):t(i)+name_length-3);
        list_CYGNSS_or{i,1}=list_CYGNSS_w{i}(strlength(ifp_CYGNSS_UCAR)+1:end);
    end
    nof_CYGNSS=numel(list_CYGNSS_or); %number of file per year/ can be less than 365/366
    data_doy_CYGNSS=[];
    for i=1:nof_CYGNSS
        temp=list_CYGNSS_or{i};
        data_doy_CYGNSS(i,1)=str2double(temp(end-5:end-3));
    end
    nod=date2doy(datenum((year_),12,31)); %number of day in certain year
    list_CYGNSS=cell(nod,1);
    for i=1:numel(t)
        list_CYGNSS{data_doy_CYGNSS(i),1}=list_CYGNSS_or{i};
    end
    
    nan_frame=single(nan(size(ease_lat_36km)));
    nan_frame_3d=single(nan([size(ease_lat_36km),nod]));
    
    CYGNSS_SM=nan_frame_3d;
    t_file_CYGNSS=[];
    for doy=1:nod
        disp([num2str(year_), '.',num2str(doy)])
        if ~isempty(list_CYGNSS{doy})
           % read CYGNSS and make same size of the data frame
            t_file_CYGNSS=[ifp_CYGNSS_UCAR, list_CYGNSS{doy}];
            temp_or_CYGNSS_SM=single(ncread(t_file_CYGNSS, 'SM_daily'));
            temp_or_CYGNSS_SM(isnan(temp_or_CYGNSS_SM))=-9999;
            lat_CYGNSS=ncread(t_file_CYGNSS, 'latitude');
            lon_CYGNSS=ncread(t_file_CYGNSS, 'longitude');
            r1=find(single(ease_lat_36km(:,1))==(max(lat_CYGNSS(:))));
            r2=find(single(ease_lat_36km(:,1))==(min(lat_CYGNSS(:))));
            c1=find(single(ease_lon_36km(1,:))==(min(lon_CYGNSS(:))));
            c2=find(single(ease_lon_36km(1,:))==(max(lon_CYGNSS(:))));
            temp_large_CYGNSS_SM=nan_frame;
            temp_large_CYGNSS_SM(r1:r2, c1:c2)=temp_or_CYGNSS_SM;
            
            CYGNSS_SM(:,:,doy)=temp_large_CYGNSS_SM;
            
        else
            disp([num2str(year_), '.',num2str(doy),'>>no data'])
            CYGNSS_SM(:,:,doy)=nan_frame;
            
        end
    end
    
    disp('saving SM data...')
    save([ofp_CYGNSS_UCAR,num2str(year_),'_CYGNSS_SM.mat'],'CYGNSS_SM', 'ease_lat_36km','ease_lon_36km','-v7.3')
    clearvars CYGNSS_SM    
    disp('fisnihed')    
   
end
%%
t=CYGNSS_SM(:,:,50);
t(t<0)=nan;
imagesc(t)