#!/bin/sh


# kill previous instances of this script before running
# $$ refers to the current process which is $0
for pid in `pgrep -f $0`; do
   if [[ $pid != $$ ]]; then
      kill $pid
   fi
done

# this scripts checks for the power level of two batteries
# notifies user if power gets below the supplied value

full=0
charging=0
draining=0
lowpower=0
limit=$1

while true; do
   bat0=`cat /sys/class/power_supply/BAT0/capacity`
   bat1=`cat /sys/class/power_supply/BAT1/capacity`
   stat0=`cat /sys/class/power_supply/BAT0/status`
   stat1=`cat /sys/class/power_supply/BAT1/status`

   if [ $stat0 == "Full" ] && [ $stat1 == "Full" ]; then
      state="Full"
   elif [ $stat0 == "Charging" ] || [ $stat1 == "Charging" ]; then
      state="Charging"
   else
      state="Discharging"
   fi

   case $state in
      Full) 
         if [ $full -eq 0 ]; then
            full=1
            notify-send -u normal 'battery' 'fully charged'
         fi
         ;;

      Charging)
         full=0
         draining=0
         lowpower=0

         if [ $charging -eq 0 ]; then
            charging=1
            notify-send -u normal 'battery' 'charging'
            echo 'battery is charging'
         fi
      ;;

      Discharging)
         full=0
         charging=0

         if [ $draining -eq 0 ]; then
            draining=1
            notify-send -u low 'battery' 'discharging'
            echo 'battery is discharging'
         fi

         if [ $bat0 -le $limit ] && [ $bat1 -le $limit ]; then
            if [ $lowpower -eq 0 ]; then
               lowpower=1
               notify-send -u critical 'battery' 'low power'
               echo 'battery on low power'
            fi
         fi
      ;;
   esac

   sleep 5
done
