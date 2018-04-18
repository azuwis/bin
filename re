#!/bin/bash

default_duration='1hour'
default_reminder='30m'

parse() {
    local index="$1"
    local regex="$2"
    local flag="$3"
    local value="$4"
    local offset=${DATETIME[$((flag/2+8))]}
    if [ "$offset" -ge 8 ]
    then
        return 0
    fi
    if [[ "${ARGS[index]}" =~ $regex ]]
    then
        DATETIME[$((flag+offset))]="$value"
        unset 'ARGS[index]'
        DATETIME[$((flag/2+8))]=$((offset+4))
        return 0
    else
        return 1
    fi
}

# start_date start_date_relative start_time start_time_relative end_date end_date_relative end_time end_time_relative date_offset time_offset
DATETIME=("$(date '+%m/%d/%Y')" 0day "$(date '+%H:%M')" 0hour '' 0day '' '' 0 0)

if [ "$1" = '-n' ]
then
    shift
    DRY_RUN=yes
fi

ARGS=("$@")

# parse start_date end_date
for i in "${!ARGS[@]}"
do
    parse "$i" '^[0-9]*d$' 1 "${ARGS[i]}ay" ||
        parse "$i" '^[0-9]*w$' 1 "${ARGS[i]}eek" ||
        parse "$i" '^[0-9]*m$' 1 "${ARGS[i]}onth" ||
        parse "$i" '^[0-9]*mo$' 0 "${ARGS[i]}n" ||
        parse "$i" '^[0-9]*tu$' 0 "${ARGS[i]}e" ||
        parse "$i" '^[0-9]*we$' 0 "${ARGS[i]}d" ||
        parse "$i" '^[0-9]*th$' 0 "${ARGS[i]}u" ||
        parse "$i" '^[0-9]*fr$' 0 "${ARGS[i]}i" ||
        parse "$i" '^[0-9]*sa$' 0 "${ARGS[i]}t" ||
        parse "$i" '^[0-9]*su$' 0 "${ARGS[i]}n" ||
        parse "$i" '^[0-9]{1,2}/[0-9]{1,2}(/[0-9]{2,4})?$' 0 "${ARGS[i]}"
done

# parse start_time end_time
for i in "${!ARGS[@]}"
do
    parse "$i" '^[0-9]*h$' 3 "${ARGS[i]}our" ||
        parse "$i" '^[0-9]{1,4}$' 2 "${ARGS[i]}"
done

# parse reminder
reminder="$default_reminder"
for i in "${!ARGS[@]}"
do
    if [[ "${ARGS[i]}" =~ ^[0-9]+r$ ]]
    then
        reminder="${ARGS[i]%r}"
        unset 'ARGS[i]'
    fi
done

start_date="$(date -d "${DATETIME[*]:0:4}" '+%m/%d/%Y')"
start_time="$(date -d "${DATETIME[*]:0:4}" '+%H:%M')"

# end_date is not set
[ -z "${DATETIME[4]}" ] && DATETIME[4]="$start_date"
# end_time is not set
[ -z "${DATETIME[6]}" ] && {
    DATETIME[6]="$start_time"
    # end_time_relative is not set
    [ -z "${DATETIME[7]}" ] && DATETIME[7]="$default_duration"
}
# end_date or end_date_relative is set
[ "${DATETIME[8]}" -eq 8 ] && [ "${DATETIME[9]}" -eq 4 ] && {
    DATETIME[6]="23:59"
    DATETIME[7]='0hour'
}

end_date="$(date -d "${DATETIME[*]:4:4}" '+%m/%d/%Y')"
end_time="$(date -d "${DATETIME[*]:4:4}" '+%H:%M')"

if [ "${DATETIME[9]}" -eq 0 ]
then
    # all day event
    allday="yes"
    start="$start_date"
    end="$end_date"
    start_epoch="$(date -d "$start" '+%s')"
    end_epoch="$(date -d "$end" '+%s')"
    duration="$(((end_epoch - start_epoch) / 86400 + 1))"
else
    start="$start_date $start_time"
    end="$end_date $end_time"
    start_epoch="$(date -d "$start" '+%s')"
    end_epoch="$(date -d "$end" '+%s')"
    duration="$(((end_epoch - start_epoch) / 60))"
fi

title="${ARGS[*]}"

echo "title: $title"
# echo "datetime: ${DATETIME[*]}"
echo "start: $start"
echo "end: $end"
[ -n "$allday" ] && echo "allday: $allday"
echo "duration: ${duration}$([ "$allday" = 'yes' ] && echo 'd' || echo 'm')"
[ "$reminder" != "$default_reminder" ] && echo "reminder: $reminder"

[ -n "$DRY_RUN" ] && exit

echo
read -r -p "Add to Reminders?[Yn]" input
if [ -z "$input" ] || [ "$input" = 'Y' ]
then
    gcalcli=(--calendar Reminders add --details all --title "$title" --when "$start" --duration "$duration" --reminder "$reminder")
    [ -n "$allday" ] && gcalcli+=(--allday)
    gcalcli "${gcalcli[@]}"
fi
