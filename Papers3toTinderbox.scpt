-- Escreve em um arquivo de texto, criando ou anexando.
on write_to_file(this_data, target_file, append_data) -- (string, file path as string, boolean) 
	try
		set the target_file to the target_file as text
		set the open_target_file to ¬
			open for access file target_file with write permission
		if append_data is false then ¬
			set eof of the open_target_file to 0
		write this_data to the open_target_file starting at eof
		close access the open_target_file
		return true
	on error
		try
			close access file target_file
		end try
		return false
	end try
end write_to_file

on theSplit(theDelimiter, theString)
	-- save delimiters to restore old settings
	set oldDelimiters to AppleScript's text item delimiters
	-- set delimiters to delimiter to be used
	set AppleScript's text item delimiters to theDelimiter
	-- create the array
	set theArray to every text item of theString
	-- restore the old setting
	set AppleScript's text item delimiters to oldDelimiters
	-- return the result
	return theArray
end theSplit

global bookList
global paperList
global perList
global webList
global keyValuePair
global colorCode
global initID
global verifica
global this_file
global propVer
global dataProc


on replace_chars(this_text, search_string, replacement_string)
	set AppleScript's text item delimiters to the search_string
	set the item_list to every text item of this_text
	set AppleScript's text item delimiters to the replacement_string
	set this_text to the item_list as string
	set AppleScript's text item delimiters to ""
	return this_text
end replace_chars


set bookList to {}
set paperList to {}
set webList to {}
set keyValuePair to {}
set initID to 300
set tinderID to 0

set colorCode to {"#FFFFFF", "#FF2100", "#FF8100", "#FFCA00", "#009aff", "#60a150"}

on write_note(note_id, note_items, texto, proto, target_file)
	set initial to "<item ID=" & character id 34 & note_id & character id 34 & " Creator=" & character id 34 & "SPY" & character id 34
	if proto ≠ "" then
		set initial to initial & " proto=" & character id 34 & proto & character id 34
	end if
	set initial to initial & ">" & character id 13
	set attr to ""
	repeat with dados in note_items
		set vari to item 2 of dados
		if vari is equal to missing value then
			set vari to ""
		end if
		set propVer to item 1 of dados
		set oDado to my replace_chars(vari as string, "&", "&amp;")
		set attr to attr & "<attribute name=" & character id 34 & item 1 of dados & character id 34 & ">" & oDado & "</attribute>" & character id 13
	end repeat
	set repAnd to my replace_chars(texto as string, "&", "&amp;")
	set repGT to my replace_chars(repAnd, ">", "&gt;")
	set repLT to my replace_chars(repGT, "<", "&lt;")
	set otexto to "<text>" & repLT & "</text>" & character id 13
	set note_data to initial & attr & otexto
	my write_to_file(note_data, target_file, true)
end write_note

on end_note(target_file)
	set endData to "</item>" & character id 13
	my write_to_file(endData, target_file, true)
end end_note

on write_paper(pubItem, target_file)
	set dataProc to pubItem
	tell application "Papers"
		set pubID to id of pubItem
		set tinderID to 0
		--Busca o ID pro Tinderbox
		repeat with i from 1 to count keyValuePair
			set pair to item i of keyValuePair
			if pair contains pubID then
				set tinderID to item 2 of pair
			end if
		end repeat
		set note_items to {}
		copy {"Authors", author names of pubItem} to end of note_items
		copy {"PublicationYear", publication year of pubItem} to end of note_items
		copy {"ArticleTitle", title of pubItem} to end of note_items
		copy {"Name", title of pubItem} to end of note_items
		copy {"Journal", bundle info of pubItem} to end of note_items
		copy {"DOI", doi of pubItem} to end of note_items
		copy {"Issue", issue of pubItem} to end of note_items
		copy {"Volume", bundle volume of pubItem} to end of note_items
		copy {"RefKeywords", keyword names of pubItem} to end of note_items
		if my rating of pubItem < 1 and flagged of pubItem then
			copy {"Color", "#D6D6D6"} to end of note_items
		else
			set dado to my rating of pubItem
			set dado to dado + 1
			copy {"Color", item dado of colorCode} to end of note_items
		end if
		my write_note(tinderID, note_items, abstract of pubItem, "Paper", target_file)
		my end_note(target_file)
	end tell
end write_paper

on write_book_chapter(pubChapter, target_file)
	set dataProc to pubChapter
	tell application "Papers"
		set pubID to id of pubChapter
		set tinderID to 0
		--Busca o ID pro Tinderbox
		repeat with i from 1 to count keyValuePair
			set pair to item i of keyValuePair
			if pair contains pubID then
				set tinderID to item 2 of pair
			end if
		end repeat
		set note_items to {}
		copy {"Authors", author names of pubChapter} to end of note_items
		copy {"BookTitle", title of pubChapter} to end of note_items
		copy {"Name", title of pubChapter} to end of note_items
		copy {"Pages", page range of pubChapter} to end of note_items
		if my rating of pubChapter < 1 and flagged of pubChapter then
			copy {"Color", "#D6D6D6"} to end of note_items
		else
			set dado to my rating of pubChapter
			set dado to dado + 1
			copy {"Color", item dado of colorCode} to end of note_items
		end if
		my write_note(tinderID, note_items, abstract of pubChapter, "Book Chapter", target_file)
		my end_note(target_file)
	end tell
	
end write_book_chapter

on write_book(pubBook, target_file)
	set dataProc to pubBook
	tell application "Papers"
		set pubID to id of pubBook
		set tinderID to 0
		--Busca o ID pro Tinderbox
		repeat with i from 1 to count keyValuePair
			set pair to item i of keyValuePair
			if pair contains pubID then
				set tinderID to item 2 of pair
			end if
		end repeat
		set note_items to {}
		copy {"Authors", author names of pubBook} to end of note_items
		copy {"PublicationYear", publication year of pubBook} to end of note_items
		copy {"PublicationCity", place of publication of pubBook} to end of note_items
		copy {"BookTitle", title of pubBook} to end of note_items
		copy {"Name", title of pubBook} to end of note_items
		set dados to {"1"}
		set verifica to short bundle info of pubBook
		if verifica contains "," then
			set dados to my theSplit(",", verifica)
		end if
		copy {"Edition", get last item of dados} to end of note_items
		copy {"DOI", doi of pubBook} to end of note_items
		copy {"Pages", page range of pubBook} to end of note_items
		copy {"Publisher", publisher name of pubBook} to end of note_items
		copy {"ISBN", isbn of pubBook} to end of note_items
		if my rating of pubBook < 1 and flagged of pubBook then
			copy {"Color", "#D6D6D6"} to end of note_items
		else
			set dado to my rating of pubBook
			set dado to dado + 1
			copy {"Color", item dado of colorCode} to end of note_items
		end if
		my write_note(tinderID, note_items, abstract of pubBook, "Book", target_file)
		-- Antes de fechar, processar os capítulos (se houver)
		repeat with chapter in every publication item of pubBook
			my write_book_chapter(chapter, target_file)
		end repeat
		my end_note(target_file)
	end tell
	
end write_book

on write_Site(pubSite, target_file)
	set dataProc to pubSite
	
	tell application "Papers"
		set pubID to id of pubItem
		set tinderID to 0
		--Busca o ID pro Tinderbox
		repeat with i from 1 to count keyValuePair
			set pair to item i of keyValuePair
			if pair contains pubID then
				set tinderID to item 2 of pair
			end if
		end repeat
		set note_items to {}
		copy {"ArticleTitle", title of pubSite} to end of note_items
		copy {"Name", title of pubSite} to end of note_items
		copy {"AccessDate", short date string of creation date of pubSite} to end of note_items
		copy {"ReferenceURL", doi of pubSite} to end of note_items
		if my rating of pubSite < 1 and flagged of pubSite then
			copy {"Color", "#D6D6D6"} to end of note_items
		else
			set dado to my rating of pubSite
			set dado to dado + 1
			copy {"Color", item dado of colorCode} to end of note_items
		end if
		my write_note(tinderID, note_items, abstract of pubSite, "Website", target_file)
		my end_note(target_file)
	end tell
end write_Site

on write_papers(target_file)
	tell application "Papers"
		set note_items to {}
		copy {"Name", "Papers"} to end of note_items
		
		my write_note(initID, note_items, "", "", target_file)
		set initID to initID + 1
		repeat with i from 1 to count paperList
			set pubItem to item i of paperList
			my write_paper(pubItem, target_file)
		end repeat
		my end_note(target_file)
	end tell
end write_papers

on write_books(target_file)
	tell application "Papers"
		-- para cada livro os publication-item sao os capitulos associados
		set note_items to {}
		copy {"Name", "Books"} to end of note_items
		my write_note(initID, note_items, "", "", target_file)
		set initID to initID + 1
		
		repeat with i from 1 to count bookList
			set bookItem to item i of bookList
			my write_book(bookItem, target_file)
		end repeat
		my end_note(target_file)
	end tell
end write_books

on write_webpages(target_file)
	tell application "Papers"
		set note_items to {}
		copy {"Name", "Web Pages"} to end of note_items
		my write_note(initID, note_items, "", "", target_file)
		set initID to initID + 1
		
		-- para cada livro os publication-item sao os capitulos associados
		repeat with i from 1 to count bookList
			set bookItem to item i of bookList
			my write_book(bookItem, target_file)
		end repeat
		my end_note(target_file)
	end tell
end write_webpages

on write_references(target_file)
	tell application "Papers"
		--Escreve os papers, os books e os websites
		set key_items to {}
		copy {"Name", "References"} to end of key_items
		my write_note(initID, key_items, "", "", target_file)
		set initID to initID + 1
		
		my write_papers(target_file)
		my write_books(target_file)
		my write_webpages(target_file)
		my write_keywords(keyValuePair, target_file)
		
		my end_note(target_file)
		
	end tell
end write_references

on write_keywords(keyValuePair, target_file)
	tell application "Papers"
		--Escreve os keywords e os artigos dos keywords como alias (ja escritos... )
		set keyList to every keyword item
		set keyw_items to {}
		copy {"Name", "Keywords"} to end of keyw_items
		my write_note(initID, keyw_items, "", "", target_file)
		set initID to initID + 1
		repeat with i from 1 to count of keyList
			set keyItem to item i of keyList
			-- Escreve os dados da Keyword
			set key_items to {}
			copy {"Name", name of keyItem} to end of key_items
			my write_note(initID, key_items, "", "", target_file)
			set initID to initID + 1
			
			set pubKeys to every publication item of keyItem
			repeat with j from 1 to count of pubKeys
				set thePubAlias to item j of pubKeys
				repeat with k from 1 to count keyValuePair
					set pair to item k of keyValuePair
					if pair contains id of thePubAlias then
						-- Escreve os dados do Alias.
						set note_items to {}
						copy {"Alias", item 2 of pair} to end of note_items
						my write_note(initID, note_items, "", "", target_file)
						set initID to initID + 1
						my end_note(target_file)
					end if
				end repeat
			end repeat
			my end_note(target_file)
		end repeat
		my end_note(target_file)
	end tell
end write_keywords

on write_authors(keyValuePair, target_file)
	tell application "Papers"
		--Escreve os keywords e os artigos dos keywords como alias (ja escritos... )
		set perList to every person item
		set aut_items to {}
		copy {"Name", "Authors"} to end of aut_items
		my write_note(initID, aut_items, "", "", target_file)
		set initID to initID + 1
		repeat with i from 1 to count of perList
			set perItem to item i of perList
			-- Escreve os dados da Keyword
			set per_items to {}
			copy {"Name", standard name of perItem} to end of per_items
			my write_note(initID, per_items, preferred name of perItem, "Author", target_file)
			set initID to initID + 1
			
			set pubKeys to every publication item of perItem
			repeat with j from 1 to count of pubKeys
				set thePubAlias to item j of pubKeys
				repeat with k from 1 to count keyValuePair
					set pair to item k of keyValuePair
					if pair contains id of thePubAlias then
						-- Escreve os dados do Alias.
						set note_items to {}
						copy {"Alias", item 2 of pair} to end of note_items
						my write_note(initID, note_items, "", "", target_file)
						set initID to initID + 1
						my end_note(target_file)
					end if
				end repeat
			end repeat
			my end_note(target_file)
		end repeat
		my end_note(target_file)
	end tell
end write_authors


display dialog "Initiating Process"& character id 13 & "Created by: Rodrigo de Godoy Domingues" & character id 13 & "e-mail: rodrigod@hiperlogic.com.br" & character id 13 & "Uberlândia - MG - BR, December, 4th - 2015"
tell application "Papers"
	set pubList to every publication item
	set perList to every person item
	--	set keywordList to every keyword item
	repeat with i from 1 to count of pubList
		set id_ref to {}
		set aPub to item i of pubList
		copy id of aPub to end of id_ref
		copy initID to end of id_ref
		copy id_ref to end of keyValuePair
		if resource type of aPub contains "Book" or resource type of aPub contains "Thesis" then
			if resource type of aPub contains "Chapter" then
				--nao faz nada. Ha os capitulos associados aos livros.
			else
				copy aPub to end of bookList
			end if
		else
			if resource type of aPub contains "website" then
				copy aPub to end of webList
			else
				copy aPub to end of paperList
			end if
		end if
		set initID to initID + 1
	end repeat
	set this_file to (((path to desktop folder) as text) & "referencias.xml")
	my write_references(this_file)
end tell
tell application "Papers"
	
	my write_authors(keyValuePair, this_file)
end tell
display dialog "Process Concluded"& character id 13 & "Created by: Rodrigo de Godoy Domingues" & character id 13 & "e-mail: rodrigod@hiperlogic.com.br" & character id 13 & "Uberlândia - MG - BR, December, 4th - 2015"
