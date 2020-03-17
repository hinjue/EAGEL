; NAME:
;       download_realtime_images
;
; PURPOSE:
;       to get the latest coronagraph images
;
; CALLING SEQUENCE:
;      download_realtime_images, 'C3', '20200310', '/home/jhinterreiter/testDownload/'
;
; INPUTS:
;       detector: name of the detector
;				  c2: for LASCO/C2
;				  c3: for LASCO/C3
;				  cor2: for STA/COR2
;		date: download date (format: 'YYYYMMDD', eg. 20200302)
;		outPath: path where to save the files
;
; MODIFICATION HISTORY:
;       20200310: created by jhinterreiter
pro download_realtime_images, stereoInst, lascoDet, date, status = status

	; just for test
	if 0 eq 1 then begin
		detector = 'cor2'
		date = '20200310'
		outPath = '/home/jhinterreiter/testDownload/'
	endif

	date = strmid(date, 0, 8)
	status = 0

	det = strlowcase(lascoDet)
	if det eq 'c2' or det eq 'c3' then begin
		;https://umbra.nascom.nasa.gov/pub/lasco/lastimage/level_05/200310/c2/
		lserver = 'https://umbra.nascom.nasa.gov/pub/lasco/lastimage/level_05/'
		ldate = strmid(date, 2,10)
		outPath = getenv('LASCO_DIR') + strupcase(lascoDet) + '/realtime/' + date + '/'
		if (file_exist(outPath) eq 0) then file_mkdir, outPath

		sock_copy, lserver + ldate + '/'+ det + '/img_hdr.txt', out_dir=outPath, err= errMsg

		hdrFile = file_search(outpath+'*.txt')
		readcol, hdrFile, fname, fdate, ftime, fdet, format = 'A, A, A, A'

		toDownload = check_files_exist(outpath, fname)
		if toDownload[0] ne '-1' then begin
			nrDownload = n_elements(toDownload)-1
			for i = 0, nrDownload do begin
				print, 'Downloading: ' + string(i) + '/' + string(nrDownload) + '       ' + toDownload[i]
				sock_copy, lserver + ldate + '/'+ det + '/' + toDownload[i], out_dir=outPath, err= errMsg
			endfor
		endif

		file_delete, hdrFile
	endif

	det = strlowcase(stereoInst)
	if det eq 'cor2' then begin
		;https://stereo-ssc.nascom.nasa.gov/data/beacon/ahead/secchi/img/cor2/20200310/
		server = 'https://stereo-ssc.nascom.nasa.gov/data/beacon/ahead/secchi/img/cor2/'
		outPath = getenv('SECCHI_LZ') + 'beacon/ahead/img/cor2/' + date + '/'
		if (file_exist(outPath) eq 0) then file_mkdir, outPath

		sock_copy, server + date, out_dir=outPath, err=errMsg

		hdrFile = file_search(outPath+date)
		firstSearchString = '.fts">'
		lastSearchString = '.fts'

		ftsFiles = get_strings_from_file(hdrFile, firstSearchString, lastSearchString)

		toDownload = check_files_exist(outpath, ftsFiles)
		if toDownload[0] ne '-1' then begin
			nrDownload = n_elements(toDownload)-1
			for i = 0, nrDownload do begin
				print, 'Downloading: ' + string(i) + '/' + string(nrDownload) + '       ' + toDownload[i]
				sock_copy, server + date + '/' + toDownload[i], out_dir=outPath, err= errMsg
			endfor
		endif

		file_delete, hdrFile

	endif

	status = 1
	print, 'all data downloaded'
end

