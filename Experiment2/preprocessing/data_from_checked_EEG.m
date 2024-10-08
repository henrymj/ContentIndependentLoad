subs = {'01','02','03','04','05','06','07','08','10','11','13','14','15','16', '18', '19'};
% subs = {'18','19'}
experiment = 'e';
numsubs= length(subs);
root = '.';
destination = ['../analysis/',experiment,'/'];
cd(root)
eeglab

for isub = 1:numsubs

    sub_folder = ['../raw_data/',subs{isub},'/'];
    files = dir(sub_folder);
    run_files = files(~[files.isdir]);
    run_file_names = {run_files.name};

        % these subjects' run 4 didn't sync so skip
    if ismember(subs{isub},{'14'})
        run_folder_names = {'1','2','3','4'};
    end
    
    for irun = 1:numel(run_file_names)

        run_file = run_file_names(irun);
        unchecked_file = strjoin([sub_folder,run_file],'');
        EEG = pop_loadset(unchecked_file);

        %Titles
        run_destination = strjoin({destination,subs{isub},'/',int2str(irun),'/'},'');
        mkdir(run_destination);
        title = EEG.setname;
        xdata_filename = strjoin({run_destination, title, '_xdata.mat'},'');
        ydata_filename = strjoin({run_destination, title, '_ydata.mat'},'');
        eyetracking_filename = strjoin({run_destination, title, '_eyetracking.mat'},'');
        idx_filename = strjoin({run_destination, title, '_artifact_idx.mat'},'');
        behavior_filename = strjoin({run_destination, title, '_behavior.csv'},'');
        info_filename = strjoin({destination,subs{isub},'/', title, '_info.mat'},'');
        

        % Artifact IDX
        artifact_idx = ~logical(EEG.reject.rejmanual);
        save(idx_filename,'artifact_idx')

        num_chans = EEG.nbchan;
        all_chans = strings(num_chans,1);
        for chan = 1:num_chans
            all_chans(chan,:) = EEG.chanlocs(chan).labels;
        end

        % XData
        EEG = pop_rejepoch(EEG,EEG.reject.rejmanual,0);
        [xdata,chan_idx] = create_xdata(EEG, all_chans);
        save(xdata_filename, 'xdata');
        
        % YData
        ydata = create_ydata(EEG, xdata);
        save(ydata_filename, 'ydata');

        % eyeData
        eyedata = create_eyedata(EEG, all_chans);
        save(eyetracking_filename, 'eyedata');
        
        % Info
        % if irun == 1
        %     unique_ID_file = strjoin(['..\raw_data\','\',subs{isub},'\',run_folder,'\',experiment,'_',subs{isub},'_1.json'],'');
        %     [unique_id,chan_labels,chan_x,chan_y,chan_z,sampling_rate,times] = create_info(EEG, unique_ID_file,chan_idx);
        %     save(info_filename,'unique_id','chan_labels','chan_x','chan_y','chan_z','sampling_rate','times');
        % end
        
        % Save copy of behavior csv
        % behavior_file = strjoin([sub_folder,'\',run_folder,'\',experiment,'_',subs{isub},'_',run_folder,'.csv'],'');
        % copyfile(behavior_file,behavior_filename);
        
        clear labels num_trials templabel x y checked_trials 
    end
end
disp("DATA EXTRACTION COMPLETE")

function [xdata, chan_idx] = create_xdata(EEG, all_chans)
    % create xdata for saving to .mat
    chan_idx = ismember(all_chans,{'L-GAZE-X','L-GAZE-Y','R-GAZE-X','R-GAZE-Y','StimTrak','HEOG','VEOG','TP9','GAZE_X','GAZE_Y'});

    xdata = EEG.data(~chan_idx,:,:);
end

function [ydata] = create_ydata(EEG, xdata)
    % create xdata for saving to .mat. This will definitely change based on
    % your portcode structure!

    num_trials = size(xdata,3);
    ydata = zeros(num_trials,1);
    for x=1:num_trials
        sorted_labels = sort(EEG.epoch(x).eventbinlabel);
        char_labels = char(sorted_labels(end));
        ydata(x,:) = str2double(char_labels(5:6));
    end
end

function [eyedata, chan_idx] = create_eyedata(EEG, all_chans)
    % create eyedata for saving to .mat
    chan_idx = ismember(all_chans,{'L-GAZE-X','L-GAZE-Y','R-GAZE-X','R-GAZE-Y','HEOG','VEOG','GAZE_X','GAZE_Y', 'GAZE-X','GAZE-Y'});
    eyedata = EEG.data(chan_idx,:,:);
end

function [unique_id,chan_labels,chan_x,chan_y,chan_z,sampling_rate,times] = create_info(EEG, unique_ID_file, chan_idx)

    % Gather info variables
    chan_labels = {EEG.chanlocs.labels}';
    chan_labels = char(chan_labels(~chan_idx));
    chan_x = [EEG.chanlocs.X];
    chan_y = [EEG.chanlocs.Y];
    chan_z = [EEG.chanlocs.Z];
    chan_x = chan_x(~chan_idx(1:31));
    chan_y = chan_y(~chan_idx(1:31));
    chan_z = chan_z(~chan_idx(1:31));
    sampling_rate = EEG.srate;
    times = EEG.times;
    
    val = jsondecode(fileread(unique_ID_file));
    unique_id = str2double(val.UniqueSubjectIdentifier);
end