%--------------------------BEGIN NOTE------------------------------%
% University of Virginia
%--------------------------END NOTE--------------------------------%
% ARGUMENTS:
%
% INPUTS: SMAP hdf files
%
% DESCRIPTION:
%
% REVISION HISTORY: 
% 9 Jul 2020 Hyunglok Kim; initial specification
%-----------------------------------------------------------------%

clear; clc
ifp='/project/hydrosense/LIS_INPUT/RS_DATA/SMAP/SPL3SMP_E.003/'; % folder path for SPL3SMP
ofp='/project/hydrosense/matlab/mat/SMAP/SPL3SMP_E.003/'; % folder path for outpus

for year_=2019:2019
    
    [~, cmdout]=system(['find ',ifp,' -iname "*_',num2str(year_),'*" -type f']);
    t=strfind(cmdout, ifp);
    list_SMAP_w=[];list_SMAP_or=[];
    name_length=t(2)-t(1)+1;
    
    for i=1:numel(t)
        list_SMAP_w{i,1}=cmdout(t(i):t(i)+name_length-3);
        list_SMAP_or{i,1}=list_SMAP_w{i}(strlength(ifp)+1:end);
    end
    
    nof=numel(list_SMAP_or); %number of file per year/ can be less than 365/366
    
    data_doy=[];
    for i=1:nof
        temp=list_SMAP_or{i};
        data_doy(i,1)=date2doy(datenum(str2double(temp(27:30)),str2double(temp(31:32)),str2double(temp(33:34))));
    end
    
    nod=date2doy(datenum((year_),12,31)); %number of day in certain year
    list_SMAP=cell(nod,1);
    for i=1:numel(t)
        list_SMAP{data_doy(i),1}=list_SMAP_or{i};
    end
    
    lat=h5read([ifp, list_SMAP{data_doy(1)}], '/Soil_Moisture_Retrieval_Data_AM/latitude')';
    lon=h5read([ifp, list_SMAP{data_doy(1)}], '/Soil_Moisture_Retrieval_Data_AM/longitude')';
    nan_frame=single(nan(size(lat,1), size(lat,2)));
    nan_frame_3d=single(nan(size(lat,1), size(lat,2), nod));
    
    SMAP_SM_am=nan_frame_3d; SMAP_SM_pm=nan_frame_3d;
    t_file=[];
    for doy=1:nod
        disp([num2str(year_), '.',num2str(doy)])
        if ~isempty(list_SMAP{doy})
            t_file=[ifp, list_SMAP{doy}];
            temp_or_SM_am=h5read(t_file, '/Soil_Moisture_Retrieval_Data_AM/soil_moisture')'; % am
            temp_or_SM_pm=h5read(t_file, '/Soil_Moisture_Retrieval_Data_PM/soil_moisture_pm')'; % pm
            
            SMAP_SM_am(:,:,doy)=single(temp_or_SM_am);
            SMAP_SM_pm(:,:,doy)=single(temp_or_SM_pm);
        else
            disp([num2str(year_), '.',num2str(doy),'>>no data'])
            SMAP_SM_am(:,:,doy)=nan_frame;
            SMAP_SM_pm(:,:,doy)=nan_frame;
        end
    end
    
    save([ofp,num2str(year_),'_SMAP_SM_am.mat'],'SMAP_SM_am', 'lat','lon','-v7.3')
    clearvars SMAP_SM_am
    save([ofp,num2str(year_),'_SMAP_SM_pm.mat'],'SMAP_SM_pm', 'lat','lon','-v7.3')
    clearvars SMAP_SM_pm

    SMAP_RQF_am=nan_frame_3d; SMAP_RQF_pm=nan_frame_3d;
    t_file=[];
    for doy=1:nod
        disp([num2str(year_), '.',num2str(doy)])
        if ~isempty(list_SMAP{doy})
            t_file=[ifp, list_SMAP{doy}];
            temp_or_RQF_am=h5read(t_file, '/Soil_Moisture_Retrieval_Data_AM/retrieval_qual_flag')'; % am
            temp_or_RQF_pm=h5read(t_file, '/Soil_Moisture_Retrieval_Data_PM/retrieval_qual_flag_pm')'; % pm
            
            SMAP_RQF_am(:,:,doy)=single(temp_or_RQF_am);
            SMAP_RQF_pm(:,:,doy)=single(temp_or_RQF_pm);
        else
            disp([num2str(year_), '.',num2str(doy),'>>no data'])
            SMAP_RQF_am(:,:,doy)=nan_frame;
            SMAP_RQF_pm(:,:,doy)=nan_frame;
        end
    end
    
    save([ofp,num2str(year_),'_SMAP_RQF_am.mat'],'SMAP_RQF_am', 'lat','lon','-v7.3')
    clearvars SMAP_RQF_am
    save([ofp,num2str(year_),'_SMAP_RQF_pm.mat'],'SMAP_RQF_pm', 'lat','lon','-v7.3')
    clearvars SMAP_RQF_pm

end
