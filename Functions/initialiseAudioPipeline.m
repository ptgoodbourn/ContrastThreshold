function equipment = initialiseAudioPipeline( equipment )
%INITIALISEAUDIOPIPELINE Initialise a PsychToolbox Audio pipeline.
%   INITIALISEAUDIOPIPELINE by itself opens the audio pipeline, but you
%   won't be able to do much with it without returning the handle to the
%   port in the 'equipment' output argument.
%
%   INITIALISEAUDIOPIPELINE(equipment) allows you to set any parameters of
%   the PsychPortAudio('Open') command; type PsychPortAudio Open? for more
%   information on these. They should be passed as fields of the structure
%   'equipment', with the names given in that help file, but in mixed case
%   and with 'audio' as a prefix. For example, to set the latency class to
%   the lowest priority, create the field equipment.audioReqLatencyClass
%   and set it to 0. You needn't pass anything at all; each parameter has a
%   sensible default (see PsychPortAudio Open?). Fields (and corresponding
%   parameters) are:
%
%   audioDeviceId           (deviceid)
%   audioMode               (mode)
%   audioReqLatencyClass    (reqlatencyclass)
%   audioFreq               (freq)
%   audioChannels           (channels)
%   audioBufferSize         (buffersize)
%   audioSuggestedLatency   (suggestedlatency)
%   audioSelectChannels     (selectchannels)
%   audioSpecialFlags       (specialflags)
%
%   equipment = INITIALISEAUDIOPIPELINE(equipment) returns the handle of
%   the audio port in the field equipment.ptbAudioPort.
%
%   09/02/17 PTG wrote it.

    if nargin < 1
        equipment = struct;
    end
    
    if isfield(equipment,'audioDeviceId')
        deviceId = equipment.audioDeviceId;
    else
        deviceId = [];
    end
    
    if isfield(equipment,'audioMode')
        mode = equipment.audioMode;
    else
        mode = [];
    end
    
    if isfield(equipment,'audioReqLatencyClass')
        reqLatencyClass = equipment.audioReqLatencyClass;
    else
        reqLatencyClass = [];
    end
    
    if isfield(equipment,'audioFreq')
        freq = equipment.audioFreq;
    else
        freq = [];
    end
    
    if isfield(equipment,'audioChannels')
        channels = equipment.audioChannels;
    else
        channels = [];
    end
    
    if isfield(equipment,'audioBufferSize')
        bufferSize = equipment.audioBufferSize;
    else
        bufferSize = [];
    end
    
    if isfield(equipment,'audioSuggestedLatency')
        suggestedLatency = equipment.audioSuggestedLatency;
    else
        suggestedLatency = [];
    end
    
    if isfield(equipment,'audioSelectChannels')
        selectChannels = equipment.audioSelectChannels;
    else
        selectChannels = [];
    end
    
    if isfield(equipment,'audioSpecialFlags')
        specialFlags = equipment.audioSpecialFlags;
    else
        specialFlags = 0;
    end
    
    InitializePsychSound;
    equipment.ptbAudioPort = PsychPortAudio('Open', deviceId, mode, reqLatencyClass, freq, channels, bufferSize, suggestedLatency, selectChannels, specialFlags);
    
end

