% The CYGNSS spacecraft numerical identifier (CSNI)
% ddm reflectometry channel (DRC)
%
% Mar/24/2018: Initial specification
% Aug/22/2020: Update for Rivanna
clear; clc

addpath('/sfs/qumulo/qproject/hydrosense/matlab/libs/SAT_data_related_CODE/')
load('/sfs/qumulo/qproject/hydrosense/matlab/mat/ease_grid_files/ease_lat_lon_9km.mat')
%load ('E:\matlab\coast_world.mat');
load('/sfs/qumulo/qproject/hydrosense/matlab/mat/soil_climate_etc/SAND_9km.mat');
%%
%CONUS region
ease_lat_9km=ease_lat_9km(163:469,590:1211);
ease_lon_9km=ease_lon_9km(163:469,590:1211);
SAND_9km=SAND_9km(163:469,590:1211);
reference_lat=ease_lat_9km;
reference_lon=ease_lon_9km;
%%
year_=2019;
folder_path=['/scratch/hk5kp/CYGNSS/v2.1/',num2str(year_),'/'];
doy_get=dir(folder_path);
doy_get(1:2,:)=[];

for i=1:size(doy_get,1)
    t_doy(i,1)=str2double(doy_get(i).name);
end

v_frame=nan(size(reference_lat,1),size(reference_lat,2));
v_frame_3d_hr=nan(size(reference_lat,1),size(reference_lat,2),23);
v_frame_3d_DRC=nan(size(reference_lat,1),size(reference_lat,2),4*23);
%
% doy=93;input_file_path=[folder_path,'0',num2str(doy),'\'];
% list_CYG=filename2cell(input_file_path,'nc');
% CSNI=1;
% snr=ncread([input_file_path,list_CYG{CSNI}],'ddm_snr');
% fc=ncread([input_file_path,list_CYG{CSNI}],'fresnel_coeff');
% inc_a=ncread([input_file_path,list_CYG{CSNI}],'sp_inc_angle');
t_lat=reference_lat(:,1); t_lon=reference_lon(1,:); ocean_pixel=isnan(SAND_9km);
bad_index=1; bad_file=[];
DDM_SNR=cell(size(reference_lat)); SP_INC_A=DDM_SNR; DDM_ANT=DDM_SNR; UTC=DDM_SNR;

for doi_i=1:numel(t_doy)
    
    doy=t_doy(doi_i);
    
    if doy<10
        input_file_path=[folder_path,'00',num2str(doy),'/'];
    elseif doy<100
        input_file_path=[folder_path,'0',num2str(doy),'/'];
    else
        input_file_path=[folder_path,num2str(doy),'/'];
    end
    
    [~, cmdout]=system(['find ',input_file_path,' -iname "*.nc" -type f']);
    t=strfind(cmdout, input_file_path);
    list_CYG_w=[];
    list_CYG=[];
    name_length=t(2)-t(1)+1;
    
    for i=1:numel(t)
        list_CYG_w{i,1}=cmdout(t(i):t(i)+name_length-3);
        list_CYG{i,1}=list_CYG_w{i}(strlength(input_file_path)+1:end);
    end
        
    %list_CYG=filename2cell(input_file_path,'nc');
    daily_ddm_snr=[]; daily_sp_inc_a=[]; daily_ddm_ant=[]; daily_utc=[]; daily_sp_lat=[]; daily_sp_lon=[];
    
    for CSNI=1:numel(list_CYG)
        [doy, CSNI]
        
        try
            t_ddm_snr=ncread([input_file_path,list_CYG{CSNI}],'ddm_snr');
            t_ddm_snr(t_ddm_snr==-9999)=nan ;sz=size(t_ddm_snr);
            t_ddm_snr=reshape(t_ddm_snr, 1,size(t_ddm_snr,2)*size(t_ddm_snr,1));            
            daily_ddm_snr=[daily_ddm_snr, t_ddm_snr];
            
            t_sp_inc_a=ncread([input_file_path,list_CYG{CSNI}],'sp_inc_angle'); t_sp_inc_a(t_sp_inc_a==-9999)=nan;
            t_sp_inc_a=reshape(t_sp_inc_a, 1,sz(1)*sz(2));            
            daily_sp_inc_a=[daily_sp_inc_a, t_sp_inc_a];
            
            t_ddm_ant=ncread([input_file_path,list_CYG{CSNI}],'sp_rx_gain'); t_ddm_ant(t_ddm_ant==-99)=nan; %5>nan;
            t_ddm_ant=reshape(t_ddm_ant, 1,sz(1)*sz(2));
            daily_ddm_ant=[ daily_ddm_ant, t_ddm_ant];
            
            t_utc=ncread([input_file_path,list_CYG{CSNI}],'ddm_timestamp_utc')';
            t_utc=repmat(t_utc, [1,sz(1)]);
            daily_utc=[daily_utc, t_utc/60/60/24+datenum(year_-1,12,31)+doy];
           
            t_sp_lat=ncread([input_file_path,list_CYG{CSNI}],'sp_lat'); t_sp_lat(t_sp_lat==-9999)=nan;
            t_sp_lat=reshape(t_sp_lat, 1,sz(1)*sz(2));
            daily_sp_lat=[daily_sp_lat, t_sp_lat];
           
            t_sp_lon=ncread([input_file_path,list_CYG{CSNI}],'sp_lon'); t_sp_lon(t_sp_lon==-9999)=nan;
            t_sp_lon=reshape(t_sp_lon, 1,sz(1)*sz(2));
            t_sp_lon(t_sp_lon>=180)=t_sp_lon(t_sp_lon>=180)-360;
            daily_sp_lon=[daily_sp_lon, t_sp_lon];
            
        catch          
            ['bad-',num2str(doy),'-',num2str(CSNI)]
            bad_file{bad_index,1}=[input_file_path,list_CYG{CSNI}];
            bad_index=bad_index+1;
        end
    end
    daily_sp_lat(daily_sp_lat>max(t_lat) | daily_sp_lat<min(t_lat) | daily_sp_lon>max(t_lon) | daily_sp_lon<min(t_lon))=nan;
    daily_sp_lon(daily_sp_lat>max(t_lat) | daily_sp_lat<min(t_lat) | daily_sp_lon>max(t_lon) | daily_sp_lon<min(t_lon))=nan;
    nan_value=isnan(sum([daily_ddm_snr; daily_sp_inc_a; daily_ddm_ant; daily_utc; daily_sp_lat; daily_sp_lon]));
    daily_ddm_snr(nan_value)=[]; daily_sp_inc_a(nan_value)=[];daily_ddm_ant(nan_value)=[];daily_utc(nan_value)=[];daily_sp_lat(nan_value)=[];daily_sp_lon(nan_value)=[];
    
    t_lat_index=interp1(t_lat, 1:size(t_lat,1), daily_sp_lat,'nearest');t_lon_index=interp1(t_lon, 1:size(t_lon,2), daily_sp_lon,'nearest');
    index_array=sub2ind(size(reference_lat), t_lat_index, t_lon_index);
    invalid=isnan(sum([t_lat_index, t_lon_index],2));
    daily_ddm_snr(invalid)=[];daily_sp_inc_a(invalid)=[]; daily_ddm_ant(invalid)=[];daily_utc(invalid)=[];daily_sp_lat(invalid)=[];daily_sp_lon(invalid)=[]; t_lat_index(invalid)=[]; t_lon_index(invalid)=[];
    
    for i=1:numel(index_array)        
        DDM_SNR{index_array(i)}=[DDM_SNR{index_array(i)}, single(daily_ddm_snr(i))];
        SP_INC_A{index_array(i)}=[SP_INC_A{index_array(i)}, single(daily_sp_inc_a(i))];
        DDM_ANT{index_array(i)}=[DDM_ANT{index_array(i)}, single(daily_ddm_ant(i))];
        UTC{index_array(i)}=[UTC{index_array(i)}, daily_utc(i)];               
    end  
    DDM_SNR((ocean_pixel))={[]}; SP_INC_A((ocean_pixel))={[]}; DDM_ANT((ocean_pixel))={[]}; UTC((ocean_pixel))={[]};
    
end

save(['/project/hydrosense/matlab/mat/CYGNSS/UVA/',num2str(year_),'.mat'],'DDM_SNR','SP_INC_A','DDM_ANT','UTC','reference_lat','reference_lon')
%% Mapping
% % temp=CSNI_DDM{82,4};
% title_='Geostatically resampled';
% target=temp;
% c_min=min(min(target));
% c_max=max(max(target));
% c_map='jet';
% c_map_indicator=1;
% % target(isnan(new_SAND))=nan;
% % temp_lat=subset_lat_up:-resol:subset_lat_down+resol/2;
% % temp_lon=subset_lon_left:resol:subset_lon_right+resol/2;
% % [reference_lon,reference_lat]=meshgrid(temp_lon,temp_lat);
% subset_lat_down=min(lat_1d);
% subset_lat_up=max(lat_1d);
% subset_lon_left=min(lon_1d);
% subset_lon_right=max(lon_1d);
% 
% Statistic_Mapping_VOD(subset_lat_down, subset_lat_up, subset_lon_left, subset_lon_right, reference_lat, reference_lon, target,title_,coastworld, c_min,c_max,c_map,c_map_indicator)



