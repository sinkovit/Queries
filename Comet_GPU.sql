-- Query for getting information on projects using GPUs
-- with results broken down by usage in theshared and dedicated queues

-- Get info on projects running in both shared and dedicated queues
select t1.pn project, t1.job_count GPU_jobcount, t1.total_charges GPU_charges, t2.job_count GPU_shared_jobcount, t2.total_charges GPU_shared_charges
from
(select project_name pn, count(charge) job_count, sum(charge) total_charges
from JOBS_AND_CHARGES 
where queue = 'gpu' 
group by (project_name)) t1,
(select project_name pn, count(charge) job_count, sum(charge) total_charges
from JOBS_AND_CHARGES 
where queue = 'gpu-shared' 
group by (project_name)) t2
where t1.pn = t2.pn

UNION

-- Projects running in just dedicated queue
select project_name pn, count(charge) job_count, sum(charge) total_charges, 0, 0
from JOBS_AND_CHARGES
where queue = 'gpu'
and project_name NOT IN (select unique project_name from JOBS_AND_CHARGES where queue = 'gpu-shared') 
group by (project_name)

UNION

-- Projects running in just shared queue
select project_name pn, 0, 0, count(charge) job_count, sum(charge) total_charges
from JOBS_AND_CHARGES
where queue = 'gpu-shared'
and project_name NOT IN (select unique project_name from JOBS_AND_CHARGES where queue = 'gpu') 
group by (project_name)

order by 1
