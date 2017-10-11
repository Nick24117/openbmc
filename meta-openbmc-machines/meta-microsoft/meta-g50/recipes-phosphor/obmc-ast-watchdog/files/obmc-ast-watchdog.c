/*************************************************************
*                                                            *
*   Copyright (C) Microsoft Corporation. All rights reserved.*
*                                                            *
*************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <linux/watchdog.h>

#define WATCHDOG_MODULE     "/dev/watchdog"

#define WATCH_MISS_THRESHOLD  (10)
#define MAX_LEN_FILE_NAME (50)

enum em_watch_type{
    EM_WATCH_REDFISH = 0,
    EM_WATCH_HWMON,
    EM_WATCH_EVENT_SERVICE,
    EM_WATCH_COUNT
};

struct st_watch_record {
    enum em_watch_type type;
    char file_path[MAX_LEN_FILE_NAME];
    unsigned int miss_count;
};

struct st_watch_record  g_watch_tab[EM_WATCH_COUNT] = {
    {EM_WATCH_REDFISH, "/run/obmc/watch_redfish", 0},
    {EM_WATCH_HWMON, "/run/obmc/watch_hwmon", 0},
    {EM_WATCH_EVENT_SERVICE, "/run/obmc/watch_event_service", 0},
};

static void create_new_watch_file(char *path)
{
    FILE *fp = NULL;
    if (path == NULL)
        return;
    fp = fopen(path, "w+");
    if (fp != NULL)
        fclose(fp);
}

//@return: 1-success to check watch file; 0-it is abnormal to check watch file
static int check_watch_file_status()
{
    int i; 
    for (i = 0; i<EM_WATCH_COUNT; i++)
    {
        if( access( g_watch_tab[i].file_path, F_OK ) == -1 )
        {
            g_watch_tab[i].miss_count = 0;
            create_new_watch_file( g_watch_tab[i].file_path);
        }
        else
        {
            g_watch_tab[i].miss_count+=1;
            if(g_watch_tab[i].miss_count > WATCH_MISS_THRESHOLD)
                return 0;
        }
    }
    return 1;
}

//@return: 1-success for system stable; 0-it is abnormal for system stable
static int wait_system_stable()
{
    int i;

    //create all watch file
    for (i = 0; i<EM_WATCH_COUNT; i++)
        create_new_watch_file(g_watch_tab[i].file_path);

    //wait and check all task is alive to delete relative watch file
    while (1)
    {
        for (i = 0; i<EM_WATCH_COUNT; i++)
            if( access( g_watch_tab[i].file_path, F_OK ) != -1 )
                break;
        //check all releate watch files are deleted
        if (i == EM_WATCH_COUNT)
            return 1;
        sleep(5);
    }
    return 0;
}

static void save_pid (void) {
    pid_t pid = 0;
    FILE *pidfile = NULL;
    pid = getpid();
    if (!(pidfile = fopen("/run/obmc-ast-watchdog.pid", "w"))) {
        fprintf(stderr, "failed to open pidfile\n");
        return;
    }
    fprintf(pidfile, "%d\n", pid);
    fclose(pidfile);
}

void WDT2_disable()
{
    system("devmem 0x1e78502c 32 0");
    return;
}

void main()
{
    struct stat st = {0};
    int fd = -1;

    save_pid();

    //check and create /run/obmc/ directory
    if (stat("/run/obmc/", &st) == -1) {
        mkdir("run/obmc/", 0755);
    }

    if (wait_system_stable() == 0)
    {
        printf("\nDisable Watchdog for system stable timeout !!\n");  
        return;
    }

    fd = open(WATCHDOG_MODULE, O_RDWR);
    if(fd < 0)
    {
        printf("open '%s' error!\n", WATCHDOG_MODULE);
        return;
    }

    //After wait system stable and enabled watchdog1, watchdog2 can be disabled
    WDT2_disable();

    printf("\nStart Watchdog ... \n");  
    while(1)
    {
        if(check_watch_file_status() == 1){
            //default hardware watchdog timeout is 30 seconds
            if(ioctl(fd, WDIOC_KEEPALIVE) < 0){
                printf("WDIOC_KEEPALIVE IOCTL error!\n");
            }
        }
        sleep(5);       
    }
    close(fd);
    return;
}
