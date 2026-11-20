vim.cmd([[
:function! ReplaceCharInLine(replacee,replacer)
:	let line = getline('.')
:	let s:newLine = ""
:	for s:l in line
:		let s:newLine = (s:l =~ a:replacee) ?  s:newLine . a:replacer : s:newLine . s:l 
:	endfor
:	call setline('.',s:newLine)
:endfunction
]])
vim.cmd([[
:function! GetCharAtPos(pos)
:	return getregion(a:pos, a:pos)[0]
:endfunction
]])
vim.cmd([[
:function! GetCharAtCursor()
:	return GetCharAtPos(getpos('.'))
:endfunction
]])
vim.cmd([==[
:function! GetLeftWordRegion()
:	let cursorPos = getpos('.')
:	let cursorChar = getregion(cursorPos, cursorPos)
:	let stop = cursorPos
:	let c = GetCharAtPos(stop)
:	while(charclass(c) == 2)
:		if(stop[2] == col('$'))
:			return [[-1,-1,-1,-1],[-1,-1,-1,-1]]
:		endif
:		let stop[2] = stop[2] + 1
:		let c = GetCharAtPos(stop)
:	endwhile
:	while (charclass(c) != 2)
:		if(stop[2] == 1)
:			return [[-1,-1,-1,-1],[-1,-1,-1,-1]]
:		endif
:		let stop[2] = stop[2] - 1
:		let c = GetCharAtPos(stop)
:	endwhile
:	if(stop[2] != 1 && charclass(c) != 2)
:		let stop[2] = stop[2] - 1
:	endif
:	let start = [stop[0],stop[1],stop[2],stop[3]]
:	let start[2] = (start[2] == 1) ? 1 : start[2] - 1 
:	let s = GetCharAtPos(start)
:	while(charclass(s) == 2)
:		if(start[2] == 1)
:			break
:		endif
:		let start[2] = start[2] - 1
:		let s = GetCharAtPos(start)
:	endwhile
:	let start[2] = (start[2] == stop[2] || start[2] == 1) ? start[2] : start[2] + 1
:	return [start, stop]
:endfunction
]==])
vim.cmd([==[
:function! GetRightWordRegion()
:	let cursorPos = getpos('.')
:	let cursorChar = getregion(cursorPos, cursorPos)
:	let start = cursorPos
:	let c = GetCharAtPos(start)
:	while(charclass(c) == 2)
:		if(start[2] == col('$'))
:			return [[-1,-1,-1,-1],[-1,-1,-1,-1]]
:		endif
:		let start[2] = start[2] + 1
:		let c = GetCharAtPos(start)
:	endwhile
:	while ( charclass(c) != 2 )
:		if(start[2] == col('$'))
:			return [[-1,-1,-1,-1],[-1,-1,-1,-1]]
:		endif
:		let start[2] = start[2] + 1
:		let c = GetCharAtPos(start)
:	endwhile
:	if(start[2] != col('$') && charclass(c) != 2)
:		let start[2] = start[2] + 1
:	endif
:	let stop = [start[0],start[1],start[2],start[3]]
:	let stop[2] = (stop[2] == col('$')) ? col('$') : stop[2] + 1 
:	let s = GetCharAtPos(stop)
:	while(charclass(s) == 2)
:		if(stop[2] == 1)
:			break
:		endif
:		let stop[2] = stop[2] + 1
:		let s = GetCharAtPos(stop)
:	endwhile
:	let stop[2] = (stop[2] == start[2]) ? stop[2] : stop[2] - 1
:	return [start, stop]
:endfunction
]==])
vim.cmd([==[
:function! GetMiddleWordRegion()
:let right = GetRightWordRegion()
:if	right[0][0] == -1
:	return [[-1,-1,-1,-1],[-1,-1,-1,-1]]
:endif
:let left = GetLeftWordRegion()
:if	left[0][0] == -1
:	return [[-1,-1,-1,-1],[-1,-1,-1,-1]]
:endif
:let start = [left[1][0], left[1][1], left[1][2] + 1, left[1][3]]
:let end = [right[0][0], right[0][1], right[0][2] - 1, right[0][3]]
:return [start, end]
:endfunction
]==])
vim.cmd([==[
:function! GetLeftWord()
:let left = GetLeftWordRegion()
:if left[0][0] == -1
:	return ''
:endif
:return getregion(left[0],left[1])[0]
:endfunction
]==])
vim.cmd([==[
:function! GetRightWord()
:let right = GetRightWordRegion()
:if right[0][0] == -1
:	return ''
:endif
:return getregion(right[0],right[1])[0]
:endfunction
]==])
vim.cmd([==[
:function! GetMiddleWord()
:let middle = GetMiddleWordRegion()
:if middle[0][0] == -1
:	return ''
:endif
:return getregion(middle[0],middle[1])[0]
:endfunction
]==])
vim.cmd([==[
:function! GetInvalidPos()
:return [-1,-1,-1,-1]
:endfunction
]==])
vim.cmd([==[
:function! GetSwappedWordsLine()
:let left = GetLeftWordRegion()
:let middle = GetMiddleWordRegion()
:let right = GetRightWordRegion()
:let leftWord = 	GetLeftWord()
:let middleWord = 	GetMiddleWord()
:let rightWord = 	GetRightWord()
:if middle[0][0] == -1 || right[0][0] == -1 || left[0][0] == -1
:	return ['',GetInvalidPos(),GetInvalidPos(),GetInvalidPos(),GetInvalidPos(),GetInvalidPos(),GetInvalidPos(),GetInvalidPos(),GetInvalidPos(),GetInvalidPos(),GetInvalidPos()]
:endif
:let swappedWords = rightWord .. middleWord .. leftWord
:let linestart = [left[0][0],left[0][1], 1, left[0][3]]
:let lineend = [left[0][0],left[0][1], col('$'), left[0][3]]
:let leftLeft = ''
:let leftline = ''
:if left[0][2] != 1
	:let leftLeft = [left[0][0],left[0][1], left[0][2]-1, left[0][3]]
	:let leftline = getregion(linestart, leftLeft)[0]
:endif
:let rightRight = [right[1][0],right[1][1], right[1][2]+1, right[1][3]]
:let rightline = getregion(rightRight, lineend)[0]
:return [leftline .. swappedWords .. rightline,linestart,leftLeft,left[0],left[1],middle[0],middle[1],right[0],right[1],rightRight,lineend]
:endfunction
]==])
vim.cmd([==[
:function! SwapWords(pos=9)
:let newLine = GetSwappedWordsLine()
:if newLine[1][0] == -1
:	let left = GetLeftWordRegion()
:	if ((left[0][2]) - 1 >= 1)
:		call setpos('.', [left[0][0],left[0][1],left[0][2]-1,left[0][3]])
:		echo "SETTING IT!"
:	endif
:	let newLine = GetSwappedWordsLine()
:endif
:if newLine[1][0] == -1
:	echo "Can't do swap!"
:	return
:endif
:call setline('.',newLine[0])
:call setpos('.',newLine[a:pos])
endfunction
]==])
vim.keymap.set({'i','n'}, '<leader>,', function() vim.fn.SwapWords() end)
vim.cmd([==[
function! Openings()
	return {'[': 0,'(': 0,'<': 0}
endfunction
]==])
vim.cmd([==[
function! Closings()
	return {']': 0,')': 0,'>': 0}
endfunction
]==])
vim.cmd([==[
function! OpeningsToClosings()
	return {'[': ']','(': ')','<': '>'}
endfunction
]==])
vim.cmd([==[
function! ClosingsToOpenings()
	return {']': '[',')': '(','>': '<'}
endfunction
]==])
vim.cmd([==[
function! FindPairedClosing(line, col)
	let col = a:col
	let line = a:line
	let key = line[col]
	let closings = Closings()
	let openings = Openings()
	let openingsToClosings = OpeningsToClosings()
	let closingsToOpenings = ClosingsToOpenings()
	if !has_key(openings, key)
		echo "Not a opening!!!"
		return - 1
	endif
	let openings[key] += 1
	let closingKey = openingsToClosings[key]
	while(col < strcharlen(line) && openings[key] > closings[closingKey]) " Find openings
		let col = col + 1
		let character = line[col]
		if character == key
			let openings[key] += 1
		endif
		if character == closingKey " Found closing
			let closings[closingKey] += 1
		endif
	endwhile
	if closings[closingKey] < openings[key]
		echo "No opener found corresponding to closing"
		return -1
	endif
	return col
endfunction
]==])
vim.cmd([==[
function! FindPairedOpening(line, col)
	let col = a:col
	let line = a:line
	let key = line[col]
	let closings = Closings()
	let openings = Openings()
	let openingsToClosings = OpeningsToClosings()
	let closingsToOpenings = ClosingsToOpenings()
	if !has_key(closings, key)
		echo "Not a closing!!!"
		return - 1
	endif
	let closings[key] += 1
	let openingKey = closingsToOpenings[key]
	while(col > 0 && closings[key] > openings[openingKey]) " Find openings
		let col = col - 1
		let character = line[col]
		if character == openingKey
			let openings[openingKey] += 1
		endif
		if character == key " Found closing
			let closings[key] += 1
		endif
	endwhile
	if closings[key] > openings[openingKey]
		echo "No opener found corresponding to closing"
		return -1
	endif
	return col
endfunction
]==])
vim.cmd([==[
"l - letters/numbers
"o - openings
"c - closings
"e - everything else
"a - anything
"<l>[o]{a}[c]{e}<l>[o]{a}[c]
function! GetTermColRegion(line, col)
	let cursor_start_pos = a:col
	let closings = Closings()
	let openings = Openings()
	let closingsToOpenings = ClosingsToOpenings()
	let openingsToClosings = OpeningsToClosings()
	let line = a:line
	let startCol = cursor_start_pos
	let col = startCol
	let c = line[col]
	let hasLetters = 0
	while(1) " Find out whether has letters
		let c = line[col]
		if has_key(openings, c) " Found opening
			let key = c
			if col == 0 || charclass(line[col-1]) != 2 " No letter before opening
				let hasLetters = 0
				let openings[key] = 1
			else " Letter before opening
				let hasLetters = 1
				let col = col - 1
			endif
			break
		elseif has_key(closings, c) " Found closing
			let col = FindPairedOpening(line, col)
			if col == -1
				echo "No opening found"
				return [-1,-1]
			endif
		elseif charclass(line[col]) == 2 " Found letter
			let hasLetters = 1
			break
		elseif(col <= 0)
			echo "No legal characters found"
			return [-1,-1]
		else
			let col = col - 1
		endif
	endwhile
	let hasOpening = 0
	let lettersStart = col
	let lettersEnd = col
	if hasLetters
		while(lettersStart > 0 && charclass(line[lettersStart]) == 2) "Find start of letter sequence
			let lettersStart = lettersStart - 1
		endwhile
		if(charclass(line[lettersStart]) != 2)
			let lettersStart += 1
		endif
		while(lettersEnd < strcharlen(line) && charclass(line[lettersEnd]) == 2)
			let lettersEnd += 1
		endwhile
		if(charclass(line[lettersEnd]) != 2)
			let lettersEnd -= 1
		endif
		let openingCol = col
		while(openingCol < strcharlen(line) - 1 && charclass(line[openingCol]) == 2)
			let openingCol += 1
			if has_key(openings, line[openingCol])
				let hasOpening = 1
				break
			endif
		endwhile
	else
		let hasOpening = 1
		let openingCol = col
		let lettersStart = col
		let lettersEnd = col
	endif
	if hasOpening
		let closingCol = FindPairedClosing(line, openingCol)
		if closingCol == -1
			echo "ERROR"
			return [-1,-1]
		endif
	else
		let openingCol = lettersStart
		let closingCol = lettersEnd
	endif
	return [lettersStart, closingCol]
endfunction
]==])
vim.cmd([==[
function! GetNextTermRegion(line, col)
	let termRegion = GetTermColRegion(a:line, a:col)
	let line = a:line
	let endIt = termRegion[1] + 1
	echo endIt
	while endIt < strcharlen(line) && charclass(line[endIt]) != 2 && !has_key(Openings(), line[endIt]) && !has_key(Closings(), line[endIt])
		let endIt += 1
	endwhile
	if (endIt >= strcharlen(line) || (charclass(line[endIt]) != 2 && !has_key(Openings(), line[endIt])))
		return [-1, -1]
	endif
	echo endIt
	return GetTermColRegion(line, endIt)
endfunction
]==])
vim.cmd([==[
function! GetPrevTermRegion(line, col)
	let termRegion = GetTermColRegion(a:line, a:col)
	let line = a:line
	let startIt = termRegion[0] - 1
	echo startIt
	while startIt > 0 && charclass(line[startIt]) != 2 && !has_key(Openings(), line[startIt]) && !has_key(Closings(), line[startIt])
		let startIt -= 1
	endwhile
	if (startIt < 0 || (charclass(line[startIt]) != 2 && !has_key(Closings(), line[startIt])))
		echo line[startIt]
		echo "FAILURE!"
		return [-1, -1]
	endif
	echo startIt
	return GetTermColRegion(line, startIt)
endfunction
]==])
vim.cmd([==[
function! SwapTerms()
	let col = col('.') - 1
	let line = getline('.')
	echo line
	let termRegion = GetTermColRegion (line, col)
	let nextRegion = GetNextTermRegion(line, col)
	echo nextRegion
	if nextRegion[0] == -1
		let termRegion = GetPrevTermRegion(line, col)
		let nextRegion = GetTermColRegion(line, col)
	endif
	if nextRegion[0] == -1 || termRegion[0] == -1
		echo "ERROR: Can't Swap Terms!"
		return -1
	endif
	let middleRegion = [termRegion[1] + 1, nextRegion[0] - 1]
	let term = slice(line,termRegion[0],termRegion[1]+1)
	echo term
	let nextTerm = slice(line,nextRegion[0],nextRegion[1]+1)
	echo nextTerm
	let middleTerm = slice(line,middleRegion[0], middleRegion[1]+1)
	echo middleTerm
	let lineStart = 0
	let lineEnd = strcharlen(line) - 1
	let startPart = [lineStart, termRegion[0] - 1]
	let endPart = [nextRegion[1] + 1, lineEnd]
	let newline = ''
	echo newline
	if lineStart != termRegion[0]
		let newline = newline .. slice(line, startPart[0], startPart[1]+1)
		echo newline
	endif
	let newline = newline .. nextTerm .. middleTerm .. term
	echo newline
	if lineEnd != nextRegion[1]
		let newline = newline .. slice(line, endPart[0], endPart[1]+1)
		echo newline
	endif
	echo newline
	call setline('.',newline)
	let position = getpos('.')
	let newPosition = position
	let newPosition[2] = endPart[0]
	call setpos('.', newPosition)
	return 1
endfunction
]==])
vim.keymap.set({'i','n'}, '<leader>.', function() vim.fn.SwapTerms() end)
