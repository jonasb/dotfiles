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

def ensure_executables_exist(*executables):
  for executable in executables:
    if distutils.spawn.find_executable(executable) is None:
      raise Exception("Couldn't find executable %s" % executable)

def adb(*cmd):
  return subprocess.check_output([ADB_CMD] + list(cmd))

def detect_screen_orientation():
  for line in adb('shell', 'dumpsys', 'input').splitlines():
    if 'SurfaceOrientation' in line:
      match = re.search('([\d]+)', line)
      if match is not None:
        return int(match.group(0))
  raise Exception("Couldn't detect screen orientation")

def screen_cap(output_path):
  adb('shell', 'screencap', '-p', DEVICE_TEMP_PATH)
  adb('pull', DEVICE_TEMP_PATH, output_path)
  adb('shell', 'rm', DEVICE_TEMP_PATH)

def rotate_image(output_path, screen_orientation):
  if screen_orientation == 0:
    return
  subprocess.check_call([IMAGEMAGICK_MOGRIFY_CMD, '-rotate', str(-screen_orientation * 90), output_path])

def open_image(output_path):
  subprocess.check_call([OPEN_CMD, output_path])

def main():
  parser = OptionParser(usage = 'usage: %prog [options] [filename]')
  parser.add_option('-f', '--force', dest='overwrite', action='store_true', default=False)
  parser.add_option('-o', '--open', dest='open', action='store_true', default=False)
  (options, args) = parser.parse_args()
  if len(args) > 1:
    parser.error("Only one filename can be specified (got %d)" % len(args))
  output_path = len(args) == 1 and args[0] or 'screen.png'
  output_path = os.path.abspath(output_path)
  if not options.overwrite and os.path.exists(output_path):
    parser.error('Output file already exists, use -f to overwrite (%s)' % output_path)

  ensure_executables_exist(ADB_CMD, IMAGEMAGICK_MOGRIFY_CMD)
  if options.open:
    ensure_executables_exist(OPEN_CMD)

  screen_orientation = detect_screen_orientation()
  screen_cap(output_path)
  rotate_image(output_path, screen_orientation)
  print('Captured screen to %s' % output_path)
  if options.open:
    print('Opening...')
    open_image(output_path)

if __name__ == '__main__':
  main()
