import os
import subprocess
import sys
import json

from bottle import route, run, static_file

@route('/static/<name:path>')
def get_file(name):
  response = static_file(name, os.getcwd())
  response.set_header('Cache-Control', 'no-cache, max-age=0')
  #response.set_header('Expires', '0')
  #response.set_header('Pragma', 'no-cache')
  return response

@route('/close/<json_string:path>')
def result(json_string):
  parsed_json = json.loads(json_string) 
  browser = parsed_json['browser']
  #if browser == 0:
    #subprocess.call(['killall', '-9', 'chrome']);
  return "OK"

@route('/spmv_bench/<json_string:path>')
def result(json_string):
  parsed_json = json.loads(json_string) 
  output_file = parsed_json['output_file']
  #print(output_file, file=sys.stderr)
  #print(os.path.join(os.getcwd(), output_file), file=sys.stderr)
  f = open(os.path.join(os.getcwd(), output_file),'a')
  browser = parsed_json['browser']
  f.write(os.path.splitext(os.path.basename(parsed_json['file']))[0])
  f.write(",")
  f.write(str(parsed_json['outer_max']))
  f.write(",")
  f.write(str(parsed_json['inner_max']))
  f.write(",")
  f.write(str(parsed_json['N']))
  f.write(",")
  f.write(str(parsed_json['nnz']))
  f.write(",")
  f.write(str(parsed_json['coo_sd']))
  f.write(",")
  f.write(str(parsed_json['coo']))
  f.write(",")
  f.write(str(parsed_json['coo_sum']))
  f.write(",")
  f.write(str(parsed_json['csr_sd']))
  f.write(",")
  f.write(str(parsed_json['csr']))
  f.write(",")
  f.write(str(parsed_json['csr_sum']))
  f.write(",")
  f.write(str(parsed_json['dia_sd']))
  f.write(",")
  f.write(str(parsed_json['dia']))
  f.write(",")
  f.write(str(parsed_json['dia_sum']))
  f.write(",")
  f.write(str(parsed_json['ell_sd']))
  f.write(",")
  f.write(str(parsed_json['ell']))
  f.write(",")
  f.write(str(parsed_json['ell_sum']))
  f.write(",")
  f.write("\n")
  f.close()
  #if browser == 0:
    #subprocess.call(['killall', '-9', 'chrome']);
  #elif browser == 1:
    #subprocess.call(['killall', '-9', 'firefox']);
    #sys.stderr.close()
    #sys.exit(0)
  #if browser == 0:
    #subprocess.Popen(["killall", "-9", "chrome"], stdout=subprocess.PIPE).communicate()
    #sys.stderr.close()
    #sys.exit(0)
    #subprocess.call(['killall', '-9', 'chrome']);
  #if browser == 1:
    #subprocess.call(['killall', '-9', 'firefox-bin']);
  return "OK"

#print(os.getcwd(), file=sys.stderr)
os.chdir('../')
#print(os.getcwd(), file=sys.stderr)
run(host='localhost', port=8080, quiet=True)
