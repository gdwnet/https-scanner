#Run the script by providing a domain name, e.g. ./script.sh gdwnet.com

        site=$1

                #Grab the domain name from the MySQL database

                #Output what we are doing
                echo "Cert Analyzing: " $site

                #Check to see if port 443 is open
                #curl -sL -w "%{http_code}\n" https://google.com:443 -o /dev/null
                site_https_port_code=$(curl -sL -w "%{http_code}\n" https://$site:443 -o /dev/null)

                if [ $site_https_port_code = "000" ]; then
                        let site_https_port_code=200
                fi
                echo "site port 443:" $site_https_port_code


                #Main Analysis
                        #Grab the cert and smack it into a variable. The echo "q" terminates the connection when done
                        cert_data=$(echo "q" | timeout 20 openssl s_client -connect $site:443 2>/dev/null)

                        #Now we look at the data for the line "issuer"
                        issuer=$(echo "${cert_data}" |grep "issuer")

                        #Chop off the first 7 letters (The issuer part)
                        issuer=${issuer:7}

                        #Grab end date
                        enddate=$(echo "q" |timeout 20 openssl s_client -connect $site:443 |openssl x509 -noout -dates|grep "After")
                        enddate=${enddate:9}
                        echo $enddate

                        #Output what we fine
                        echo "Cert issued by: " $issuer

                        #Because mysql struggles with certain chars.......
                        issuer=$(sed "s/'//g" <<< $issuer)

                        #Find out if the site has a redirect
                        redirect=$(curl -Ls -o /dev/null -w %{url_effective} $site)

                        echo "redirects to: " $redirect

