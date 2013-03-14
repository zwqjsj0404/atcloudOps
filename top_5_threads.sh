#!/bin/bash

redEcho()
{
    echo -e "\033[1;31m$@\033[0m"
}

uuid=`date +%s`_${RANDOM}_$$

ps -Leo pid,lwp,user,comm,pcpu --no-headers | awk '$4=="java"{print $0}' |
sort -k5 -r -n | head -5 | while read threadLine ; do
        pid=`echo ${threadLine} | awk '{print $1}'`
        threadId=`echo ${threadLine} | awk '{print $2}'`
        threadId0x=`printf %x ${threadId}`
        user=`echo ${threadLine} | awk '{print $3}'`
        pcpu=`echo ${threadLine} | awk '{print $5}'`
        
        jstackFile=/tmp/${uuid}_${pid}
        
        [ ! -f "${jstackFile}" ] &&
        {
            jstack ${pid} > ${jstackFile} ||
            { redEcho "Fail to jstack java process ${pid}"; rm ${jstackFile} ; continue; }
        }
        
        redEcho "The stack of busy(${pcpu}%) thread(${threadId}/0x${threadId0x}) of java process(${pid}) of user(${user}):"
        sed "/nid=0x${threadId0x}/,/^$/p" -n ${jstackFile}
done

rm /tmp/${uuid}_*
