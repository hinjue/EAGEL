;+
; NAME:
;       downloadImages
;
; PURPOSE:
;       Downloads STEREO/COR? and LASCO/C? images to /home/jhinterreiter/data/
;
; CALLING SEQUENCE:
;       download_images, '20101104T00:00:00', '20101104T02:00:00', 'COR2', 'C2', status = status
;
; INPUTS:
;       startDate: when the download should start
;       endDate: when the download should end
;		stereoInst: either 'COR1' or 'COR2'
;		lascoInst: either 'C2' or 'C3'
;
; OUTPUTS:
;       Files downloaded to  getenv('LASCO_DIR') and getenv('SECCHI_LZ')
;
; NOTE:
;       'SECCHI_LZ' has to be set! setenv, 'SECCHI_LZ=/home/jhinterreiter/data/stereo'
;		'LASCO_DIR' has to be set!
;
; MODIFICATION HISTORY:
;       20180711: created by jhinterreiter
;-

pro download_images, startDate, endDate, stereoInst, lascoDet, status = status

;startDate = '20120419T17:00' ; start date
;endDate = '20120419T18:00' ; end date
;startDate = '20180827T00:00' ; start date
;endDate = '20180827T23:59' ; end date
;lascoDet = 'C3' ; or 'C3'
;stereoInst = 'COR2'; or 'COR1'

status = 0


yr = strmid(endDate, 0,4)
mn = strmid(enddate, 4,2)
dy = strmid(enddate, 6,2)
time = strmid(enddate, 9, 9)

end_time_s = anytim(yr+'-'+mn+'-'+dy+'T'+time, /stime)

yr = strmid(startDate, 0,4)
mn = strmid(startdate, 4,2)
dy = strmid(startdate, 6,2)
time = strmid(startdate, 9, 9)
date = yr+mn+dy

start_time_s = anytim(yr+'-'+mn+'-'+dy+'T'+time, /stime)

;create directories
lascoDir = getenv('LASCO_DIR')+lascoDet+'/'+date
secchiPath = getenv('SECCHI_LZ')
stereoDir = secchiPath+'tmpFiles/'

if (file_exist(stereoDir) eq 0) then file_mkdir, stereoDir

sPos = strpos(secchiPath, 'secchi/')
stereoPath = strmid(secchipath, 0, spos)



if file_test(lascoDir, /directory) eq 0 then begin
	file_mkdir, lascoDir, /NOEXPAND_PATH
endif


det = 'c2'
if stereoInst eq 'COR1' then det = 'c1'



	; download stereo background data
;	get_stereo_bg_data, yr+mn, 'a', det
;	get_stereo_bg_data, yr+mn, 'b', det
	; download lasco background data
;	get_lasco_bg_data, yr+mn, lascoDet
;	get_lasco_bg_data, yr+mn, lascoDet, /rolled


; search for lasco files and download them
LFiles=vso_search(start_time_s, end_time_s, inst='LASCO', det=lascoDet)

if isa(lfiles, /array) then begin
	lFileNames = lfiles.fileid
	fcnt = n_elements(lfileNames)
	lfileNamesArr = strarr(fcnt)
	for i = 0, fcnt-1 do begin
		pos = strpos(lfileNames[i], '/', /reverse_search)
		lfileNamesArr[i] = strmid(lfileNames[i], pos, strlen(lfileNames[i]))
	endfor
	toDownload = check_files_exist(lascoDir, lfileNamesArr, index = index)
;	if index[0] eq -1 then print, 'All LASCO images already downloaded'
	if index[0] ne -1 then begin
		dFiles = lfiles[index]
		b=vso_get(dFiles, out_dir=lascodir+'/', /force);, /quiet)
	endif

	print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
	print, 'LASCO files can be found in: '+lascodir
	print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
endif


; search for stereo files and download them in tmpFiles
sFiles=vso_search(start_time_s, end_time_s, inst=stereoInst)

if isa(sfiles, /array) then begin
	toDownload = check_files_exist(stereoPath, sfiles.fileid, index = index)
;	if index[0] eq -1 then print, 'All Stereo images already downloaded'
	if index[0] ne -1 then begin
		print, 'Downloading '+strtrim(string(n_elements(index), 2))+' files'
		dFiles = sfiles[index]
		b=vso_get(dFiles, out_dir=stereoDir, /force);, /quiet)
		; create the stereo structure e.g. 'L0/a/img/...'
		sccingest, stereoDir
	endif
endif

pathImg = 'img/cor2/'+date
if stereoInst eq 'COR1' then pathImg = 'seq/cor1/'+date

STADir = secchiPath + 'L0/a/'+pathImg
STBDir = secchiPath + 'L0/b/'+pathImg

print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
print, 'STEREO files can be found in: '
print, STADir
print, STBDir


;print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
;print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
print, '!!! All images downloaded !!!'
;print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
;print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
status = 1
end

