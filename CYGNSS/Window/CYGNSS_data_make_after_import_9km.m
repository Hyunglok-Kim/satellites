%% CYGNSS 3D
clear all
clc
load('F:\ease_grid_files\ease_lat_lon_9km.mat')
ease_lat_9km=ease_lat_9km(301:470,612:1125);
ease_lon_9km=ease_lon_9km(301:470,612:1125);

folder_path='H:\Datasets\CYGNSS\L1\v1.1\2017\';
t_doy=[];
doy_get=dir(folder_path);
doy_get(1:2,:)=[];
doy_get(end,:)=[];
for i=1:size(doy_get,1)
    t_doy(i,1)=str2double(doy_get(i).name);
end

%% DDM
k=0;
CYGNSS_DDM=ones(size(ease_lat_9km,1),size(ease_lat_9km,2))*-999999;
CYGNSS_DDM=int32(CYGNSS_DDM);

folder_path='H:\Datasets\CYGNSS\L1\v1.1\mat\2017\';
for doi_i=1:numel(t_doy)
    doy=t_doy(doi_i)
    input_file_path=[folder_path, '9km\USA\',num2str(doy)];
    
    load([input_file_path,'_CSNI_DDM_USA.mat'])
    %     load([input_file_path,'_CSNI_DDM_ANT_USA.mat'])
    %     load([input_file_path,'_CSNI_SP_INC_A_USA.mat'])
    %     load([input_file_path,'_CSNI_UTC_USA.mat'])
    
    % del_nan_frame
    
    dnf_list=[];
    for dnf=1:size(v_frame_3d_CSNI_ddm,3)
        aa=~isnan(v_frame_3d_CSNI_ddm(:,:,dnf));
        dnf_list(dnf)=sum(aa(:))==0;
    end
    dnf_list=find(dnf_list==1);
    
    v_frame_3d_CSNI_ddm(:,:,dnf_list)=[];
    
    kk=size(v_frame_3d_CSNI_ddm,3);
    nan_value=isnan(v_frame_3d_CSNI_ddm);
    v_frame_3d_CSNI_ddm=v_frame_3d_CSNI_ddm*10000;
    v_frame_3d_CSNI_ddm=int32(v_frame_3d_CSNI_ddm);
    v_frame_3d_CSNI_ddm(nan_value)=-999999;
    
    CYGNSS_DDM(:,:,k+1:k+kk)=(v_frame_3d_CSNI_ddm);
    
    k=size(CYGNSS_DDM,3);
    
end
%%
save('H:\Datasets\CYGNSS\L1\v1.1\mat\2017\3d\9km\hr_CYGNSS_DDM_USA.mat', 'CYGNSS_DDM','-v7.3')
% save('H:\Datasets\CYGNSS\L1\v1.1\mat\2017\3d\9km\USA\CYGNSS_INC_USA.mat', 'CYGNSS_INC','-v7.3')
%% UTC
k=0;
CYGNSS_UTC=zeros(size(ease_lat_9km,1),size(ease_lat_9km,2));
CYGNSS_UTC=uint32(CYGNSS_UTC);

for doi_i=1:numel(t_doy)
    doy=t_doy(doi_i)
    input_file_path=[folder_path, '9km\USA\',num2str(doy)];
    
    load([input_file_path,'_CSNI_UTC_USA.mat'])
    
    % del_nan_frame
    dnf_list=[];
    for dnf=1:size(v_frame_3d_CSNI_ddm_utc,3)
        aa=~isnan(v_frame_3d_CSNI_ddm_utc(:,:,dnf));
        dnf_list(dnf)=sum(aa(:))==0;
    end
    dnf_list=find(dnf_list==1);
    
    v_frame_3d_CSNI_ddm_utc(:,:,dnf_list)=[];
    
    kk=size(v_frame_3d_CSNI_ddm_utc,3);
    
    v_frame_3d_CSNI_ddm_utc(isnan(v_frame_3d_CSNI_ddm_utc))=0;
    v_frame_3d_CSNI_ddm_utc=v_frame_3d_CSNI_ddm_utc*1000;
    
    v_frame_3d_CSNI_ddm_utc=uint32(v_frame_3d_CSNI_ddm_utc);
    CYGNSS_UTC(:,:,k+1:k+kk)=(v_frame_3d_CSNI_ddm_utc);
    
    
    k=size(CYGNSS_UTC,3);
    
end
save('H:\Datasets\CYGNSS\L1\v1.1\mat\2017\3d\9km\hr_CYGNSS_UTC_USA.mat', 'CYGNSS_UTC','-v7.3')

%% ANT
k=0;
CYGNSS_ANT=ones(size(ease_lat_9km,1),size(ease_lat_9km,2))*-999999;
CYGNSS_ANT=int32(CYGNSS_ANT);

folder_path='H:\Datasets\CYGNSS\L1\v1.1\mat\2017\';
for doi_i=1:numel(t_doy)
    doy=t_doy(doi_i)
    input_file_path=[folder_path, '9km\USA\',num2str(doy)];
    
    load([input_file_path,'_CSNI_DDM_ANT_USA.mat'])
    
    % del_nan_frame
    dnf_list=[];
    for dnf=1:size(v_frame_3d_CSNI_ddm_ant,3)
        aa=~isnan(v_frame_3d_CSNI_ddm_ant(:,:,dnf));
        dnf_list(dnf)=sum(aa(:))==0;
    end
    dnf_list=find(dnf_list==1);
    
    v_frame_3d_CSNI_ddm_ant(:,:,dnf_list)=[];
    
    kk=size(v_frame_3d_CSNI_ddm_ant,3);
    
    nan_value=isnan(v_frame_3d_CSNI_ddm_ant);
    v_frame_3d_CSNI_ddm_ant=v_frame_3d_CSNI_ddm_ant*10000;
    v_frame_3d_CSNI_ddm_ant=int32(v_frame_3d_CSNI_ddm_ant);
    v_frame_3d_CSNI_ddm_ant(nan_value)=-999999;
    
    CYGNSS_ANT(:,:,k+1:k+kk)=(v_frame_3d_CSNI_ddm_ant);
    
    k=size(CYGNSS_ANT,3);
    
end

save('H:\Datasets\CYGNSS\L1\v1.1\mat\2017\3d\9km\CYGNSS_ANT_USA.mat', 'CYGNSS_ANT','-v7.3')
%% INC_A
k=0;
CYGNSS_INC=ones(size(ease_lat_9km,1),size(ease_lat_9km,2))*-999999;
CYGNSS_INC=int32(CYGNSS_INC);

folder_path='H:\Datasets\CYGNSS\L1\v1.1\mat\2017\';
for doi_i=1:numel(t_doy)
    doy=t_doy(doi_i)
    input_file_path=[folder_path, '9km\USA\',num2str(doy)];
    
    load([input_file_path,'_CSNI_SP_INC_A_USA.mat'])
    
    % del_nan_frame
    dnf_list=[];
    for dnf=1:size(v_frame_3d_CSNI_sp_inc_a,3)
        aa=~isnan(v_frame_3d_CSNI_sp_inc_a(:,:,dnf));
        dnf_list(dnf)=sum(aa(:))==0;
    end
    dnf_list=find(dnf_list==1);
    
    v_frame_3d_CSNI_sp_inc_a(:,:,dnf_list)=[];
    
    kk=size(v_frame_3d_CSNI_sp_inc_a,3);
    nan_value=isnan(v_frame_3d_CSNI_sp_inc_a);
    v_frame_3d_CSNI_sp_inc_a=v_frame_3d_CSNI_sp_inc_a*10000;
    v_frame_3d_CSNI_sp_inc_a=int32(v_frame_3d_CSNI_sp_inc_a);
    v_frame_3d_CSNI_sp_inc_a(nan_value)=-999999;
    
    CYGNSS_INC(:,:,k+1:k+kk)=(v_frame_3d_CSNI_sp_inc_a);
    
    k=size(CYGNSS_INC,3);
    
end
save('H:\Datasets\CYGNSS\L1\v1.1\mat\2017\3d\9km\hr_CYGNSS_INC_USA.mat', 'CYGNSS_INC','-v7.3')

%% mapping

load('H:\Datasets\CYGNSS\L1\v1.1\mat\2017\3d\9km\hr_CYGNSS_DDM_USA.mat')
subset_lat_up=ease_lat_9km(1,1);
subset_lon_left=ease_lon_9km(1,1);
subset_lat_down=ease_lat_9km(end,1);
subset_lon_right=ease_lon_9km(1,end);
load ('E:\matlab\coast_world.mat');
title_='Geostatically resampled';
load('H:\Datasets\SAND_9km.mat')
SAND_9km=SAND_9km(64:233,612:1125);

target=double((CYGNSS_DDM(:,:,1:500)));
target(target==-999999)=nan;
target=target/10000;
target=nanmean(target,3);
target(isnan(SAND_9km))=nan;
c_min=min(min(target));
c_max=max(max(target));
c_map='jet';
c_map_indicator=1;
Statistic_Mapping(subset_lat_down, subset_lat_up, subset_lon_left, subset_lon_right, ease_lat_9km, ease_lon_9km, target,title_,coastworld, c_min,c_max,c_map,c_map_indicator)

%% daily - USA
clear all
clc
load('F:\ease_grid_files\ease_lat_lon_9km.mat')
ease_lat_9km=ease_lat_9km(301:470,612:1125);
ease_lon_9km=ease_lon_9km(301:470,612:1125);

folder_path='H:\Datasets\CYGNSS\L1\v1.1\2017\';
t_doy=[];
doy_get=dir(folder_path);
doy_get(1:2,:)=[];
doy_get(end,:)=[];
for i=1:size(doy_get,1)
    t_doy(i,1)=str2double(doy_get(i).name);
end


daily_CYGNSS_DDM_USA=nan(size(ease_lat_9km,1),size(ease_lat_9km,2), size(doy_get,1));

for doi_i=1:numel(t_doy)
    doy=t_doy(doi_i)
    
    load(['H:\Datasets\CYGNSS\L1\v1.1\mat\2017\9km\USA\',num2str(doy),'_CSNI_DDM_USA.mat'])
    % del_nan_frame
    
    dnf_list=[];
    for dnf=1:size(v_frame_3d_CSNI_ddm,3)
        aa=~isnan(v_frame_3d_CSNI_ddm(:,:,dnf));
        dnf_list(dnf)=sum(aa(:))==0;
    end
    dnf_list=find(dnf_list==1);
    v_frame_3d_CSNI_ddm(:,:,dnf_list)=[];
    
    daily_CYGNSS_DDM_USA(:,:,doi_i)=nanmean(v_frame_3d_CSNI_ddm,3);
    
end
%%
save('H:\Datasets\CYGNSS\L1\v1.1\mat\2017\3d\9km\daily_CYGNSS_DDM_USA.mat', 'daily_CYGNSS_DDM_USA','-v7.3')
%%
load('F:\ease_grid_files\ease_lat_lon_9km.mat')
load('H:\Datasets\CYGNSS\L1\v1.1\mat\2017\3d\9km\daily_CYGNSS_DDM_USA.mat')
ease_lat_9km=ease_lat_9km(301:470,612:1125);
ease_lon_9km=ease_lon_9km(301:470,612:1125);
subset_lat_up=ease_lat_9km(1,1);
subset_lon_left=ease_lon_9km(1,1);
subset_lat_down=ease_lat_9km(end,1);
subset_lon_right=ease_lon_9km(1,end);
load ('E:\matlab\coast_world.mat');
title_='Geostatically resampled';
load('H:\Datasets\SAND_9km.mat')
SAND_9km=SAND_9km(64:233,612:1125);


target=daily_CYGNSS_DDM_USA(:,:,2);
target(isnan(SAND_9km))=nan;
c_min=min(min(target));
c_max=max(max(target));
c_map='jet';
c_map_indicator=1;
Statistic_Mapping_VOD(subset_lat_down, subset_lat_up, subset_lon_left, subset_lon_right, ease_lat_9km, ease_lon_9km, target,title_,coastworld, c_min,c_max,c_map,c_map_indicator)

%% daily CYGNSS (world)
folder_path='H:\Datasets\CYGNSS\L1\v1.1\2017\';
t_doy=[];
doy_get=dir(folder_path);
doy_get(1:2,:)=[];
doy_get(end,:)=[];
for i=1:size(doy_get,1)
    t_doy(i,1)=str2double(doy_get(i).name);
end
CYGNSS_DDM=nan(size(ease_lat_9km,1),size(ease_lon_9km,2),221);
for doi_i=1:numel(t_doy)
    doy=t_doy(doi_i)
    input_file_path=['H:\Datasets\CYGNSS\L1\v1.1\mat\2017\9km\',num2str(doy)];
    
    load([input_file_path,'_CSNI_DDM.mat'])
    
    CSNI_DDM=CSNI_DDM(238:1387,:,:);
    temp=CSNI_DDM;
    CYGNSS_DDM(:,:,doy)=nanmean(temp,3);
    
end
CYGNSS_DDM(:,:,1:76)=[];
save('H:\Datasets\CYGNSS\L1\v1.1\mat\2017\3d\9km\daily_CYGNSS_world.mat', 'CYGNSS_DDM','-v7.3')
%% mapping
load('H:\Datasets\CYGNSS\L1\v1.1\mat\2017\3d\9km\daily_CYGNSS_world.mat')
load('F:\ease_grid_files\ease_lat_lon_9km.mat')
ease_lat_9km_w=ease_lat_9km(238:1387,:);
ease_lon_9km_w=ease_lon_9km(238:1387,:);
target=CYGNSS_DDM(:,:,1);
c_min=min(min(target));
c_max=max(max(target));
c_map='jet';
c_map_indicator=1;
Statistic_Mapping_VOD(subset_lat_down, subset_lat_up, subset_lon_left, subset_lon_right, ease_lat_9km_w, ease_lon_9km_w, target,title_,coastworld, c_min,c_max,c_map,c_map_indicator)
