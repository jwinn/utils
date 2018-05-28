#!/bin/sh -e

#--------------------------------------------------------------------#
# config vars - you can edit this section
#--------------------------------------------------------------------#

# domain registered with namecheap private DNS
domain="winlum.net"

# password from namecheap private DNS
password="167b4a7e451c4504bf9a87d34b94ceb4"

# either empty for '*' or space-delimited
#subdomains="@ www mail plex calibre murmur ftp"
subdomains="@"

# how many seconds to check if IP has changed
check_delay=600

# how many seconds to force an update
force_delay=604800

# the interface to query for the current IP
# to determine whether it has changed
nic="en0"

#--------------------------------------------------------------------#
# do not edit below this, unless you know what you're doing
#--------------------------------------------------------------------#

# normalize PATH
PATH=$(getconf PATH)

. ~/projects/github/jwinn/shell-scripts/includes/array.sh
. ~/projects/github/jwinn/shell-scripts/includes/date.sh
. ~/projects/github/jwinn/shell-scripts/includes/log.sh
. ~/projects/github/jwinn/shell-scripts/includes/string.sh

# check for required programs
[ ! "$(command -v curl || true)" ] && log_error "curl is required" && exit 1

# used to fetch the public ip and geoloc data
api_url="http://ip-api.com/json"

# used to store/persist runtime values
data_file="/tmp/ddns.txt"

# process the data file
if [ -f "${data_file}" ]; then
  while IFS= read -r line;
  do
    kvp=$(str_split "${line}" "=")
    key=$(str_trim "${kvp% *}")
    val=$(str_trim "${kvp#* }")
    case "$key" in
      ip) last_ip=$val ;;
      checked) last_checked=$val ;;
      forced) last_forced=$val ;;
    esac
  done < $data_file
fi

current_ts=$(date_current_ts)
last_checked=${last_checked:-$((current_ts - check_delay))}
last_forced=${last_forced:-$((current_ts - force_delay))}
diff_checked=$((current_ts - last_checked))
diff_forced=$((current_ts - last_forced))
next_check=$((check_delay - diff_checked))
next_force=$((force_delay - diff_forced))

[ $diff_checked -lt $check_delay ] && \
  [ $diff_forced -lt $force_delay ] && \
  log_info "next IP check in ${next_check} seconds" && \
  exit 0

# update last checked to current time
last_checked=$(date_current_ts)

current_ip=$(ifconfig $nic | grep "inet " | awk '{print $2}')
[ -z "${current_ip}" ] && \
  log_error "could not determine ${nic} IP" && exit 1
previous_ip=${last_ip:-$current_ip}

response=$(curl -sS -L "${api_url}")
public_ip_json=$(str_jsonkey_value "${response}" "query")
public_ip=$(str_trim "${public_ip_json}" "\"")

[ "${current_ip}" = "${previous_ip}" ] && \
  [ $diff_forced -lt $force_delay ] && \
  log_info "IP has not changed; force update in ${next_force} seconds" && \
  exit 0

base_url="https://dynamicdns.park-your-domain.com/update?"
base_url="${base_url}domain=${domain}&password=${password}"

for host in $subdomains;
do
  url="${base_url}&host=${host}"
  response=$(curl --compressed -m 60 --retry 3 -sS -L --tlsv1 "${url}")

  xml_ip=$(str_xmlnode_value "${response}" "IP" || true)
  xml_errcount=$(str_xmlnode_value "${response}" "ErrCount" || true)

  if [ -n "${xml_ip}" ] && [ $xml_errcount -eq 0 ]; then
    log_message "SUCCESS: ${host} ${domain} bound to ${xml_ip}"
    current_ip="${xml_ip}"

    # update last forced to current time
    if [ $diff_forced -ge $force_delay ]; then
      last_forced=$(date_current_ts)
    fi
  else
    log_error "request failed for ${host} ${domain} to ${current_ip}"
  fi
done

exit 0

