#Set-OCSPhone

$Users = get-qaduser -LDAPFilter '(msRTCSIP-UserEnabled=TRUE)' -IncludedProperties 'msRTCSIP-Line'
foreach ( $U in $Users ) {

    #remove the - from the phone number
    $Phone = ($U.phonenumber).substring(0,3)+($U.phonenumber).substring(4)
    set-QADUser -Identity $U -ObjectAttributes @{ 'msRTCSIP-Line' = 'tel:+1757'+$Phone }
}
