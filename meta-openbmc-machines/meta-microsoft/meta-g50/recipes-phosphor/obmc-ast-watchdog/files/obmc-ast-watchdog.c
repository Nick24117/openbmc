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

void main()
{
	int fd = open(WATCHDOG_MODULE, O_RDWR);
	
	printf("\nStart Watchdog ... \n");	
	
	if(fd < 0)	
	{
		printf("open '%s' error!\n", WATCHDOG_MODULE);
		return;
	}
	
	while(1)
	{
		//default hardware watchdog timeout is 30 seconds
		if(ioctl(fd, WDIOC_KEEPALIVE) < 0)
			printf("WDIOC_KEEPALIVE IOCTL error!\n");
				
		sleep(5);		
	}
	
	return;
}
