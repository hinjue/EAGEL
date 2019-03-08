;+
; NAME:
;       run_gcs
;
; PURPOSE:
;       starts the widget to perform the GCS fitting
;		saves the parameter to a .sav file
;
; CALLING SEQUENCE:
;       saved = run_gcs(datetime, filePrepared, fileDone)
;
; INPUTS:
;       date_time: date and time of the images to do the GCS fitting. e.g.: '20101104T03:39:09' 
;		file: file saved from the prepare_data procedure. Has the information of the images included
;		filegui: File with the sgui parameters when GCS fitting was already done once.
;
; OUTPUTS:
;		returns 1 or -1, if the GCS fitting was saved or quitted
;
; MODIFICATION HISTORY:
;       20180711: created by jhinterreiter
;-
function run_gcs, date_time, file, filegui
	date = strmid(date_time, 0, 8)

	hr = strmid(date_time,9,2)
	mi = strmid(date_time,12,2)
	se = strmid(date_time,15,2)
	tim = hr+mi+se


	restore, file, /verbose

	if isa(imb, /array) eq 0 then begin
		imb = ima
		imb[*,*] = 0
		hdrb = hdra
	endif

	print, 'Lasco: ' + hdrl.date_obs + ' ' + hdrl.time_obs
	print, 'STA:   ' + hdra.date_obs
	print, 'STB:   ' + hdrb.date_obs


	if filegui[0] ne '' then begin
		restore, filegui[0]
		sparaminit = sgui
		print, 'Old parameters restored'
	endif


	rtsccguicloud,ima,imb,hdra,hdrb, imlasco=iml, hdrlasco=hdrl, sgui=sgui, swire=swire, ocout=ocout, sparaminit=sparaminit, ssim = ssim, /modal

	if sgui.quit eq 0 then begin

		save, sgui, swire, ocout, filename = getenv('EAGEL_DIR')+'/results/'+date+'/'+date+'_'+tim+'params.sav'

		print, 'Parameters saved'
		return, 1
	endif else begin
		print, 'Images not saved'
		return, -1
	endelse
end