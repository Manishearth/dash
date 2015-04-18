declare -a PID
for i in `seq 0 4`;
do
cd "server$i"
../server config.json&
PID[$i]="$!"
cd ..

done
echo "${PID[0]} ${PID[1]} ${PID[2]} ${PID[3]} ${PID[4]}"
trap "kill -9 ${PID[0]} ${PID[1]} ${PID[2]} ${PID[3]} ${PID[4]}" SIGTERM SIGKILL INT
wait
