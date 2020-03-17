; NAME:
;       get_strings_from_file
;
; PURPOSE:
;       gets all the strings in a certain format contained in a file
;
; CALLING SEQUENCE:
;      ftsFiles = get_strings_from_file(FileNames, firstSearchString, lastSearchString)
;
; INPUTS:
;       fileName: name of the file in which should be searched
;		s1: first search string
;		s2: second search string
;
; OUTPUTS:
;       strings with a certain format within the file
;
; EXAMPLE:
;		file contains a line e.g: ...td><a href="3mr_orcl_111210.fts">3mr_orcl_111210.fts</a>...
;		and .fts files are wanted, then:
;			s1 could be e.g.: '.fts">'
;			s2 could be e.g.: '.fts'
;			result for this line is: 3mr_orcl_111210.fts
;
; MODIFICATION HISTORY:
;       20180719: created by jhinterreiter
function get_strings_from_file, fileName, s1, s2

	OPENR, lun, filename, /GET_LUN
	; Read one line at a time, saving the result into array
	;array = ''
	line = ''
	ftsFiles = ''
	WHILE NOT EOF(lun) DO BEGIN
		READF, lun, line
		ftsPos = strpos(line, s2, /reverse_search)
		if ftsPos ne -1 then begin
			brPos = strpos(line, s1, /reverse_search)+strlen(s1)
			file=strmid(line, brPos, ftsPos-brPos+strlen(s2))
			ftsFiles = [ftsFiles, file]
		endif
	ENDWHILE
	; Close the file and free the file unit
	FREE_LUN, lun

	return, ftsFiles
end


function test_fct
	return, -1
end

