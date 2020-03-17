;+
; NAME:
;       pro_exists
;
; PURPOSE:
;		checks if a procedure/function exists
;
; CALLING SEQUENCE:
;		pro_exists('test')
;
; INPUTS:
;       name: name of the procedure or function   
;
; MODIFICATION HISTORY:
;       20190308: created by jhinterreiter
;-
function pro_exists, name


catch, error, /cancel

if error ne 0 then begin
	return, 0
endif

resolve_routine, name

return, 1
end