#!/usr/bin/python3.11
import subprocess, pathlib, sys, json, re, datetime, os, shutil, hashlib
D=pathlib.Path(__file__).resolve().parent
G=D.parents[1]/'scripts/resource_gate.py'
def call(args,cwd,log,timeout=180):
 with open(log,'w') as f:
  try:return subprocess.run(['/usr/bin/python3.11',str(G),'--']+args,cwd=cwd,stdout=f,stderr=subprocess.STDOUT,timeout=timeout).returncode
  except subprocess.TimeoutExpired:return 124
if sys.argv[1]=='coverage':
 tag=sys.argv[2];out=D/'coverage'/(sys.argv[3] if len(sys.argv)>3 else tag);out.mkdir(exist_ok=False)
 data=json.loads((D/'results.json').read_text())
 include_tags=[tag]+(['resetload'] if tag=='closed' and any(pathlib.Path(r['log']).parent.name.startswith('resetload_') for r in data['runs']) else [])
 runs=[r for r in data['runs'] if any(pathlib.Path(r['log']).parent.name.startswith(t+'_') for t in include_tags) and r['result']=='PASS' and not r['expected_failure']]
 dbs=[str(D/'build'/tag/'design.vdb')]+[r['coverage_db'] for r in runs]
 args=['urg','-full64','-dir']+dbs+['-report',str(out/'report'),'-format','both','-show','ratios','-group','ratio','-group','instcov_for_score','-log',str(out/'urg.log')]
 (out/'input_runs.json').write_text(json.dumps(runs,indent=2))
 rc=call(args,D,out/'console.log',timeout=240)
 data['coverage']['native_report']=str(out/'report');data['coverage']['scope']='tb_'+D.name+'.dut and descendants';data['coverage']['input_runs']=str(out/'input_runs.json');(D/'results.json').write_text(json.dumps(data,indent=2));sys.exit(rc)
if sys.argv[1]=='suite':
 tag=sys.argv[2]
 stages=[('directed',10,81 if D.name=='spi' else 24),('small_random',11,100),('intermediate',12,1000)]+[('large_random',seed,1000) for seed in range(101,111)]+[('reset',22,4),('negative',33,1)]
 if D.name=='spi':stages += [('boundary',44,4)]
 for phase,seed,n in stages:
  rc=subprocess.run(['/usr/bin/python3.11',str(D/'run.py'),tag,phase,str(seed),str(n)]).returncode
  if rc:sys.exit(rc)
 sys.exit(0)
p=D.name
if sys.argv[1]=='compile':
 tag=sys.argv[2] if len(sys.argv)>2 else 'enhanced'
 out=D/'build'/tag;out.mkdir(exist_ok=True)
 src=D/'baseline_source' if tag=='baseline' else D
 for sub in ['rtl','tb']:shutil.copytree(src/sub,out/'source_snapshot'/sub,dirs_exist_ok=False)
 sources=[str(x) for x in sorted((src/'rtl').glob('*.sv'))]+[str(src/'tb'/f'{p}_if.sv'),str(src/'tb'/f'{p}_pkg.sv'),str(D/'tb'/f'tb_{p}.sv')]
 rows={str(f.relative_to(out/'source_snapshot')):hashlib.sha256(f.read_bytes()).hexdigest() for f in sorted((out/'source_snapshot').rglob('*.sv'))}
 (out/'source_manifest.json').write_text(json.dumps({'files':rows,'build_sha256':hashlib.sha256(json.dumps(rows,sort_keys=True).encode()).hexdigest()},indent=2))
 args=['vcs','-full64','-sverilog','-ntb_opts','uvm-1.2','-timescale=1ns/1ps','-debug_access+all','+incdir+'+str(src/'tb'),'-cm','line+cond+fsm+tgl+branch','-cm_hier',str(D/'coverage.hier'),'-cm_dir',str(out/'design.vdb'),'-Mdir='+str(out/'csrc'),'-o',str(out/'simv')]+sources
 sys.exit(call(args,out,out/'compile.log'))
tag,phase,seed,n=sys.argv[1:5]
if not (D/'build'/tag/'simv').is_file():raise SystemExit('Build must finish successfully before simulation: '+tag)
r=D/'runs'/f'{tag}_{phase}_s{seed}_n{n}';r.mkdir(exist_ok=False)
started=datetime.datetime.now(datetime.timezone.utc).isoformat()
args=[str(D/'build'/tag/'simv'),'+UVM_TESTNAME='+p+'_test','+UVM_VERBOSITY=UVM_LOW','+ntb_random_seed='+seed,'+N='+n,'+PHASE='+phase,'+UVM_TIMEOUT=2000000000000,YES','-cm','line+cond+fsm+tgl+branch','-cm_dir',str(r/'run.vdb'),'-cm_name',r.name]
if phase in ['reset','reset_load']:args+=['+RESET_CASE']
if phase=='reset_load':args+=['+RESET_LOAD','+WAVE']
if phase=='negative':args+=['+NEGATIVE']
if phase in ['smoke','directed','reset','boundary','failure','negative']:args+=['+WAVE']
rc=call(args,r,r/'sim.log',timeout=240)
s=(r/'sim.log').read_text(errors='replace');fields={}
for k,v in re.findall(r'(issued|completed|checks|passes|fails|attempts|assert_fails|aborted)=(\d+)',s):fields[k]=int(v)
uerr=[int(x) for x in re.findall(r'UVM_ERROR\s*:\s*(\d+)',s)];ufat=[int(x) for x in re.findall(r'UVM_FATAL\s*:\s*(\d+)',s)]
manifest=D/'build'/tag/'source_manifest.json'
result=dict(build_tag=tag,source_manifest=str(manifest) if manifest.exists() else None,build_sha256=json.loads(manifest.read_text())['build_sha256'] if manifest.exists() else None,phase=phase,test=p+'_test',seed=int(seed),issued_transactions=fields.get('issued'),completed_transactions=fields.get('completed'),check_count=fields.get('checks'),pass_count=fields.get('passes'),fail_count=fields.get('fails'),uvm_error=uerr[-1] if uerr else None,uvm_fatal=ufat[-1] if ufat else None,assert_attempts=fields.get('attempts',0),assert_failures=fields.get('assert_fails',0),aborted=fields.get('aborted',0),timeout=rc==124 or 'PH_TIMEOUT' in s or '[TIMEOUT]' in s,result='PASS' if rc==0 and uerr and ufat and not uerr[-1] and not ufat[-1] and fields.get('fails')==0 and fields.get('issued')==int(n) and fields.get('completed')==int(n) else 'FAIL',expected_failure=phase in ['failure','negative','boundary'],returncode=rc,log=str(r/'sim.log'),wave=str(r/'trace.vcd') if (r/'trace.vcd').exists() else None,coverage_db=str(r/'run.vdb'),started=started,finished=datetime.datetime.now(datetime.timezone.utc).isoformat())
(r/'metadata.json').write_text(json.dumps(result,indent=2))
f=D/'results.json';data=json.loads(f.read_text()) if f.exists() else {'project':p,'runs':[],'coverage':{},'open_issues':[]};data['runs'].append(result);f.write_text(json.dumps(data,indent=2));print(json.dumps(result));sys.exit(0 if result['result']=='PASS' or result['expected_failure'] else 1)
