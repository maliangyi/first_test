*** Settings ***
Library    Remote    http://172.17.0.4:8270/  
#Library    Remote    http://172.17.0.2:8271/  WITH NAME  remote1
Library    DateTime
Library    Collections        
Suite Setup    Connect To Redis    ${db_CE}
Documentation    \ 
...    RF Demo
...    'APP_DB',    
...    'APP_PLUS_DB',    
...    'ASIC_DB',    
...    'ASIC_FWD_DB',    
...    'CFG_CP_DB',    
...    'CFG_DB',    
...    'CONETXT_DB',   ##no support    
...    'IBC_DB',    
...    'LOCAL_DB',    
...    'MONITOR_DB',    
...    'RGMOMD_CE_GLOBAL',    
...    'RGMOMD_CFG_CP',    
...    'RGMOMD_CFG_GLOBAL',    
...    'RGMOMD_CONTEXT_GLOBAL',   ##no support  
...    'RGMOMD_DE_FWD_GLOBAL',    
...    'RGMOMD_DE_GLOBAL',    
...    'RGMOMD_DE_STADNALONE',    ##no support    
...    'RGMOMD_HOST',    
...    'RGMOMD_HOST_FWD',    
...    'RGMOMD_IBC_GLOBAL',    
...    'RGMOMD_LOCAL',    
...    'TOPO_DB',   ##no support     
...    'TUNNER_DB',    
...    'UDP_DB',    
...    'UDP_FWD_DB'
*** Variables ***
${db_CE}    RGMOMD_CE_GLOBAL
${db_HOST}    RGMOMD_HOST
${proto_arp}    arp_entry
${proto_ip_route}    ip_route_cfg
&{dict_result}    weight=0    rt_type=0
&{dict_result_arp_field}    ifx=0    mac=''    vid=0    inner_vid=0
*** Test Cases ***
test_set_get
    #init
    
    [Timeout]    5
    Connect To Redis   ${db_HOST}
    #input
    &{dict_ip}=    Create Dictionary    data=0x01010102
    New Proto Object    ip    common_type    Ipv4    ${dict_ip}
    
    &{dict_arp_key}=    Create Dictionary    vrf=0    v4=proto['ip']
    New Proto Object    arp_key    ${proto_arp}    Entryindex    ${dict_arp_key}
    
    &{dict_arp_fields}=    Create Dictionary     index=proto['arp_key']    ifx=1    mac='0000.1111.2222'    vid=10    inner_vid=100
    New Proto Object    arp    ${proto_arp}    Entry   ${dict_arp_fields}  
    
    Set to Redis    ${db_CE}    arp
   
    #output
    &{ip_route_key}=    Create Dictionary    proto='ce_test'    vrf_id='0'    prefix='1.1.1.1'    mask_len='24'    nh_addr='2.2.2.2'    nh_ifx='1'
    New Proto Object    route_key    ${proto_ip_route}    IpRouteKey    ${ip_route_key}
    
    &{ip_route_fields}=     Create Dictionary    index=proto['route_key']
    New Proto Object   route    ${proto_ip_route}    IpRouteCfg    ${ip_route_fields}   

    ${dict_result}=    Get From Redis    ${db_HOST}    route    ${dict_result}
    

    #compare
    Should Be Equal    &{dict_result}[weight]   ${123}
    Should Be Equal    ${dict_result.rt_type}   ${1}
    
    [Teardown]    Delete From Redis    ${db_CE}    arp
     
 test_loop
 
    ${time}=    Get Time
    LOG    ${time}    warn
        
    :FOR    ${ip_addr}    IN RANGE    10 
    \    ${ip_addr}=    Convert To String    ${ip_addr}
    \    &{dict_ip}=    Create Dictionary    data=${ip_addr}
    \    New Proto Object    ip    common_type    Ipv4    ${dict_ip}
    \    &{dict_arp_key}=    Create Dictionary    vrf=0    v4=proto['ip']
    \    New Proto Object    arp_key    ${proto_arp}    Entryindex    ${dict_arp_key}
    \    &{dict_arp_fields}=    Create Dictionary     index=proto['arp_key']    ifx=1    mac='0000.1111.2222'    vid=10    inner_vid=100
    \    New Proto Object    arp    ${proto_arp}    Entry   ${dict_arp_fields} 
    \    Set to Redis    ${db_CE}    arp
         
    ${time}=    Get Time
    LOG    ${time}    warn  
 
    :FOR    ${ip_addr}    IN RANGE    10  
    \    ${ip_addr}=    Convert To String    ${ip_addr}
    \    &{dict_ip}=    Create Dictionary    data=${ip_addr}
    \    New Proto Object    ip    common_type    Ipv4    ${dict_ip}
    \    &{dict_arp_key}=    Create Dictionary    vrf=0    v4=proto['ip']
    \    New Proto Object    arp_key    ${proto_arp}    Entryindex    ${dict_arp_key}
    \    &{dict_arp_fields}=    Create Dictionary     index=proto['arp_key']    ifx=1    mac='0000.1111.2222'    vid=10    inner_vid=100
    \    New Proto Object    arp    ${proto_arp}    Entry   ${dict_arp_fields} 
    \    Delete From Redis    ${db_CE}    arp
    
test_hmset_and_hgetall
    
    &{dict_ip}=    Create Dictionary    data=0x01010102
    New Proto Object    ip    common_type    Ipv4    ${dict_ip}
    
    &{dict_arp_key}=    Create Dictionary    vrf=0    v4=proto['ip']
    New Proto Object    arp_key    ${proto_arp}    Entryindex    ${dict_arp_key}
    
    &{dict_arp_fields}=    Create Dictionary     index=proto['arp_key']    ifx=1    mac='0000.1111.2222'    vid=10    inner_vid=100
    New Proto Object    arp    ${proto_arp}    Entry   ${dict_arp_fields}
         
    @{fields}    Create List    ${6}    ${7}    ${8}    ${9}
    Hmset To Redis    ${db_CE}    arp    ${fields}
     
    ${dict_result_arp_field}=    Hgetall from Redis    ${db_CE}    arp    ${dict_arp_fields}
    Should Be Equal    ${dict_result_arp_field.ifx}   ${1}
    Should Be Equal    ${dict_result_arp_field.mac}   0000.1111.2222
    Should Be Equal    ${dict_result_arp_field.vid}   ${10}
    Should Be Equal    ${dict_result_arp_field.inner_vid}   ${100}
    
    [Teardown]  Delete From Redis    ${db_CE}    arp
test_if
    ${time}=    Get Time
    Run Keyword If    1<2    LOG  ${time}   warn
    
    #remote1.Start Efastserver
    #remote1.Start Efastserver
   
