import sys
import os
from pathlib import Path as path
import pandas as pd
from chelsa_cmip6.GetClim import chelsa_cmip6

datadir = sys.argv[1]
area = sys.argv[2]
pars = sys.argv[3]
pars = pd.read_csv(pars)
task = os.getenv('SLURM_ARRAY_TASK_ID')
print('Task: ' + task)
task = int(task) - 1
if task is None:
  sys.exit('NOT AN ARRAY JOB')
else:
  institution = pars.institution[task]
  model = pars.model[task]
  experiment = pars.experiment[task]
  print(' - ' + institution)
  print(' - ' + model)
  print(' - ' + experiment)

#institution = 'MPI-M' #pars.institution[task]
#model = 'MPI-ESM1-2-LR' #pars.model[task]
#experiment = 'ssp585'

print(' === START === ')

if area == 'america':
  x_min = -169,
  x_max = -51,
  y_min = 4,
  y_max = 75,
else:
  x_min = -25,
  x_max = 59,
  y_min = 15,
  y_max = 72,

for yr in range(2040, 2101):
  print(' - Year: ' + str(yr))
  period = '2040-2070' if yr <= 2070 else '2071-2100'
  out = str(path(datadir, model, experiment, period, area, str(yr)))
  print(' - output in: ' + out)
  chelsa_cmip6(
    activity_id = 'ScenarioMIP',
    table_id = 'Amon',
    experiment_id = experiment,
    institution_id = institution,
    source_id = model,
    member_id = 'r1i1p1f1',
    refps = '1981-01-15',
    refpe = '2010-12-15',
    fefps = str(yr) + '-01-01',
    fefpe = str(yr) + '-12-31',
    xmin = x_min,
    xmax = x_max,
    ymin = y_min,
    ymax = y_max,
    output = out
  )

print(' === END === ')
