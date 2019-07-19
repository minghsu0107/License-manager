# !usr/bin/bash

show_error_message() {
	echo "Usage:"
	echo "./make.sh [Host] [Mode] [Options]"
	echo "Host"
	echo "    -c          for pc (on windows git bash)"
	echo "    -p          for projector (on linux)"
	echo "Mode"
	echo "    -u          using universal key"
	echo "    -t          for general test"
	echo "Options"
	echo "    -d          debug mode"
}

compile_and_run() {
	if [ $# -eq 3 -a "$1" = "-d" ]
	then
		if [ "$2" = "-c" ]
		then
			if [ ! -s license-manager-pc-debug  ]
			then
				set_status_file_name
				g++ -std=gnu++11 -D DEBUG -D PC \
				         src/example/example.cpp \
				         src/json_convert/json.hpp \
				         src/encryption/xxtea.cpp \
				         src/pc_licensing/get_pc_info.cpp \
				         src/generator/license_generator.cpp \
				         src/generator/generate_universal.cpp \
				         src/pc_licensing/license_validation_pc.cpp \
				         -o license-manager-pc-debug
			fi
			./license-manager-pc-debug "$3"
		elif [ "$2" = "-p" ]
		then
			if [ ! -s license-manager-projector-debug ]
			then
				set_status_file_name
				g++ -std=gnu++11 -D DEBUG -D PRO\
				         src/example/example.cpp \
				         src/json_convert/json.hpp \
				         src/encryption/xxtea.cpp \
				         src/projector_licensing/get_projector_info.cpp \
				         src/generator/license_generator.cpp \
				         src/generator/generate_universal.cpp \
				         src/projector_licensing/license_validation_projector.cpp \
				         -o license-manager-projector-debug
			fi
			./license-manager-projector-debug "$3"
		fi
	elif [ $# -eq 2 ]
	then
		if [ "$1" = "-c" ]
		then
			if [ ! -s license-manager-pc ]
			then
				set_status_file_name
				g++ -std=gnu++11 -D PC\
				         src/example/example.cpp \
				         src/json_convert/json.hpp \
				         src/encryption/xxtea.cpp \
				         src/pc_licensing/get_pc_info.cpp \
				         src/generator/license_generator.cpp \
				         src/generator/generate_universal.cpp \
				         src/pc_licensing/license_validation_pc.cpp \
				         -o license-manager-pc
			fi
			./license-manager-pc "$2"
		elif [ "$1" = "-p"  ]
		then
			if [ ! -s license-manager-projector ]
			then
				set_status_file_name
				g++ -std=gnu++11 -D PRO\
				         src/example/example.cpp \
				         src/json_convert/json.hpp \
				         src/encryption/xxtea.cpp \
				         src/projector_licensing/get_projector_info.cpp \
				         src/generator/license_generator.cpp \
				         src/generator/generate_universal.cpp \
				         src/projector_licensing/license_validation_projector.cpp \
				         -o license-manager-projector
			fi
			./license-manager-projector "$2"
		fi
	fi
}

set_status_file_name() {
	if [ -s ./src/generator/status/pc_status/status.json ]
	then
		hostname=`hostname`
		user=`whoami`
		new_file_name="$hostname-$user.json"
		new_file_name=`echo "$new_file_name" | awk '{print tolower($0)}'`
		mv ./src/generator/status/pc_status/status.json \
		   ./src/generator/status/pc_status/"$new_file_name"
	fi
	if [ -s ./src/generator/status/projector_status/status.json ]
	then
		source="src/projector_licensing/projector_serial.txt"
		new_file_name=`awk 'NR==1' "$source"`
		mv ./src/generator/status/projector_status/status.json \
		   ./src/generator/status/projector_status/"$new_file_name.json"
	fi
}

process() {
	if [ $1 -eq 3 -a "$4" = "-d" ]
	then
		compile_and_run "$4" "$3" "$2"
	elif [ $1 -eq 2 ]
	then
		compile_and_run "$3" "$2"
	else
		show_error_message
		exit 1
	fi
	
}

if [ $# -eq 2 -o $# -eq 3 ]
then
	if [ "$1" = "-c" ]
	then
		if [ "$2" = "-u" ]
		then
			process "$#" "a" "$1" "$3"
		elif [ "$2" = "-t" ]
		then
			process "$#" "b" "$1" "$3"
		else
			show_error_message
		fi
	elif [ "$1" = "-p" ]
	then
	    if [ "$2" = "-u" ]
		then
			process "$#" "c" "$1" "$3"
		elif [ "$2" = "-t" ]
		then
			process "$#" "d" "$1" "$3"
		else
			show_error_message
		fi
	else
	    show_error_message
	fi
else
	show_error_message
fi

exit 0
