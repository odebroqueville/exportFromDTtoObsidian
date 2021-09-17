property databaseUUID : "53DCB0A6-5506-4325-8079-0302105A228E" -- Switch this with the uuid of the database for your summary notes.
property summaryNotesGroup : "Summary Notes" -- Switch this to the name of the folder/group you'll use to store summary notes when they're first created. Must be a unique name.
property summaryNotePrefix : " " -- You can add a prefix here to indicate summary notes. If you don't want to use a prefix, use "".


tell application id "DNtp"
	set theSelection to get the selection
	set selectedRecord to the first item of theSelection
	set theDatabase to selectedRecord's database
	if selectedRecord's annotation exists then
		display dialog "This file already has an annotation note. Continuing will replace its contents."
	end if
	set recordUUID to selectedRecord's uuid
	set annotationNoteName to summaryNotePrefix & selectedRecord's name without extension
	set summaryNotesGroup to the first item of (lookup records with file summaryNotesGroup in get database with uuid databaseUUID)
	
	set highlightsSummary to summarize highlights of records theSelection to markdown in summaryNotesGroup
	
	
	if highlightsSummary is not missing value then -- highlights were successfully summarized, now we have to clean the resulting syntax
		set highlightsSummaryText to plain text of highlightsSummary
		set highlightsSummaryText to my replaceText(highlightsSummaryText, "* {==", "- > ")
		set highlightsSummaryText to my replaceText(highlightsSummaryText, return & "* ", return & "- ")
		set highlightsSummaryText to my replaceText(highlightsSummaryText, "==}", "" & return)
		set highlightsSummaryText to my replaceText(highlightsSummaryText, "\\", "")
		set plain text of highlightsSummary to highlightsSummaryText
		set name of highlightsSummary to annotationNoteName
	else -- if there were no annotations in the doc, the `summarize highlights of` action above won't result in a file, so we need to generate a blank annotation instead.
		set highlightsSummaryText to "# [" & selectedRecord's name & ".pdf](" & selectedRecord's reference URL & ")"
		set highlightsSummary to create record with {type:markdown, name:annotationNoteName, content:highlightsSummaryText} in summaryNotesGroup
	end if
	
	-- make the newly created summary note the original record's annotation
	set selectedRecord's annotation to highlightsSummary
	
	
end tell

on replaceText(this_text, search_string, replacement_string)
	set prevTIDs to AppleScript's text item delimiters
	set AppleScript's text item delimiters to the search_string
	set the item_list to every text item of this_text
	set AppleScript's text item delimiters to the replacement_string
	set this_text to the item_list as string
	set AppleScript's text item delimiters to prevTIDs
	return this_text
end replaceText
