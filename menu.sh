#!/bin/bash
######################################################################################
#                  Copyright (C) 2018 </code.ab>
#
# Script name	: menu.sh
# Run as		: ./menu.sh or menu.sh
#
# Description	:This script is used to display 6D applications menu.
#                The applications list will be read from the menu-config.conf file.
#
# Author		:Adarsh RS, Arun Binoy
# Platform		:RHEL 6 compiled.
#
# Date			:01/03/2018
######################################################################################
#About Menu
scriptVersion="2.0.1"
scriptModifyDate="26/05/2019"
scriptModifiedby="Arun Binoy"
##########################################################
################ SCRIPT  START  HERE #####################
##########################################################
#Reloading .bash_profile.
. $(find ~/ -maxdepth 1 -type f -name '.bash_profile')
## Absolute dir of this script
abScriptName=$(readlink -f "$0")
scriptName=$(basename "${abScriptName}")
scriptDir=$(dirname "${abScriptName}")
########################################################
################ DEFINE OF FUNCTION ####################
########################################################
#Lib Loading Function
function get_lib()
{
  local fileLib=${1}
    if [ -f ${fileLib} ] && [ -s ${fileLib} ]
			then
					source ${fileLib} 2>/dev/null;
			else
					echo -e "Error:Cannot initialize ${scriptName}, lib:${fileLib} is empty/missing"
					exit 0
    	fi
}

#Double Verification Process
function double_confirm()
{
	local functnID=${1}
	local secApp=${2}
	local appName=${3}
	local interVar=${4}
	local dblConfmntnMesg=${5}
	local feature=${6}
	write_header 0
	write_header "${appName}"
	echo -e "${green}Confirmation:${default}"
	echo -e "\t${dblConfmntnMesg}"
	echo
	printf "%2d. %s\n" "1" "Confirm"
	printf "%2d. %s\n" "0" "${green}Back${default}"
	echo -e "\n${footerMsg}"
	echo "-----------------------"
	printf  " Choose Option${green}[0-1]${default}:"
	sleep 2
	read dblConfmtn
	wait
	if [[ ${dblConfmtn} == 0 ]]
		then
			log_it "6" "[I] [${LINENO}] Input received as ${dblConfmtn}, Going back to sub menu ${secApp} section."
			footer_mesg "0" "Opted to Cancel ${feature}."
	elif [[ ${dblConfmtn} == 1 ]]
		then
			if [ ${functnID} -eq 1 ]
				then
					log_it "6" "[I] [${LINENO}] Input Received for ${dblConfmtn},Proceeding to ${feature}, Mode:Script(${functnID}), Script Name:${interVar}, appNamee:${appName}, Section:${secApp}"
					script_execute ${appName} ${interVar} "${feature}" 0 0
			elif [ ${functnID} -eq 2 ]
				then
					log_it "6" "[I] [${LINENO}] Input Received for ${dblConfmtn},Proceeding to ${feature}, Mode:View Logs(${functnID}), Type:${interVar}, appNamee:${appName}, Section:${secApp}"
					log_details ${secApp} ${appName} ${interVar} 1 
			elif [ ${functnID} -eq 3 ]
				then
					log_it "6" "[I] [${LINENO}] Input Received for ${dblConfmtn},Proceeding to ${feature}, Mode:Kill PID(${functnID}), PID:${interVar}, appNamee:${appName}, Section:${secApp}"
					app_kill "${secApp}" "${appName}" "${interVar}"
			elif [ ${functnID} -eq 4 ]
				then
					log_it "6" "[I] [${LINENO}] Input Received for ${dblConfmtn},Proceeding to ${feature}, Mode:Tail Logs(${functnID}), Type:${interVar}, appNamee:${appName}, Section:${secApp}"
					script_execute  ${appName} ${interVar} "${feature}" 0 0
			elif [ ${functnID} -eq 5 ]
				then
					log_it "6" "[I] [${LINENO}] Input Received for ${dblConfmtn},Proceeding to ${feature}, Mode:Task Script(${functnID}), Type:${interVar}, appNamee:${appName}, Section:${secApp}"
					log_details ${secApp} ${appName} ${interVar} 2		
				else
					log_it "4" "[W] [${LINENO}] Input Received for ${dblConfmtn}, Unknown Mode value ${functnID}, Going back to sub_menu ${secApp}"
					footer_mesg 2 "${red} Internal error occurred. ${default}"
			fi
		else
			log_it "4" "[W] [${LINENO}] Input Received for ${dblConfmtn}, unknown value , Going back to sub_menu ${secApp}"
			footer_mesg 2 "Invalid option selected. Please re-select"
			double_confirm "${functnID}" "${secApp}" "${appName}" "${interVar}" "${dblConfmntnMesg}" "${feature}"
	fi
}
#Task Control
function task_control()
{
	noofTaskids=$(sed -nr "/^\[TASK\]/ { :l /^no_of_task[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" ${configFile})
	[ -z ${noofTaskids} ] && noofTaskids="0"
	log_it "6" "[I] [${LINENO}] Received request for task Control no of task:${noofTaskids}"
	if [ ${noofTaskids} -gt 0 ]
	then 
		write_header 0
		write_header "TASK"
		for (( tid=1;tid<=${noofTaskids};tid++ ))
			do 
				taskname=$(sed -nr "/^\[TASK\]/ { :l /^script${tid}[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" ${configFile}| awk -F '|' '{print $1}')
				[ -z ${taskname} ] && taskname="Invalid Config"
				taskscript=$(sed -nr "/^\[TASK\]/ { :l /^script${tid}[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" ${configFile}| awk -F '|' '{print $2}')
				[ -z ${taskscript} ] && taskscript="Invalid"
				log_it "6" "[I] [${LINENO}] Received request for task Control No of Task:${noofTaskids}, ${tid}-${taskname}-${taskscript}"
				print_menu "${tid}" "${taskname}" "${taskscript}"
			done
			printf "%2d. %s\n" "0" "${green}Back${default}" 
			echo -e "\n${footerMsg}"
			echo " ----------------------"
			printf " Choose Option ${green}[0-${tid}]${default}:"
			read taskmenuinpt
			if [[ ${taskmenuinpt} == 0 ]]
				then 
					unset footerMsg
					log_it "6" "[I][${LINENO}] ${taskmenuinpt} Input received to Back to Main Menu - Task Control"
			elif [[ "$taskmenuinpt" == *[[:digit:]]* && $taskmenuinpt -ge 0 && $taskmenuinpt -lt ${tid} ]]
				then 
					taskname=$(sed -nr "/^\[TASK\]/ { :l /^script${taskmenuinpt}[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" ${configFile}| awk -F '|' '{print $1}')
					[ -z ${taskname} ] && taskname="0"
					taskscript=$(sed -nr "/^\[TASK\]/ { :l /^script${taskmenuinpt}[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" ${configFile}| awk -F '|' '{print $2}')
					[ -z ${taskscript} ] && taskscript="0"
					log_it "6" "[I] [${LINENO}] Received input ${taskmenuinpt} for task Control :${taskname}-${taskscript}"
					if [[ ${taskname} == 0 ]] || [[ ${taskscript} == 0 ]]
						then 
							footer_mesg "2" "Invalid Task Configuration"
							log_it "3" "[E] [${LINENO}] Invalid Task Configuration :${taskname}-${taskscript}"
						else
							double_confirm 4 TASK  "${taskname}" "${taskscript}" "Do you want to run task ${taskname}  \n ${yellow} sh ${taskscript}${default}" "Execute"
							log_it "6" "[I] [${LINENO}] Double Confirmation on :${taskname}-${taskscript}"
					fi 
					task_control
				else
					footer_mesg "1" "Invalid option selected. Please re-select"
					task_control
					log_it "4" "[W] [${LINENO}] Invalid input received- Task Control"
			fi
		else
			 footer_mesg "1" "No tasks are configured"
			 log_it "4" "[W] [${LINENO}] No tasks are configured- Task Control"
	fi 
}

function logs_menu()
{
	local secApp=${1}
	local appName=${2}
	local logpath=${3}
	write_header 0
	write_header "${appName}"
	echo -e "${green}Logs Options:${default}\n"
	printf "%2d. %s\n" "1" "View Log"
	printf "%2d. %s\n" "2" "Tail Log"
	printf "%2d. %s\n" "0" "${green}Back${default}"
	echo -e "\n${footerMsg}"
	echo " ----------------------"
	printf "Choose Option ${green}[0-2]${default}:"
	read inptlogsmenu
	if [[ ${inptlogsmenu} == 0 ]]
		then
			log_it "6" "[I] [${LINENO}] Input Received ${inptlogsmenu},Going to main_menu"
			unset footerMsg
			sub_menu ${secApp}
	elif [[ ${inptlogsmenu} == 1 ]]
		then
			unset footerMsg
			log_it "6" "[I] [${LINENO}] Input Received ${inptlogsmenu},Going to More Logs"
			log_details ${secApp} ${appName} ${logpath} 1
	elif [[ ${inptlogsmenu} == 2 ]]
	    then
			log_it "6" "[I] [${LINENO}] Input Received ${inptlogsmenu},Going to Tail Logs"
			unset footerMsg
			log_details ${secApp} ${appName} ${logpath} 2
		else
			unset footerMsg
			log_it "4" "[W] [${LINENO}] Input Received ${inptlogsmenu},Invalid Selection in Logs Menu"
			footer_mesg "1" "Invalid option selected. Please re-select"
			logs_menu ${secApp} ${appName} ${logpath} 
fi
}
function sub_menu()
{
	write_header 0
	local secApp=${1}
	local appName=$(var_parser ${secApp} | sed -n 's/^name=//p') 
	process_status ${secApp}  0
	log_it "6" "[I] [${LINENO}] Section:${secApp}, appNamee:${appName}, Status:${appStatus}, PID:${pidVal}"
	if [ ${appStatus} -eq 1 ]
		then
			write_header "${appName}"
			echo -e "${green}Info${default}"
			print_menu "0" "	Status" ": ${green}Running${default}"
			print_menu "0" "	PID" ": ${pidVal}"
			print_menu "0" "	User" ": ${menuUser}"
			print_menu "0" "	Mem" ":${memUsage}%"
			print_menu "0" "	CPU" ":${cpuUsage}%"
			print_menu "0" "	Uptime" ": ${uptimePid}"
			print_menu "0" "	Directory" ": ${dirrunning}"
			print_menu "0" "	Open Files" ": ${openFilesApp}"	
			echo
			printf "%2d. %s\n" "1" "Restart"
			printf "%2d. %s\n" "2" "Stop"
			printf "%2d. %s\n" "3" "Logs"
			printf "%2d. %s\n" "4" "Reload"
			printf "%2d. %s\n" "5" "Kill(Signal -9)"
			printf "%2d. %s\n" "0" "${green}Back${default}"
			echo -e "\n${footerMsg}"
			echo " ----------------------"
			printf " Choose Option ${green}[0-5]${default}:"
			read inputSubmenu
			if [[ ${inputSubmenu} == 0 ]]
				then
					log_it "6" "[I] [${LINENO}] Input Received ${inputSubmenu},Going to main_menu"
					unset footerMsg
			elif [[ ${inputSubmenu} == 1 ]] 
				then
					unset footerMsg
					restrtScrpt=$(var_parser ${secApp} | sed -n 's/^restart_script=//p')
					[ -z ${restrtScrpt} ] && restrtScrpt=0 
					if [[  ${restrtScrpt} != 0 ]]
						then
							log_it "6" "[I] [${LINENO}] Input Received ${inputSubmenu},Going to Restart Option"
							double_confirm 1 ${secApp} "${appName}" "${restrtScrpt}" "Do you want to restart ${appName} by executing\n ${yellow} sh ${restrtScrpt}${default}" "Restart"
							sub_menu ${secApp}
						else
							log_it "4" "[W] [${LINENO}] restrtScrpt not present in configuration file for ${secApp}"
							footer_mesg "2" "Restart feature is not enabled for ${appName}"
							sub_menu ${secApp}
					fi
			elif [[ ${inputSubmenu} == 2 ]]
				then
					unset footerMsg
					stopSrpt=$(var_parser ${secApp} | sed -n 's/^stop_script=//p') 
					[ -z ${stopSrpt} ] && stopSrpt=0 
					if [[  ${stopSrpt} != 0 ]]
						then
							log_it "6" "[I] [${LINENO}] Input Received ${inputSubmenu},Going to Stop Option"
							double_confirm 1 ${secApp} "${appName}" "${stopSrpt}" "Do you want to stop ${appName} by executing\n ${yellow} sh ${stopSrpt} ${default}" "Stop"
							sub_menu ${secApp}
						else
							log_it "4" "[W] [${LINENO}] stopSrpt not present in configuration file for ${secApp}"
							footer_mesg "2" "Stop feature is not enabled for ${appName}"
							sub_menu ${secApp}
					fi
			elif [[ ${inputSubmenu} == 3 ]]
				then
					unset footerMsg
					logpath=$(var_parser ${secApp} | sed -n 's/^log_dir=//p')
					[ -z ${logpath} ] && logpath=0 
					if [[  ${logpath} != 0 ]]
						then
							log_it "6" "[I] [${LINENO}] Input Received ${inputSubmenu},Going to Logs Option"
							logs_menu ${secApp} "${appName}" "${logpath}"
							sub_menu ${secApp}
						else
							log_it "3" "[E] [${LINENO}] log_dir not present in configuration file for ${secApp}"
							footer_mesg "2" "Logs feature is not enabled for ${appName}"
							sub_menu ${secApp}
					fi
			elif [[ ${inputSubmenu} == 4 ]]
				then
					unset footerMsg
					reloadSrpt=$(var_parser ${secApp} | sed -n 's/^reload_script=//p')
					[ -z ${reloadSrpt} ] && reloadSrpt=0 
					if [[  ${reloadSrpt} != 0 ]]
						then
							log_it "6" "[I] [${LINENO}] Input Received ${inputSubmenu},Going to Reload Option"
							double_confirm 1 ${secApp} "${appName}" "${reloadSrpt}" "Do you want to reload ${appName} by executing \n${yellow}  sh ${reloadSrpt} ${default}" "Reload"
							sub_menu ${secApp}
						else
							log_it "3" "[E] [${LINENO}] reloadSrpt not present in configuration file for ${secApp}"
							footer_mesg "2" "Reload feature is not enabled for ${appName}"
							sub_menu ${secApp}
					fi
			elif [[ ${inputSubmenu} == 5 ]] 
				then
					unset footerMsg
					log_it "6" "[I] [${LINENO}] Input Received ${inputSubmenu},Killing ${appName} PID:${pidVal}"
					double_confirm 3 ${secApp} "${appName}" "${pidVal}" "Do you want to Kill ${appName} by executing \n${yellow} kill -9 ${pidVal}${default}" "Kill"
					sub_menu ${secApp}
				else
					unset footerMsg
					log_it "4" "[W] [${LINENO}] Invalid Input Received ${inputSubmenu},sub_menu"
					footer_mesg "2" "Invalid option selected. Please re-select"
					sub_menu ${secApp}
			fi
	elif [[ ${appStatus} == 0 ]]
		then
			write_header "${appName}"
			echo -e "${green}Info${default}"
			print_menu "0" "	Status" ": ${yellow}Not Running${default}"
			echo
			printf "%2d. %s\n" "1" "Start"
			printf "%2d. %s\n" "2" "View Log"
			printf "%2d. %s\n" "0" "${green}Back${default}"
			echo -e "\n${footerMsg}"
			echo " ----------------------"
			printf " Choose Option ${green}[0-2]${default}:"
			wait
			read inputSubmenu
			if [[ ${inputSubmenu} == 0 ]]
				then
					log_it "6" "[I] [${LINENO}] Input Received ${inputSubmenu},Loading main_menu"
					unset footerMsg
			elif [[ ${inputSubmenu} == 1 ]]
				then
					unset footerMsg
					strtScrpt=$(var_parser ${secApp} | sed -n 's/^start_script=//p')
					[ -z ${strtScrpt} ] && strtScrpt=0 
					if [[  ${strtScrpt} != 0 ]]
						then
							log_it "6" "[I] [${LINENO}] Input Received ${inputSubmenu},Going to Start Option"
							double_confirm 1 ${secApp} "${appName}" "${strtScrpt}" "Do you want to start ${appName} by executing\n ${yellow}sh ${strtScrpt}${default}" "Start"
							sub_menu ${secApp}
						else
							log_it "4" "[W] [${LINENO}] strtScrpt not present in configuration file for ${secApp}"
							footer_mesg "2" "Start feature is not enabled for ${appName}"
							sub_menu ${secApp}
					fi

				elif [[ ${inputSubmenu} == 2 ]]
					then
						logpath=$(var_parser ${secApp} | sed -n 's/^log_dir=//p')
						[ -z ${logpath} ] && logpath=0 
						if [[  ${logpath} != 0 ]]
							then
								log_it "6" "[I] [${LINENO}] logpath  present for ${secApp}"
								double_confirm 2 ${secApp} "${appName}" "${logpath}" "Do you want to view ${appName} Logs" "View Logs"
								sub_menu ${secApp}
							else
							log_it "3" "[E] [${LINENO}] logpath not present in configuration file for ${secApp}"
							footer_mesg "2" "Logs feature is not enabled for ${appName}"
							sub_menu ${secApp}
						fi
					else
						log_it "4" "[W] [${LINENO}] invalid option selected ${inputSubmenu},sub_menu status-2"
						footer_mesg "2" "Invalid option selected. Please re-select"
						sub_menu ${secApp}
			fi
	elif [[ ${appStatus} == 2 ]]
		then 
			write_header "${appName}"
			echo -e "${green}Info${default}"
			print_menu "0" "	Error" ": ${yellow}Multiple Instances are Running${default}"
			log_it "4" "[W] [${LINENO}] Multiple instances are running PID Values:${pidVal}"
			echo -e "	PID Values:${pidVal}\n"
			pause
		else 
			write_header "MENU"
			echo -e "${green}Info${default}"
			print_menu "0" "	Error" ": ${red}Invalid Configuration${default}"
			log_it "4" "[W] [${LINENO}] Invalid Configurations found, Please set priper appID"
			echo
			pause
	fi
}

function main_menu()
{
	write_header 0
	write_header "MENU"
	awk -F '[' '{print $2}' ${configFile}| awk -F ']' '{print $1}' | grep ^[A-Za-z0-9] | grep -v "GLOBAL" | grep -v "MENU" | grep -v "TASK" | grep -v "SAMPLE" | sort | uniq > ${tmppath}/.apptemp
	countC=$(cat ${tmppath}/.apptemp | wc -l)
	[ -z ${countC} ] && countC=0
	log_it "6" "[I] [${LINENO}] No of section found in ${configFile} as ${countC},Reading each section, Available :$(cat ${tmppath}/.apptemp)."
	if [ ${countC} -gt 0 ]
		then
				for (( i=1; i<=${countC}; i++ ))
					do
						secApp=$(cat ${tmppath}/.apptemp | head -n ${i} | tail -1)
						local appName=$(var_parser ${secApp} | sed -n 's/^name=//p')
						[ -z ${appName} ] && appName="Name not Configured"
						process_status ${secApp} 1
						print_menu "${i}" "${appName}" "${msgStatus}"
						log_it "6" "[I] [${LINENO}] Printing menu to display  ${i}. ${appName} <${finwidth}> ${msgStatus}"
					done
	fi
	countI=$(( countC + 1 ))
	printf "%2d. %s\n" "${countI}" "Execute Task"
	countJ=$(( countI + 1 ))
	printf "%2d. %s\n" "${countJ}" "About Server"
	countK=$(( countJ + 1 ))
	printf "%2d. %s\n" "${countK}" "About Menu"
	countL=$(( countK + 1 ))
	printf "%2d. %s\n" "${countL}" "Refresh"
	printf "%2d. %s\n" "0" "${green}Exit${default}"
	echo -e "\n${footerMsg}"
	echo " ----------------------"
}
##########################################################
############### DEFINE VARIABLES HERE ####################
##########################################################
get_lib "${scriptDir}/libs/global_var"	
if [ -f ${configFile} ]  && [ -s ${configFile} ]
	then
		touch ${configFile}
		get_lib "${scriptDir}/libs/var_parser"	
		logDir=$(var_parser MENU | sed -n 's/^log_dir=//p')
		[ -z ${logDir} ] && logDir="${scriptDir}/logs"
		logPrefix=$(var_parser MENU | sed -n 's/^log_prefix=//p')
		[ -z ${logPrefix} ] && logPrefix="Menu"
		menuUser=$(var_parser MENU | sed -n 's/^menu_user=//p')
		[ -z ${menuUser} ] && menuUser="${USER}"
		logRotation=$(var_parser MENU | sed -n 's/^log_rotation=//p')
		[ -z ${logRotation} ] && logRotation="0"
		logLevel=$(var_parser MENU | sed -n 's/^log_level=//p')
		[ -z ${logLevel} ] && logLevel="0"
		serverName=$(var_parser MENU | sed -n 's/^server_name=//p')
		[ -z ${serverName} ] && serverName="$(hostname)"
		autoClear=$(var_parser MENU | sed -n 's/^auto_clear=//p')
		[ -z ${autoClear} ] && autoClear=0
		clearDays=$(var_parser MENU | sed -n 's/^clear_days=//p')
		[ -z ${clearDays} ] && clearDays=10
		scriptEnable=$(var_parser GLOBAL | sed -n 's/^script_enable=//p')
		[ -z ${scriptEnable} ] && scriptEnable="0"
		instanceId=$(var_parser GLOBAL | sed -n 's/^instance_id=//p')
		[ -z ${instanceId} ] && instanceId="00"
		instanceId=$(cut -c1-2 <<< ${instanceId} | awk '{printf "%02d\n", $0;}')
		serviceName=$(var_parser GLOBAL | sed -n 's/^service_name=//p')
		[ -z ${serviceName} ] && serviceName="SIXDEE"
		serverType=$(var_parser GLOBAL | sed -n 's/^server_type=//p')
		[ -z ${serverType} ] && serverType="2"
		multipleInstance=$(var_parser GLOBAL | sed -n 's/^multiple_instance=//p')
		[ -z ${multipleInstance} ] && multipleInstance="0"
		tmppath=${scriptDir}/.tmp; mkdir -p ${tmppath} ${logDir}
		firstRun=${tmppath}/firstRun${scriptBuild}
		get_lib "${scriptDir}/libs/log_it"
		get_lib "${scriptDir}/libs/auto_clear"
		get_lib "${scriptDir}/libs/menu_func"
		get_lib "${scriptDir}/libs/menu_disp"
		log_it "6" "[I] [${LINENO}] ${scriptName} initialized with Config File :${configFile}, Version:${scriptVersion}, Release:${scriptModifyDate} Build:${scriptBuild}, ModuleID=${moduleID}, Instance_ID:${instanceId}"
		log_it "6" "[I] [${LINENO}] Script Finished loading of global variables into cache."
		log_it "6" "[I] [${LINENO}] Script Enable:${scriptEnable}, Log Path:${logDir}, Log Prefix:${logPrefix}, Log Rotation:${logRotation}, Logs Level:${logLevel}, Server Name:${serverName}, Auto Clear Logs:${autoClear}, Clear Frequency in days:${clearDays}, Service Name:${serviceName}."
		log_it "6" "[I] [${LINENO}] Script Temp Path:${tmppath}, Log File:${loggerFileName}, Menu User:${menuUser}."
		
		if [ ${scriptEnable} -eq 0 ]
			then
				log_it "4" "[W] [${LINENO}] Script is not enabled in ${configFile}:${scriptEnable}, Please set value scriptEnable=1."
				echo -e "${red}Script is not enabled in ${configFile}:${scriptEnable}, Please set value scriptEnable=1. ${default}"
				exit 0
		fi 
		if [ ${autoClear} -eq 1 ]
			then
				auto_clear "${logDir}" "${logPrefix}" ".log" "${clearDays}" 
		fi
		if [ ! -f ${firstRun} ] 2>/dev/null;
			then 
				touch ${firstRun}
		fi
	else
		echo -e "${red} Error:Cannot initialize Menu Browser; Config File:${configFile} is empty/missing. ${default}"
		exit 0
fi
# ignore CTRL+C, CTRL+Z and quit singles using the trap
#trap '' SIGINT SIGQUIT SIGTSTP
########################################################
################ BEGINING OF MAIN  #####################
########################################################
#Main Script Start Here
while  true
 do
	log_it "6" "[I] [${LINENO}] Received request for displaying Main Menu, Function call main_menu"
	main_menu
	printf " Choose Option ${green}[0-${countL}]${default}:"
	wait
	read inputMain
	log_it "6" "[I] [${LINENO}] Input received in main_menu as ${inputMain}."
	if [[ ${inputMain} == "0" ]]
		then
			unset footerMsg
			log_it "4" "[W] [${LINENO}] Menu exit option received, Breaking menu operation."
			echo -e "${green} Bye! ${default}\n"
			break
	elif [[ "$inputMain" == *[[:digit:]]* && $inputMain -ge 0 && $inputMain -lt ${countI} ]]
		then
			unset footerMsg
			secApp=$(cat ${tmppath}/.apptemp | head -n ${inputMain} | tail -1)
			log_it "6" "[I] [${LINENO}] Input received as ${inputMain} for main menu,Opted ${secApp},Loading Sub Menu. Current Sections available $(cat ${tmppath}/.apptemp)"
			sub_menu ${secApp}
	elif [[ "$inputMain" == "${countI}" ]]
		then
			unset footerMsg
			log_it "6" "[I] [${LINENO}] Input received as ${inputMain} for main menu,Execute Task"
			task_control
	elif [[ "$inputMain" == "${countJ}" ]]
		then
			unset footerMsg
			log_it "6" "[I] [${LINENO}] Input received as ${inputMain} for main menu,View About Server"
			aboutSys
	elif [[ "$inputMain" == "${countK}" ]]
		then
			unset footerMsg
			log_it "6" "[I] [${LINENO}] Input received as ${inputMain} for main menu,View About Menu"
			aboutMenu
	elif [[ "$inputMain" == "${countL}" ]]
		then
			unset footerMsg
			log_it "6" "[I] [${LINENO}] Input received as ${inputMain} for main menu,Refresh Menu"
		else
			write_header
			footer_mesg "2" "Invalid option selected. Please re-select"
			log_it "4" "[W] [${LINENO}] Input received as {$inputMain} for main menu , Opted invalid option"
	fi
done
#End of Script