#! /bin/bash/

# variables declartion to send email
recipient=="msdineshkumar6@gmail.com"


# Threshold values in percentage as top limit
cpu_threshold=80   # 80% CPU usage
memory_threshold=80  # 80% memory usage
disk_threshold=90  # 90% disk usage 

# Get system parameters
hostname=$(hostname)
current_time=$(date)
cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
memory_usage=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
disk_usage=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')

# Function to send email
send_email() {
    local subject="$1"
    local body="$2"
    echo -e "$body" | mail -s "$subject" "$recipient"
}

# Create alerts for each system parameter
alert_message=""
if (( $(echo "$cpu_usage > $cpu_threshold" | bc -l) )); then
    alert_message="$alert_message\nWARNING: CPU usage is high ($cpu_usage%)"
fi

if (( $(echo "$memory_usage > $memory_threshold" | bc -l) )); then
    alert_message="$alert_message\nWARNING: Memory usage is high ($memory_usage%)"
fi

if (( $disk_usage > $disk_threshold )); then
    alert_message="$alert_message\nWARNING: Disk usage is high ($disk_usage%)"
fi

# If any parameter exceeds the threshold, send an email
if [[ ! -z "$alert_message" ]]; then
    subject="System Alert: $hostname - $current_time"
    body="System Alert Report for $hostname - $current_time\n\n$alert_message\n\nPlease take action."
    send_email "$subject" "$body"
    echo "Alert email sent to $recipient."
else
    echo "System parameters are normal. No alert triggered."
fi