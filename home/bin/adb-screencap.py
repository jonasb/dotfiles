#!/usr/bin/env python -tt
import distutils.spawn
import os
import re
import subprocess
from optparse import OptionParser

ADB_CMD='adb'
IMAGEMAGICK_MOGRIFY_CMD='mogrify'
OPEN_CMD='open' #TODO support other platforms than osx
DEVICE_TEMP_PATH='/data/local/tmp/s.png'

class AdbScreenCapCommand(object):
  def __init__(self, options, output_path):
    self.options = options
    self.output_path = output_path

  def ensure_executables_exist(self, *executables):
    for executable in executables:
      if distutils.spawn.find_executable(executable) is None:
        raise Exception("Couldn't find executable %s" % executable)

  def adb(self, *cmd):
    return subprocess.check_output([ADB_CMD] + list(cmd))

  def detect_screen_orientation(self):
    for line in self.adb('shell', 'dumpsys', 'input').splitlines():
      if 'SurfaceOrientation' in line:
        match = re.search('([\d]+)', line)
        if match is not None:
          return int(match.group(0))
    raise Exception("Couldn't detect screen orientation")

  def enter_demo(self):
    self.adb('shell', 'am', 'broadcast', '-a', 'com.android.systemui.demo', '--es', 'command', 'enter')
    self.adb('shell', 'am', 'broadcast', '-a', 'com.android.systemui.demo', '--es', 'command', 'clock', '--es', 'hhmm', '0900')
    self.adb('shell', 'am', 'broadcast', '-a', 'com.android.systemui.demo', '--es', 'command', 'battery', '--es', 'level', '100', '--es', 'plugged', 'false')
    self.adb('shell', 'am', 'broadcast', '-a', 'com.android.systemui.demo', '--es', 'command', 'notifications', '--es', 'visible', 'false')

  def leave_demo(self):
    self.adb('shell', 'am', 'broadcast', '-a', 'com.android.systemui.demo', '--es', 'command', 'exit')

  def screen_cap(self):
    self.adb('shell', 'screencap', '-p', DEVICE_TEMP_PATH)
    self.adb('pull', DEVICE_TEMP_PATH, self.output_path)
    self.adb('shell', 'rm', DEVICE_TEMP_PATH)

  def rotate_image(self, screen_orientation):
    if screen_orientation == 0:
      return
    subprocess.check_call([IMAGEMAGICK_MOGRIFY_CMD, '-rotate', str(-screen_orientation * 90), self.output_path])

  def open_image(self):
    subprocess.check_call([OPEN_CMD, self.output_path])

  def run(self):
    self.ensure_executables_exist(ADB_CMD, IMAGEMAGICK_MOGRIFY_CMD)
    if self.options.overwrite:
      self.ensure_executables_exist(OPEN_CMD)

    screen_orientation = self.detect_screen_orientation()
    if self.options.demo:
      self.enter_demo()
    self.screen_cap()
    if self.options.demo:
      self.leave_demo()
    self.rotate_image(screen_orientation)
    print('Captured screen to %s' % self.output_path)
    if self.options.open:
      print('Opening...')
      self.open_image()

def main():
  parser = OptionParser(usage = 'usage: %prog [options] [filename]')
  parser.add_option('-f', '--force', dest='overwrite', action='store_true', default=False)
  parser.add_option('-o', '--open', dest='open', action='store_true', default=False)
  parser.add_option('-d', '--demo', dest='demo', action='store_true', default=False)
  (options, args) = parser.parse_args()
  if len(args) > 1:
    parser.error("Only one filename can be specified (got %d)" % len(args))
  output_path = len(args) == 1 and args[0] or 'screen.png'
  output_path = os.path.abspath(output_path)
  if not options.overwrite and os.path.exists(output_path):
    parser.error('Output file already exists, use -f to overwrite (%s)' % output_path)

  AdbScreenCapCommand(options, output_path).run()

if __name__ == '__main__':
  main()
