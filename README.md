Introduction
------------

matcomcat is a Matlab package, intended (initially) as a demonstration of Matlab code
used to search the ANSS ComCat Earthquake Catalog.  It currently consists of one class, LibComCat, which
is a wrapper around the ANSS ComCat search  <a href="http://comcat.cr.usgs.gov/fdsnws/event/1/">API</a>.

Installation and Dependencies
-----------------------------

This package depends on:
 * p_json, which can be found here: 
http://www.mathworks.com/matlabcentral/fileexchange/25713-highly-portable-json-input-parser/content/p_json.m

* To install this package, you can either use git to clone the following url:
https://github.com/mhearne-usgs/matcomcat.git

or download the zip file of the repository from:
https://github.com/mhearne-usgs/matcomcat/archive/master.zip

or by clicking the "Download ZIP" button found on:
https://github.com/mhearne-usgs/matcomcat

Any directory created using the above methods should be added to the Matlab path.

Uninstalling and Updating
-------------------------

To uninstall:

Delete the directory created by any of the above installation methods.

To update:

If the initial directory was created by using "git clone", then you can update
by doing:

git pull

in the directory.

For either of the other two methods, uninstall as above and reinstall using your preferred approach.

Usage
------------
<pre>This class is a wrapper around the ComCat search API:
 http://comcat.cr.usgs.gov/fdsnws/event/1/
 It provides methods for retrieving data from ComCat.
 
  getCatalogs - Retrieve a cell array of available product catalogs.
  lbc = LibComCat();
  catalogs = lbc.getCatalogs();
  Output:
   - catalogs is a cell array of available product catalogs
 
  getEventData - Retrieve a cell array of event data from Comcat.
  lbc = LibComCat();
  events = lbc.getEventData(varargin);
  Input:
  - varargin is a list of parameters and values:
             - starttime Matlab datenum object
             - endtime   Matlab datenum object
             - xmin Minimum longitude (dec degrees)
             - xmax Maximum longitude (dec degrees)
             - ymin Minimum latitude (dec degrees)
             - ymax Maximum latitude (dec degrees)
             - minmag Minimum magnitude
             - maxmag Maximum magnitude
  Output:
   - events is a cell array of event structures, where
              the interesting fields are:
              - id: Event id
              - properties: Structure with a set of event
              properties
              - geometry: Structure containing a field called
                 'coordinates', a 3 element cell array of lat,lon,depth
  Usage:
  Retrieve all events greater than 5.5 in the last 30 days
  lbc = LibComCat();
  comevents = lbc.getEventData('starttime',now-30,'endtime',now,'minmag',5.5);
  for i=1:length(comevents)
      [yr,mo,dy,hr,mi,se] = unixsecs2date(comevents{i}.properties.time/1000); %unix time stamp in ms
      etimestr = datestr([yr mo dy hr mi se]);
      fprintf('%s - %s\n',etimestr,comevents{i}.properties.title);
  end
</pre>