-- Ben Cleveland
-- CSEP 544
-- Homework 3 Problem 2

-- Number of Nodes: 5
-- Amount of time to run: ~6 minutes, 3 seconds


register s3n://uw-cse344-code/myudfs.jar


-- load the test file into Pig
-- raw = LOAD 's3n://uw-cse-344-oregon.aws.amazon.com/cse344-test-file' USING TextLoader as (line:chararray);
-- later you will load to other files, example:
raw = LOAD 's3n://uw-cse-344-oregon.aws.amazon.com/btc-2010-chunk-000' USING TextLoader as (line:chararray); 

-- parse each line into ntriples
ntriples = foreach raw generate FLATTEN(myudfs.RDFSplit3(line)) as (subject:chararray,predicate:chararray,object:chararray);

--group the n-triples by subject column
subjects = group ntriples by (subject);

-- flatten the objects out (because group by produces a tuple of each object
-- in the first column, and we want each object to be a string, not a tuple),
-- and count the number of tuples associated with each subject
count_by_subject = foreach subjects generate flatten($0), COUNT($1) as count;

-- group by the subject count
x_by_counts = group count_by_subject by count;

-- Compute the final counts
x_y = foreach x_by_counts generate flatten($0), COUNT($1) as y;

-- store the results in the folder /user/hadoop/example-results
store x_y into '/user/hadoop/fo2' using PigStorage();
-- Alternatively, you can store the results in S3, see instructions:
-- store x_y into 's3n://superman-hw6/example-results';
