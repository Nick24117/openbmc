/*************************************************************
*                                                            *
*   Copyright (C) Microsoft Corporation. All rights reserved.*
*                                                            *
*************************************************************/

#include <stdio.h>
#include <time.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/watchdog.h>

#define WATCHDOG_MODULE		"/dev/watchdog"


#define WATCH_MISS_THRESHOLD 5

enum{
    WATCH_REDFISH,
    WATCH_HWMON,
    WATCH_EVENT_SERVICE,
    WATCH_COUNT
};

const char *WATCH_FILE_PATH[] = {
    [WATCH_REDFISH]        = "/var/lib/obmc/watch_redfish",
    [WATCH_HWMON]          = "/var/lib/obmc/watch_hwmon",
    [WATCH_EVENT_SERVICE]  = "/var/lib/obmc/watch_event_service",
};

void main()
{
    static char watch[WATCH_COUNT] = {0};
    char watchMissCount = 0;
    int i, c = 0;
    FILE *fp = NULL;
	int fd = open(WATCHDOG_MODULE, O_RDWR);
	
	printf("\nStart Watchdog ... \n");	
	
	if(fd < 0)	
	{
		printf("open '%s' error!\n", WATCHDOG_MODULE);
		return;
	}
	
	while(1)
	{
        watchMissCount = 0;
        for(i=0; i<WATCH_COUNT; ++i){
            fp = fopen(WATCH_FILE_PATH[i], "r");
            if(fp == NULL){
                watch[i] = 0;
                fp = fopen(WATCH_FILE_PATH[i], "w+");
            }else{
                if(watch[i] < WATCH_MISS_THRESHOLD){
                    watch[i]++;
                }else{
                    watchMissCount++;
                }
                printf("@@@ check %s exist, watch[%d] = %d, watchMissCount = %d\n", WATCH_FILE_PATH[i], i, watch[i], watchMissCount);
            }
            fclose(fp);
        }

        if(watchMissCount == 0){
            //default hardware watchdog timeout is 30 seconds
            if(ioctl(fd, WDIOC_KEEPALIVE) < 0){
                printf("WDIOC_KEEPALIVE IOCTL error!\n");
            }
        }
		sleep(5);		
	}

	return;
}
