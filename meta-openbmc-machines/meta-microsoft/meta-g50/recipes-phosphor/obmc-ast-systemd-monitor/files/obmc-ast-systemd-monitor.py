#!/usr/bin/python -u

import sys
import os
import gobject
import dbus.mainloop.glib
import bmchealth_handler

MONITOR_POLL_INTERVAL = 1000
TEMP_MONITOR_FILE = "/tmp/monitor_systemd_cache"

def check_is_pid(filename):
    try:
        val = int(filename)
    except:
        return 0
    return 1

def check_is_main_service(file):
    try:
        cgroup_path = "/proc/"+file+"/cgroup"
        cgroup = ""
        with open(cgroup_path, "r") as f:
            for line in f:
                cgroup = line.rstrip('\n')
        comm_path = "/proc/"+file+"/comm"
        comm = ""
        with open(comm_path, "r") as f:
            for line in f:
                comm = line.rstrip('\n')
        if comm == "sh":
            return None
        service_name = cgroup.split("/")[-1]
        if service_name == "":
            return None
        service_path = "/lib/systemd/system/"+service_name
        service_content = ""
        with open(service_path, "r") as f:
            service_content = f.read()
        if service_content.find(comm)>=0:
            return [service_name, comm]
        else:
            return None
    except:
        return None

def scanServiceList():
    count = 0
    service_list = {}
    proc_list = os.listdir("/proc/")
    #scan /proc/[pid] status
    for file in proc_list:
        if check_is_pid(file) == 1:
            item = check_is_main_service(file)
            if item != None:
                service_list[file] = item
    return service_list

class MonitorSystemd():
    def __init__(self):
        self.service_status = {}
        self.service_delete={}
        self.restoreCaheFile()
        gobject.timeout_add(MONITOR_POLL_INTERVAL, self.monitorService)

    def saveCaheFile(self):
        with open(TEMP_MONITOR_FILE, 'w+') as f:
            for key in self.service_status:
                f.write(key+";"+self.service_status[key]+"\n")
            for key in self.service_delete:
                f.write(key+";"+self.service_delete[key]+"\n")

    def restoreCaheFile(self):
        try:
            with open(TEMP_MONITOR_FILE, 'r') as f:
                for line in f:
                    val_a = line.rstrip('\n').split(";")
                    if val_a[0].find("-delete") >=0:
                        self.service_delete[val_a[0]] = val_a[1]
                    else:
                        self.service_status[val_a[0]] = val_a[1]
        except:
            pass

    def monitorService(self):
        srv_list = scanServiceList()
        for key in srv_list:
            key_map_str = srv_list[key][0] + "-" + srv_list[key][1]
            if key_map_str in self.service_status:
                if self.service_status[key_map_str] != key and \
                (key_map_str+"-delete" not in self.service_delete or self.service_delete[key_map_str+"-delete"] != key):
                    bmchealth_handler.LogEventBmcHealthMessages("Asserted", "BMC Service Restarted", \
                            data={'service_id_low':int(key)&0xff, 'service_id_high':(int(key)>>8)&0xff})
                    self.service_delete[key_map_str+"-delete"] = self.service_status[key_map_str]
                    self.service_status[key_map_str] = key
            else:
                self.service_status[key_map_str] = key
                self.service_delete[key_map_str+"-delete"] = ""
        self.saveCaheFile()
        return True

if __name__ == '__main__':
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    root_sensor = MonitorSystemd()
    mainloop = gobject.MainLoop()

    print "Starting to Monitor Systemd"
    mainloop.run()

