; NAME:
;       getSTBgData
;
; PURPOSE:
;       Downloads the monthly_min background data (*_dbTB_*.fts) for the stereo files from stereo-ssc.nascom.nasa.gov
;
; CALLING SEQUENCE:
;       getBackgroundData, '201204', 'a', 'c2'
;
; INPUTS:
;       date: year and month (e.g. '201204')
;		sc: spacecraft ('a' for STEREO-A and 'b' for STEREO-B)
;		det: detector ('c1' for COR1 and 'c2' for COR2)
;
; OUTPUTS:
;       Files downloaded to getenv('SECCHI_LZ')+/secchi/backgrounds/a/monthly_min/+date
;
; MODIFICATION HISTORY:
;       20181102: created by jhinterreiter

pro get_stereo_bg_data, date, sc, detector

;date = '201207'
;sc = 'b'
;detector = 'c2'

scu=STRUPCASE(sc)

inst = strmid(detector, 1, 1)

	server = 'https://stereo-ssc.nascom.nasa.gov/data/ins_data/secchi_backgrounds/'+sc+'/monthly_min/'+date+'/'

	indexFilepath = getenv('SECCHI_LZ')+'backgrounds/'+sc+'/indexFile/'

	if (file_exist(indexFilepath) eq 0) then file_mkdir, indexFilepath

	FileNames = indexFilepath+'FileNames.txt'

	; download index.html from the webpage which includes the names of the .fts files
	spawn, 'wget --no-remove-listing --no-check-certificate -O '+FileNames+' '+server

	firstSearchString = '.fts">'
	lastSearchString = '.fts'

	ftsFiles = get_strings_from_file(FileNames, firstSearchString, lastSearchString)

	det = strmid(detector, 1, 1)
	newDate = strmid(date, 2,6)


	; search string to get all the file from the year and the month, also file beginning with A, B, C, x and the month
	sString = ['??'+det+scu+'_*'+newdate+'??.fts']

	indexSelFiles = WHERE(STRMATCH(ftsFiles, sString, /FOLD_CASE) EQ 1)
	if indexSelfiles[0] ne -1 then begin
		selFiles = ftsfiles[indexSelFiles]

		out_dir = getenv('SECCHI_LZ')+'backgrounds/'+sc+'/monthly_min/'+date+'/'
	;	out_dir=miPath+roll

		if (file_exist(out_dir) eq 0) then file_mkdir, out_dir


		toDownload = check_files_exist(out_dir, selfiles)
		if toDownload[0] ne '-1' then begin
			for i = 0, n_elements(toDownload)-1 do begin
				;	print, server+selfiles[i]
				; download the files
				sock_copy,server+toDownload[i],out_dir=out_dir, err= errMsg;, /quiet
			endfor
		endif
	endif
end