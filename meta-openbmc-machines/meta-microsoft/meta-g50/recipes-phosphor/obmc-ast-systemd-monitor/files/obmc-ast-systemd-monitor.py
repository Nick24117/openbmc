#!/usr/bin/python -u
# pylint: disable=missing-docstring
import os
import sys
import time
import traceback

import obmc.events

class Process(object):
    PID_UNKNOWN = -1

    def __init__(self, uid, name, pidfile):
        self._uid = uid
        self._name = name
        self._pidfile = pidfile
        self._previous_pid = self.PID_UNKNOWN
        self._current_pid = self.PID_UNKNOWN
        self._first_run = True

    def _restarted(self):
        '''
        A running process is considered restarted if it changes PID.

        NOTE a dead process is not considered restarted.
        '''
        if self._current_pid == self.PID_UNKNOWN:
            return False
        return self._previous_pid != self._current_pid

    def _save_pid(self):
        self._previous_pid = self._current_pid

    def _update_pid(self):
        is_running = False
        try:
            if os.access(self._pidfile, os.R_OK):
                with open(self._pidfile) as pfile:
                    pid = int(pfile.read())
                cmdline = '/proc/%d/cmdline' % pid
                if os.access(cmdline, os.R_OK):
                    is_running = True
        except IOError:
            # If pidfile doesn't exist yet, so be it.
            pass
        if is_running:
            self._current_pid = pid
            self._first_run = False
        else:
            self._current_pid = self.PID_UNKNOWN

    def name(self):
        return self._name

    def restarted(self):
        if self._first_run:
            self._update_pid()
            restarted = False
            self._save_pid()
        else:
            self._update_pid()
            restarted = self._restarted()
            self._save_pid()
        return restarted

    def uid(self):
        return self._uid

def _emit_event(process):
    event_manager = obmc.events.EventManager()
    event = obmc.events.Event.from_binary(
        obmc.events.Event.SEVERITY_WARN,
        sensor_type=0x28,
        sensor_number=0x82,
        event_dir_type=0x70,
        event_data_1=0xA0,
        event_data_2=process.uid(),
    )
    record_id = event_manager.create(event)
    if record_id != 0:
        print '[INFO] detected %s restarted, a SEL is created' % (
            process.name(),
        )
    else:
        print '[INFO] detected %s restarted, but failed to add SEL' % (
            process.name(),
        )

def _main():
    # NOTE if UID is changed, obmc/events.py must change accordingly.
    processes = (
        Process(1, 'obmc-redfish', '/run/obmc-redfish.pid'),
        Process(2, 'obmc-phosphor-event', '/run/obmc-phosphor-event.pid'),
        Process(3, 'oob-ipmid', '/run/oob-ipmid.pid'),
        Process(4, 'obmc-console-server', '/run/obmc-console-server.pid'),
        Process(5, 'hwmon', '/run/hwmon.pid'),
        Process(6, 'fan_algorithm', '/run/fan_algorithm.pid'),
        Process(7, 'bmchealth_handler', '/run/bmchealth_handler.pid'),
        Process(8, 'obmc-ast-watchdog', '/run/obmc-ast-watchdog.pid'),
        Process(9, 'cable_led', '/run/cable_led.pid'),
        Process(10, 'button_id', '/run/button_id.pid'),
        Process(11, 'power_control_sthelens', '/run/power_control_sthelens.pid'),
        Process(12, 'chassis_control', '/run/chassis_control.pid'),
        Process(13, 'pex_core', '/run/pex_core.pid'),
        Process(14, 'pmbus_scanner', '/run/pmbus_scanner.pid'),
        Process(15, 'gpu_core', '/run/gpu_core.pid'),
        Process(16, 'pcie-device-temperature', '/run/pcie-device-temperature.pid'),
        Process(17, 'led_controller', '/run/led_controller.pid'),
        Process(18, 'control_bmc', '/run/control_bmc.pid'),
        Process(19, 'fan_generic_obj', '/run/fan_generic_obj.pid'),
    )
    while True:
        for process in processes:
            try:
                if process.restarted():
                    _emit_event(process)
            except StandardError:
                print >>sys.stderr, '[ERROR] failed to check %s' % (
                    process.name(),
                )
                traceback.print_exc()
        time.sleep(10)

if __name__ == '__main__':
    _main()
