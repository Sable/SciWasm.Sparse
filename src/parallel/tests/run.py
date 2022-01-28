#!/usr/bin/python

import subprocess
import sys, getopt
import os

def main(argv):
  browser = 0
  precision = 0
  num_workers = 1
  b_found = False
  p_found = False
  w_found = False
  tests = 'all'
  output_file = 'e.out'
  try :
    opts, args = getopt.getopt(argv, "hb:p:o:w:t:")
  except getopt.GetoptError:
    print 'ERROR : run.py -b <browser> -p <precision> <input_filename>'
    sys.exit(2)
  for opt, arg in opts:
    if opt == '-h':
      print 'ERROR : run.py -b <browser> -p <precision> <input_filename>'
      sys.exit()
    elif opt == '-b':
      b_found = True
      if arg == 'chrome':
        browser = 0
      elif arg == 'firefox':
        browser = 1
      else:
        print 'Error in browser argument. Usage : run.py -b <browser> -p <precision> <input_filename>'
        sys.exit()
    elif opt == '-p':
      p_found = True
      if arg == 'single':
        precision = 0
      elif arg == 'double':
        precision = 1
      else:
        print 'Error in precision argument. Usage : run.py -b <browser> -p <precision> <input_filename>'
        sys.exit()
    elif opt == '-o':
      output_file = arg
    elif opt == '-w':
      w_found = True
      num_workers = arg
    elif opt == '-t':
      tests = arg
  if not b_found or not p_found or not w_found:
    print 'run.py -b <browser> -p <precision> -w <workers> <input_filename>'
    sys.exit()

  arg = args[0] 
  basename = os.path.basename(arg)
  status = subprocess.call('cp ' + arg + ' ' + basename, shell=True)
  line1 = "var filename = '" + basename + "'"  
  line2 = "var browser = " + str(browser)
  line3 = "var output_file = '" + output_file + "'"
  line4 = "var num_workers = " + str(num_workers)
  line5 = "var tests = '" + tests + "'"
  line6 = "let TOTAL_MEMORY = 2147418112"
  if browser == 1:
    line6 = "let TOTAL_MEMORY = 16777216" 
  with open('input.js', 'w') as g:
    g.write(line1 + '\n' + line2 + '\n' + line3 + '\n' + line4 + '\n' + line5 + '\n' + line6 + '\n')
  httpd = subprocess.Popen(["python", "web.py"], stdout=subprocess.PIPE)

  url = "http://localhost:8080/static/tests/index32.html"
  if precision == 1:
    url = "http://localhost:8080/static/tests/index64.html"

  browser_path = r'/mnt/local/HDD_data/cheetah/chrome97/opt/google/chrome/chrome'
  browser_opts = ' '
  browser_opts = ' '.join(["--js-flags=\"--experimental-wasm-simd --wasm-no-bounds-checks --wasm-no-stack-checks\"", "--headless --remote-debugging-address=0.0.0.0 --remote-debugging-port=9222 --enable-features=SharedArrayBuffer"])
  if browser == 1:
    browser_path = r'/mnt/local/HDD_data/cheetah/firefox_nightly80/firefox/firefox'
    browser_opts = ' '
    browser_opts = ' '.join(["--headless"])
  invocation = browser_path + " " + browser_opts + " " + url 
  print invocation

  p = subprocess.Popen(invocation, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
  out, err = p.communicate()
  httpd.terminate()
  status = subprocess.call('rm ' + os.path.splitext(basename)[0] + '.mtx', shell=True)

if __name__ == "__main__":
  main(sys.argv[1:])

