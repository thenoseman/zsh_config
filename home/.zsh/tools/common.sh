# Colors
declare -A COLORS=(
	[RESET]="\e[0m"
	[RED]="\e[38;5;9m"
	[GREEN]="\e[38;5;2m"
	[YELLOW]="\e[38;5;11m"
	[VIOLET]="\e[38;5;13m"
	[TURQUOISE]="\e[38;5;13m"
)
export COLORS

# echoc RED "This is in red!"
echoc() {
	local color="$1"
	shift
	echo -ne "${COLORS[$color]}${*}${COLORS[RESET]}\n"
}
