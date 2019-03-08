; NAME:
;       getLascoBgData
;
; PURPOSE:
;       Downloads the monthly background data (e.g. 2m_clcl_120401.fts) for the lasco files from https://lasco-www.nrl.navy.mil/content/retrieve/monthly/
;
; CALLING SEQUENCE:
;       getBackgroundData, date, detector
;
; INPUTS:
;       date: year and month (e.g. '201204')
;		detector: detector ('c2' or 'c3')
;
; KEYWORDS:
;		rolled: to get also images from https://lasco-www.nrl.navy.mil/content/retrieve/monthly/rolled/
;
; OUTPUTS:
;       Files downloaded to getenv('MONTHLY_IMAGES')
;
; MODIFICATION HISTORY:
;       20180719: created by jhinterreiter
pro get_lasco_bg_data, date, detector, rolled=rolled

;date = '201207'
;detector = 'c2'

	roll = ''
	if keyword_set(rolled) then roll = 'rolled/'
	
	inst = strmid(detector, 1, 1)


	server = 'https://lasco-www.nrl.navy.mil/content/retrieve/monthly/'+roll

	miPath = getenv('MONTHLY_IMAGES')

	indexFilepath = miPath+'indexFile/'+roll

	if (file_exist(indexFilepath) eq 0) then file_mkdir, indexFilepath

	FileNames = indexFilepath+'FileNames'+strmid(roll, 0, 1)+'.txt'

	; download index.html from the webpage which includes the names of the .fts files
	spawn, 'wget --no-remove-listing --no-check-certificate -O '+FileNames+' '+server

	firstSearchString = '.fts">'
	lastSearchString = '.fts'

	ftsFiles = get_strings_from_file(FileNames, firstSearchString, lastSearchString)

	det = strmid(detector, 1, 1)
	fyear = strmid(date, 2, 1)
	lyear = strmid(date, 3, 1)
	fMon = strmid(date, 4, 1)
	lMon = strmid(date, 5, 1)

	; search string to get all the file from the year and the month, also file beginning with A, B, C, x and the month
	sString = [det+'*_[ABCx'+fyear+'][x'+lyear+']'+fmon+lmon+'??.fts'];'2*_1204??.fts', 

	selFiles = ftsfiles[WHERE(STRMATCH(ftsFiles, sString, /FOLD_CASE) EQ 1)]

	out_dir=miPath+roll

	if (file_exist(out_dir) eq 0) then file_mkdir, out_dir


	toDownload = check_files_exist(out_dir, selfiles)
	if toDownload[0] ne '-1' then begin
		for i = 0, n_elements(toDownload)-1 do begin
			;	print, server+selfiles[i]
			; download the files
			sock_copy,server+toDownload[i],out_dir=out_dir, err= errMsg;, /quiet
		endfor
	endif
end