#!/usr/bin/python

import subprocess
import sys, getopt
import os

def main(argv):
  limit = 5000000
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
  ls = subprocess.Popen(["wc", "-l", arg], stdout=subprocess.PIPE)
  size = int(ls.communicate()[0].split()[0])
  basename = os.path.basename(arg)
  loc = os.path.join(os.getcwd(),os.path.splitext(basename)[0])
  split = subprocess.Popen(["split", "-l", str(limit), "-d", '--additional-suffix=.mtx', arg, loc], stdout=subprocess.PIPE)
  split.communicate()
  if size > limit:
    num = size/limit
  else:
    num = 0
  if size % limit:
    num = num + 1;
  line1 = "var num = " + str(num) 
  line2 = "var filename = '" + os.path.splitext(basename)[0] + "'"  
  line3 = "var len = 0"
  line4 = "var browser = " + str(browser)
  line5 = "var output_file = '" + output_file + "'"
  line6 = "var num_workers = " + str(num_workers)
  line7 = "let TOTAL_MEMORY = 2147418112"
  line8 = "var tests = '" + tests + "'"
  if browser == 1:
    line7 = "let TOTAL_MEMORY = 16777216" 
  with open('input.js', 'w') as g:
    g.write(line1 + '\n' + line2 + '\n' + line3 + '\n' + line4 + '\n' + line5 + '\n' + line6 + '\n' + line7 + '\n' + line8 + '\n')
  httpd = subprocess.Popen(["python", "web.py"], stdout=subprocess.PIPE)
  url = "http://localhost:8080/static/index32.html"
  if precision == 1:
    url = "http://localhost:8080/static/index64.html"
  #browser_path = r'google-chrome'
  #browser_path = r'/home/sable/psandh3/Downloads/chrome-linux/chrome'
  #browser_path = r'/mnt/local/cheetah/chromium72/chrome'
  browser_path = r'/mnt/local/HDD_data/cheetah/chrome80/opt/google/chrome/chrome'
  browser_opts = ' '
  #browser_opts = ' '.join(["--js-flags=\"--experimental-wasm-simd --wasm-no-bounds-checks --wasm-no-stack-checks\"", "--auto-open-devtools-for-tabs"])
  #browser_opts = ' '.join(["--js-flags=\"--experimental-wasm-simd --wasm-no-bounds-checks --wasm-no-stack-checks\"", "--headless --remote-debugging-address=0.0.0.0 --remote-debugging-port=9222 --auto-open-devtools-for-tabs"])
  browser_opts = ' '.join(["--js-flags=\"--experimental-wasm-simd --wasm-no-bounds-checks --wasm-no-stack-checks\"", "--headless --remote-debugging-address=0.0.0.0 --remote-debugging-port=9222"])
  #browser_opts = ' '.join(["--js-flags=\"--experimental-wasm-simd --wasm-simd-post-mvp\"", "--headless --remote-debugging-address=0.0.0.0 --remote-debugging-port=9222 --auto-open-devtools-for-tabs"])
  if browser == 1:
    #browser_path = r'/mnt/cheetah/Firefox_nightly/firefox/firefox'
    browser_path = r'/mnt/local/HDD_data/cheetah/firefox_nightly80/firefox/firefox'
    browser_opts = ' '
    browser_opts = ' '.join(["--headless"])
    #browser_path = r'firefox'
    #browser_path = r'/mnt/cheetah/firefox64/firefox'
  #browser_opts = ' '.join(["--js-flags=\"--print-wasm-code\""])
  #browser_opts = ' '.join(["--no-sandbox", "--incognito", "--js-flags=\"--print-opt-code --print-opt-code-filter=spmv_coo --code-comments\""])
  #browser_opts = ' '.join(["--js-flags=\"--max-new-space-size=8192\""])
  #browser_opts = ' '.join(["--devtools"])
  invocation = browser_path + " " + browser_opts + " " + url 
  print invocation
  p = subprocess.Popen(invocation, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
  out, err = p.communicate()
  #print err
  httpd.terminate()
  files = os.path.splitext(basename)[0]
  for i in range(num):
    rm = subprocess.Popen(["rm", "-r", files+ str(i/10) + str(i%10) +'.mtx'], stdout=subprocess.PIPE)

if __name__ == "__main__":
  main(sys.argv[1:])

