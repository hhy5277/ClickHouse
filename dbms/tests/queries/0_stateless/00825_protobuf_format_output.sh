#!/usr/bin/env bash

# To generate reference file for this test use the following commands:
# ninja ProtobufDelimitedMessagesSerializer
# build/utils/test-data-generator/ProtobufDelimitedMessagesSerializer > dbms/tests/queries/0_stateless/00825_protobuf_format_output.reference

CURDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
. $CURDIR/../shell_config.sh

set -e -o pipefail

# Copy schema files to the current directory because the client can open schemas from the current directory only.
cp "$CURDIR/00825_protobuf_format.proto" 00825_protobuf_format_copy.proto
cp "$CURDIR/00825_protobuf_format_syntax2.proto" 00825_protobuf_format_syntax2_copy.proto

# Run the client.
$CLICKHOUSE_CLIENT --multiquery <<'EOF'
SET allow_experimental_low_cardinality_type = 1;
CREATE DATABASE IF NOT EXISTS test;
DROP TABLE IF EXISTS test.table;

CREATE TABLE test.table (uuid UUID,
                         name String,
                         surname String,
                         gender Enum8('male'=1, 'female'=0),
                         birthDate Date,
                         photo Nullable(String),
                         phoneNumber Nullable(FixedString(13)),
                         isOnline UInt8,
                         visitTime Nullable(DateTime),
                         age UInt8,
                         zodiacSign Enum16('aries'=321, 'taurus'=420, 'gemini'=521, 'cancer'=621, 'leo'=723, 'virgo'=823,
                                           'libra'=923, 'scorpius'=1023, 'sagittarius'=1122, 'capricorn'=1222, 'aquarius'=120,
                                           'pisces'=219),
                         songs Array(String),
                         color Array(UInt8),
                         hometown LowCardinality(String),
                         location Array(Decimal32(6)),
                         pi Nullable(Float64),
                         lotteryWin Nullable(Decimal64(2)),
                         someRatio Float32,
                         temperature Decimal32(1),
                         randomBigNumber Int64
                         ) ENGINE = MergeTree ORDER BY tuple();

INSERT INTO test.table VALUES (toUUID('a7522158-3d41-4b77-ad69-6c598ee55c49'), 'Ivan', 'Petrov', 'male', toDate('1980-12-29'), 'png', '+74951234567', 1, toDateTime('2019-01-05 18:45:00'), 38, 'capricorn', ['Yesterday', 'Flowers'], [255, 0, 0], 'Moscow', [55.753215, 37.622504], 3.14, 214.10, 0.1, 5.8, 17060000000);
INSERT INTO test.table VALUES (toUUID('c694ad8a-f714-4ea3-907d-fd54fb25d9b5'), 'Natalia', 'Sokolova', 'female', toDate('1992-03-08'), 'jpg', NULL, 0, NULL, 26, 'pisces', [], [100, 200, 50], 'Plymouth', [50.403724, -4.142123], 3.14159, NULL, 0.007, 5.4, -20000000000000);
INSERT INTO test.table VALUES (toUUID('a7da1aa6-f425-4789-8947-b034786ed374'), 'Vasily', 'Sidorov', 'male', toDate('1995-07-28'), 'bmp', '+442012345678', 1, toDateTime('2018-12-30 00:00:00'), 23, 'leo', ['Sunny'], [250, 244, 10], 'Murmansk', [68.970682, 33.074981], 3.14159265358979, 100000000000, 800, -3.2, 154400000);

SELECT * FROM test.table ORDER BY name FORMAT Protobuf SETTINGS format_schema = '00825_protobuf_format_copy:Person';
SELECT 'ALTERNATIVE->';
SELECT * FROM test.table ORDER BY name FORMAT Protobuf SETTINGS format_schema = '00825_protobuf_format_copy:AltPerson';
SELECT 'STRINGS->';
SELECT * FROM test.table ORDER BY name FORMAT Protobuf SETTINGS format_schema = '00825_protobuf_format_copy:StrPerson';
SELECT 'SYNTAX2->';
SELECT * FROM test.table ORDER BY name FORMAT Protobuf SETTINGS format_schema = '00825_protobuf_format_syntax2_copy:Syntax2Person';
EOF

# Remove copies of the schema files.
rm "00825_protobuf_format_copy.proto" "00825_protobuf_format_syntax2_copy.proto"
