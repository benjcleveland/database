register s3n://uw-cse344-code/myudfs.jar


-- load the test file into Pig
raw = LOAD 's3n://uw-cse-344-oregon.aws.amazon.com/cse344-test-file' USING TextLoader as (line:chararray);
-- later you will load to other files, example:
-- raw = LOAD 's3n://uw-cse-344-oregon.aws.amazon.com/btc-2010-chunk-000' USING TextLoader as (line:chararray); 

-- parse each line into ntriples
ntriples = foreach raw generate FLATTEN(myudfs.RDFSplit3(line)) as (subject:chararray,predicate:chararray,object:chararray);

-- filter the data to the tuples we care about
rdfabout = filter ntriples by subject matches '.*rdfabout\\.com.*' PARALLEL 50;

-- make a copy and rename
-- rdfabout2 = filter ntriples by subject matches '.*rdfabout\\.com.*' as (subject2:chararray,predicate2:chararray,object2:chararray);
rdfabout2 = foreach rdfabout generate $0 as subject2, $1 as predicate2, $2 as object2 PARALLEL 50;

-- join
j = join rdfabout by object, rdfabout2 by subject2 PARALLEL 50; 

-- remove duplicates
dist = DISTINCT j PARALLEL 50;

-- order by
ordered = order dist by predicate;

store ordered into '/tmp/fo5' using PigStorage();
