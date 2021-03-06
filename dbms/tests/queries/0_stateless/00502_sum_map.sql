SET send_logs_level = 'none';

CREATE DATABASE IF NOT EXISTS test;
DROP TABLE IF EXISTS test.sum_map;
CREATE TABLE test.sum_map(date Date, timeslot DateTime, statusMap Nested(status UInt16, requests UInt64)) ENGINE = Log;

INSERT INTO test.sum_map VALUES ('2000-01-01', '2000-01-01 00:00:00', [1, 2, 3], [10, 10, 10]), ('2000-01-01', '2000-01-01 00:00:00', [3, 4, 5], [10, 10, 10]), ('2000-01-01', '2000-01-01 00:01:00', [4, 5, 6], [10, 10, 10]), ('2000-01-01', '2000-01-01 00:01:00', [6, 7, 8], [10, 10, 10]);

SELECT * FROM test.sum_map ORDER BY timeslot;
SELECT sumMap(statusMap.status, statusMap.requests) FROM test.sum_map;
SELECT sumMapMerge(s) FROM (SELECT sumMapState(statusMap.status, statusMap.requests) AS s FROM test.sum_map);
SELECT timeslot, sumMap(statusMap.status, statusMap.requests) FROM test.sum_map GROUP BY timeslot ORDER BY timeslot;
SELECT timeslot, sumMap(statusMap.status, statusMap.requests).1, sumMap(statusMap.status, statusMap.requests).2 FROM test.sum_map GROUP BY timeslot ORDER BY timeslot;

SELECT sumMapFiltered([1])(statusMap.status, statusMap.requests) FROM test.sum_map;
SELECT sumMapFiltered([1, 4, 8])(statusMap.status, statusMap.requests) FROM test.sum_map;

DROP TABLE test.sum_map;

select sumMap(val, cnt) from ( SELECT [ CAST(1, 'UInt64') ] as val, [1] as cnt );
select sumMap(val, cnt) from ( SELECT [ CAST(1, 'Float64') ] as val, [1] as cnt );
select sumMap(val, cnt) from ( SELECT [ CAST('a', 'Enum16(\'a\'=1)') ] as val, [1] as cnt );

select sumMap(val, cnt) from ( SELECT [ CAST(1, 'DateTime(\'Europe/Moscow\')') ] as val, [1] as cnt );
select sumMap(val, cnt) from ( SELECT [ CAST(1, 'Date') ] as val, [1] as cnt );
select sumMap(val, cnt) from ( SELECT [ CAST('01234567-89ab-cdef-0123-456789abcdef', 'UUID') ] as val, [1] as cnt );
select sumMap(val, cnt) from ( SELECT [ CAST(1.01, 'Decimal(10,2)') ] as val, [1] as cnt );

select sumMap(val, cnt) from ( SELECT [ CAST('a', 'FixedString(1)') ] as val, [1] as cnt ); -- { serverError 43 }
select sumMap(val, cnt) from ( SELECT [ CAST('a', 'String') ] as val, [1] as cnt ); -- { serverError 43 }
