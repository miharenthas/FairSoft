#a tiny script to get an idea of what's installed on the system
#before going bananas with downloads and builds

# $1 -- the lib name
# $2 -- a weird include path (if "--" use $1)
# $3 -- optionally, a version


checklib(){
	libname=$1; shift
	if [ $1 = "--" ]; then incname=$libname
	else incname=$1; fi; shift
	if [ -n $1 ]; then libvers=$1; fi

	libs=$( ls /lib{,64}/*$libname*$libvers* 2>/dev/null )
	incs=$( ls /usr{,/local}/include/*$incname* 2>/dev/null )

	if [ -n "$libs" -a -n "$incs" ]; then check=0
	elif [ -n "$libs" -a -z "$incs" ]; then
		echo "Please install the development version of $libname."
		check=-1
	elif [ -z "$libs" ]; then check=1; fi
}
