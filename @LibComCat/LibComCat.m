classdef LibComCat
    %This class is a wrapper around the ComCat search API:
    %http://comcat.cr.usgs.gov/fdsnws/event/1/
    %It provides methods for retrieving data from ComCat.
    %
    % getCatalogs - Retrieve a cell array of available product catalogs.
    % lbc = LibComCat();
    % catalogs = lbc.getCatalogs();
    % Output:
    %  - catalogs is a cell array of available product catalogs
    %
    % getEventData - Retrieve a cell array of event data from Comcat.
    % lbc = LibComCat();
    % events = lbc.getEventData(varargin);
    % Input:
    % - varargin is a list of parameters and values:
    %            - starttime Matlab datenum object
    %            - endtime   Matlab datenum object
    %            - xmin Minimum longitude (dec degrees)
    %            - xmax Maximum longitude (dec degrees)
    %            - ymin Minimum latitude (dec degrees)
    %            - ymax Maximum latitude (dec degrees)
    %            - minmag Minimum magnitude
    %            - maxmag Maximum magnitude
    % Output:
    %  - events is a cell array of event structures, where
    %             the interesting fields are:
    %             - id: Event id
    %             - properties: Structure with a set of event
    %             properties
    %             - geometry: Structure containing a field called
    %                'coordinates', a 3 element cell array of lat,lon,depth
    % Usage:
    % Retrieve all events greater than 5.5 in the last 30 days
    % lbc = LibComCat();
    % comevents = lbc.getEventData('starttime',now-30,'endtime',now,'minmag',5.5);
    % for i=1:length(comevents)
    %     [yr,mo,dy,hr,mi,se] = unixsecs2date(comevents{i}.properties.time/1000); %unix time stamp in ms
    %     etimestr = datestr([yr mo dy hr mi se]);
    %     fprintf('%s - %s\n',etimestr,comevents{i}.properties.title);
    % end
    
            
    properties (Access=private)
      baseurl
    end
    properties(Constant)
        TIMEFMT = 'yyyy-mm-ddTHH:MM:SS';
    end
    methods
        function obj = LibComCat()
            %Create a LibComCat object
            obj.baseurl = 'http://comcat.cr.usgs.gov/fdsnws/event/1/[METHOD[?PARAMETERS]]';
        end
        function catalogs = getCatalogs(obj)
            url = strrep(obj.baseurl,'[METHOD[?PARAMETERS]]','catalogs');
            xmlstr = urlread(url);
            tmpfile = 'tmp.xml';
            fid = fopen(tmpfile,'wt');
            fwrite(fid,xmlstr);
            fclose(fid);
            try
                catalogs = {};
                dom = xmlread(tmpfile);
                cats = dom.getElementsByTagName('Catalog');
                for i=1:cats.getLength()
                    catalog = char(cats.item(i-1).getFirstChild().getData());
                    catalogs{end+1} = catalog;
                end
            catch me
                delete(tmpfile);
            end
        end
        function events = getEventData(obj,varargin)
            
            url = strrep(obj.baseurl,'[METHOD[?PARAMETERS]]','query');
            pstruct = getparamstruct(varargin);
            params = {'format','geojson','orderby','time-asc'};
            
            if isfield(pstruct,'starttime')
                params{end+1} = 'starttime';
                params{end+1} = datestr(pstruct.starttime,obj.TIMEFMT);
            end
            if isfield(pstruct,'endtime')
                params{end+1} = 'endtime';
                params{end+1} = datestr(pstruct.endtime,obj.TIMEFMT);
            end
            if isfield(pstruct,'xmin')
                params{end+1} = 'minlongitude';
                params{end+1} = num2str(pstruct.xmin,'%.6f');
            end
            if isfield(pstruct,'xmax')
                params{end+1} = 'maxlongitude';
                params{end+1} = num2str(pstruct.xmax,'%.6f');
            end
            if isfield(pstruct,'ymin')
                params{end+1} = 'minlatitude';
                params{end+1} = num2str(pstruct.ymin,'%.6f');
            end
            if isfield(pstruct,'ymax')
                params{end+1} = 'maxlatitude';
                params{end+1} = num2str(pstruct.ymax,'%.6f');
            end
            if isfield(pstruct,'minmag')
                params{end+1} = 'minmagnitude';
                params{end+1} = num2str(pstruct.minmag,'%.1f');
            end
            if isfield(pstruct,'maxmag')
                params{end+1} = 'maxmagnitude';
                params{end+1} = num2str(pstruct.maxmag,'%.1f');
            end
            data = urlread(url,'get',params);
            jstruct = p_json(data);
            events = jstruct.features;
        end
    end
end

% getparamstruct  Return a parameter structure from cell array of parameters.
% paramstruct = getparamstruct(varargin);
% Input:
%  - varargin     Nx2 Cell array of key,value pairs.
%  Output:
%  - paramstruct  Structure version of key value pairs.
% Usage:
% Create a parameter structure from the variable arguments:
% varargin = {'param1',5,'param2',[7 5 4],'param3',{'one','two'}};
% results in:
% paramstruct.param1 = 5;
% paramstruct.param2 = [7 5 4];
% paramstruct.param3 = {'one','two'};
function paramstruct = getparamstruct(varargin)
    args = varargin{1};
    nargs = length(args);
    if mod(nargs,2)
        %fprintf('Must have a value for every parameter.  Returning.\n');
        paramstruct = struct();
        return;
    end
    paramstruct = struct();
    for i=1:nargs/2
        vidx = i*2;
        pidx = vidx-1;
        param = args{pidx};
        value = args{vidx};
        if ~isstr(param)
            fprintf('Parameter names must be strings.  Returning empty.\n');
            paramstruct = struct();
            return;
        end
        paramstruct = setfield(paramstruct,param,value);
    end
    return;
end