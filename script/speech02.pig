-- paths passed in via command line (pig ... -param VAR=value)
-- and also add to Java classpath
-- S4JARPATH <path to s4_core, Pig Wrapper and related jars>
-- APPPATH   <path to S4 applicaiton jar(s)>
-- DATAPATH  <HDFS path (or local path if in local mode) to input data

-- jars needed for the wrapper
register $S4JARPATH/s4-core-0.3-SNAPSHOT.jar;
register $S4JARPATH/spring-2.5.6.jar;
register $S4JARPATH/kryo-1.01.jar;
register $S4JARPATH/bcel-5.2.jar;
register $S4JARPATH/minlog-1.2.jar;
register $S4JARPATH/S4PigWrapper-0.1.jar;

-- jar for our S4 application
register $APPPATH/speech01-0.0.0.1.jar

-- data stored on grid
%declare confpath $DATAPATH/conf
%declare datapath $DATAPATH/data/speech02


-- speech events
define createSpeechEvent io.s4.pig.S4EventBuilder('io.s4.example.speech01.Speech; id; location; speaker; time');
define rerouteSpeechPE io.s4.pig.S4PEWrapper('rerouteSpeechPE; $confpath; speech02_conf.xml');
define speechTimeReader io.s4.pig.S4EventReader('io.s4.example.speech01.Speech');

-- sentence events
define createSentenceEvent io.s4.pig.S4EventBuilder('io.s4.example.speech01.Sentence; id; speechId; text; time');
define rerouteSentencePE io.s4.pig.S4PEWrapper('rerouteSentencePE; $confpath; speech02_conf.xml');
define sentenceTimeReader io.s4.pig.S4EventReader('io.s4.example.speech01.Sentence');

-- joining PE and event catcher (displays events)
define sentenceJoinPE io.s4.pig.S4PEWrapper('sentenceJoinPE; $confpath; speech02_conf.xml');
define eventCatcher io.s4.pig.S4PEWrapper('eventCatcher; $confpath; speech02_conf.xml');


-- load speech, sentence data
speech_data = load '$datapath/speech.txt' as (id: int, location: chararray, speaker: chararray, time: long);
sentence_data = load '$datapath/sentence.txt' as (id: int, speechId: int, text: chararray, time: long);


-- create speec events from raw data
rawSpeechEvts =
foreach
	speech_data
generate
	'RawSpeech' as streamName,
	null as keyName,
	null as keyValue,
	null as compoundKeyInfo,
	createSpeechEvent(id, location, speaker, time) as event;
rawSpeechGroup = group rawSpeechEvts by (streamName, keyName, keyValue);

-- process bag of events
speechData =
foreach
	rawSpeechGroup
generate
	flatten( rerouteSpeechPE(rawSpeechEvts) ) as (serialPE, peKey, BofE);

speechFlat =
foreach
	speechData
generate
	flatten(BofE) as (streamName, keyName, keyValue, compoundKeyInfo, event);

speechEvts =
foreach
	speechFlat
generate
	*,
	(long)speechTimeReader(event, 'time')#'time' as time;

dump speechEvts;
describe speechEvts;


-- create sentence events
rawSentenceEvts =
foreach
	sentence_data
generate
	'RawSentence' as streamName,
	null as keyName,
	null as keyValue,
	null as compoundKeyInfo,
	createSentenceEvent(id, speechId, text, time);
rawSentenceGroup = group rawSentenceEvts by (streamName, keyName, keyValue);

-- process bag of events
sentenceData =
foreach
	rawSentenceGroup
generate
	flatten( rerouteSentencePE(rawSentenceEvts) ) as (serialPE, peKey, BofE);

sentenceFlat =
foreach
	sentenceData
generate
	flatten(BofE) as (streamName, keyName, keyValue, compoundKeyInfo, event);

sentenceEvts =
foreach
	sentenceFlat
generate
	*,
	(long)sentenceTimeReader(event, 'time')#'time' as time;

--dump sentenceEvts;
describe sentenceEvts;


-- filter and join (in pig: union) the right event types
speechJoinEvts = filter speechEvts by
	streamName == 'Speech' and keyName == 'id';
sentenceJoinEvts = filter sentenceEvts by
	streamName == 'Sentence' and keyName == 'speechId';

joinInputEvts = union onschema speechJoinEvts, sentenceJoinEvts;
joinInputGrouped = group joinInputEvts by (keyValue);

--dump joinInputGrouped;
describe joinInputGrouped;

-- send to the joinPE
sortedData =
foreach
	joinInputGrouped {
	sorted_events = order joinInputEvts by time;
generate
	sorted_events as sorted_events;
}

dump sortedData;
describe sortedData;

joinedData =
foreach
	sortedData
generate
	flatten( sentenceJoinPE(sorted_events) ) as (serialPE, peKey, BofE);

dump joinedData;
describe joinedData;

joinedFlat =
foreach
	joinedData
generate
	flatten(BofE) as (streamName, keyName, keyValue, compoundKeyInfo, event);

joinedEvts =
foreach
	joinedFlat
generate
	*,
	(long)sentenceTimeReader(event, 'time')#'time' as time;

describe joinedEvts;

joinedGroup = group joinedEvts by (keyValue);

-- send to the event catcher (no need to group)
preFinalSorted =
foreach
	joinedGroup {
	sorted_events = order joinedEvts by time;
generate
	sorted_events as sorted_events;
}

finalData =
foreach
	preFinalSorted
generate
	flatten( eventCatcher(sorted_events) ) as (serialPE, peKey, BofE);

-- no output events; data written to stdout in reduce job
dump finalData;
describe finalData;
