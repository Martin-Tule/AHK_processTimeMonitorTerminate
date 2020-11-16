; answer to gkimsey at https://gaming.stackexchange.com/questions/74554/can-i-enforce-a-time-limit-window-on-steam-games-notably-team-fortress-2
; V1.1 - terminates one given process based on used time.
; Ideas for future variants:
; V1.2 - adds termination based on computer time
; V2.0 - adds watch for multiple programs
; V3.0 - catch user input upon process start
; V4.0 - add security features for user input (injection etc.)

;Data structures to store data (internal; not saved between runs - do this later)
; - timeSet := {Integer} stores runtime in minutes.
; - timeSetHours := convert this to timeSetMin if set.
; - timeUsed := runtime for program in minutes.

; ADMIN ENTER VALUE HERE, -1 MEANS NOT SET, ONLY SET ONE OF timeSet OR timeSetHours.
timeSet := 2
timeSetHours := -1
program2watch := "steam.exe"
; END OF ADMIN INPUT VARIABLES.

; Sets program time values
timeUsed := 0
if (timeSetHours != -1 && timeSet == -1){
	timeSet := timeSetHours*60
}

; check if program is active:
; cred: https://autohotkey.com/board/topic/33659-if-program-is-not-running-then-start/
programActiveCheck(process_name){
	; debug code here:
	;msgbox fromprogramActiveCheck program2watch- %process_name%
	Process, Exist, %process_name% ; check to see if e.g. Printkey.exe, is running
	If (ErrorLevel = 0) ; 0 = it is not running
		{
		; debug code here:
		;msgbox Program %process_name% with p_id process was not running.
		
		return ErrorLevel
	}
	Else ; If it is running, ErrorLevel equals the process id for the target program (Printkey). Then close it.
		{
		; debug code here
		;msgbox Program %process_name% with p_id process %ErrorLevel% is running
		
		return ErrorLevel
	}
}


; kill program:
killProcess(process_id){
	Process, Close, %process_id%
	; debug code here:
	;msgbox Killed process %ErrorLevel%
}


; infiLoop1MinCheck
; infinite loop w. wait (1 min)
; IF program in array is running => add 1 to timeUsed.
; IF timeSet >= timeUsed => terminate program and display message.
infiLoop1MinCheck(program2watch, timeUsed, timeSet){
	; debug code here:
	;msgbox frominfiLoop1MinCheck program2watch- %program2watch% -timeUsed- %timeUsed% -timeSet- %timeSet%
	while (timeSet != -1){
		Sleep, 60000		; sleep for one minute.
		processActivity := programActiveCheck(program2watch)
		if (processActivity != 0){
		; add one minute to counter.
			timeUsed++
			;msgbox used time is %timeUsed%
			if (timeUsed >= timeSet){
				; program is running and time budget exceeded:
				killProcess(processActivity)
				msgbox your time budget for program %program2watch% has exceed it's limit of %timeSet% minutes
			}
		}
	}
}

; MAIN:
main(program2watch, timeUsed, timeSet){
	; debug code here:
	;msgbox fromMAIN program2watch- %program2watch% -timeUsed- %timeUsed% -timeSet- %timeSet%
	infiLoop1MinCheck(program2watch, timeUsed, timeSet)
}

; Run program
main(program2watch, timeUsed, timeSet)


;Possble expansions:
; A:
; - set time exclusion => Add this to loopcheck (viz. IF time=X and program=Y; terminate program)
; B:
; - have the same script work for different programs, have list of instances of class 'ProgramTime' which have program name and timelimit and ...
; - ... prohibited time and counter.
; C:
; - store time usage on computer, set date first, import this file, replace null value of program if todays timestamp already exists with time in file.
; ... otherwise add new row to file with timestamp and zero value. Write to this file and read from this file for every check in oneMinuteInfiniteLoop. 
; ... by doing it every loop iteration we ensure functionality even if program is killed (only one minute will be lost).