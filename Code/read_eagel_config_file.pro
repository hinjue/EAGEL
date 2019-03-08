; gets the paths from the config file
FUNCTION get_parameter_from_config_file, inputText, var
	
	for i = 0, n_elements(inputText)-1 do begin
		line = inputText[i]
		if STRCMP(line, var, strlen(var), /FOLD_CASE) then begin
			return, strmid(line, strlen(var)+1, strlen(line))
;		if line.startWith(var) then stop
		endif
	endfor
	return, ''
END




;!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!
;!!! START of program !!!
;!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!
;+
; NAME:
;       read_eagel_config_file
;
; PURPOSE:
;       Reads the config file and sets all the needed environment variables:
;			DATA_DIR
;			SECCHI_LZ
;			LASCO_DIR
;			MONTHLY_IMAGES
;			NRL_LIB
;			SECCHI_BKG, if needed
;
; CALLING SEQUENCE:
;		read_eagel_config_file
;
; MODIFICATION HISTORY:
;       20181129: created by jhinterreiter
;-
PRO read_eagel_config_file

	file = getenv('EAGEL_DIR')+'Code/EAGEL_config.dat'

	OPENR, lun, file, /GET_LUN
	; Read one line at a time, saving the result into array
	array = ''
	line = ''
	WHILE NOT EOF(lun) DO BEGIN & $
	  READF, lun, line & $
	  array = [array, line] & $
	ENDWHILE
	; Close the file and free the file unit
	FREE_LUN, lun

	EAGEL_Path = get_parameter_from_config_file(array, 'EAGEL_DIR')
	Data_Path = get_parameter_from_config_file(array, 'DATA_DIR')
	LASCO_BG_Path = get_parameter_from_config_file(array, 'LASCO_BG_DIR')
	STEREO_BG_Path = get_parameter_from_config_file(array, 'STEREO_BG_DIR')
	NRL_LIB = get_parameter_from_config_file(array, 'NRL_LIB')
	RESULTS_Path = get_parameter_from_config_file(array, 'RESULTS_DIR')


	if Data_Path ne '' then begin
		setenv, 'DATA_DIR='+Data_Path
		setenv, 'SECCHI_LZ='+Data_Path+'STEREO/secchi/'
		setenv, 'LASCO_DIR='+Data_Path+'LASCO/'
	endif

	if LASCO_BG_Path ne '' then setenv, 'MONTHLY_IMAGES='+LASCO_BG_Path
	if NRL_LIB ne '' then setenv, 'NRL_LIB='+NRL_LIB
	if STEREO_BG_Path ne '' then setenv, 'SECCHI_BKG='+STEREO_BG_Path

END