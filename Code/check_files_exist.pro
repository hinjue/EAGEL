; NAME:
;       check_files_exist
;
; PURPOSE:
;       checks if files are already existing. Returns a list of not already existing files
;
; CALLING SEQUENCE:
;      toDownload = check_files_exist(path, files)
;
; INPUTS:
;       path: path to the local files
;		files: name of the files
;
; OUTPUTS:
;		the name of the files that are not existing
;		-1: if all files exist
;
; KEYWRODS: 
;		index: returns the index of the files that do not already exist, (-1 if all files exist)
;
; MODIFICATION HISTORY:
;       20180719: created by jhinterreiter
function check_files_exist, path, files, index = index

	filesPath = path[0]+files
	existing = file_search(filesPath)
	if existing[0] ne '' and n_elements(existing) eq n_elements(filesPath) then begin 
		index = -1
		return, -1
	endif else begin
		match2, existing, filespath, suba, subb
		index = where(subb eq -1)
		return, files[index]
	endelse
end
