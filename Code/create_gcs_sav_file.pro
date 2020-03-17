;+
; NAME:
;       create_gcs_sav_file
;
; PURPOSE:
;       makes a .sav file from the GCSParameterHelcats.dat file
;
; CALLING SEQUENCE:
;       create_gcs_sav_file
;
;
; NOTE:
;       'DATA_DIR' has to be set! e.g. setenv, 'DATA_DIR=/nas/helio/data/'
;
; MODIFICATION HISTORY:
;       20181129: created by jhinterreiter
;-
PRO create_gcs_sav_file

	path = getenv('DATA_DIR') + 'HELCATS/'
	file = file_search(path+'GCSParameterHelcats.dat')


	readcol, file, idHcme, preDate, pretime, lastDate, lastTime, carlon, stolon, $
		stolat, tilt, ssprat, h_angle, apex_speed, CMEmass, $
		format = 'A,A,A,A,A,F,F,F,F,F,F,F,F', nlines = elements, /silent, skipline = 2, compress = 0
	
	
	posDate = strpos(idhcme[0], '__', /reverse_search)
	idDate = strmid(idhcme, posDate + 2, 8)

	save, idHcme, idDate, preDate, pretime, lastdate, lasttime, carlon, stolon, $
		stolat, tilt, ssprat, h_angle, apex_speed, CMEmass, filename = path+'GCSParameterHelcats.sav'

end