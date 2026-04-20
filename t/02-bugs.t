#!perl
use 5.006;
use strict;
use warnings;
use Test::More;
use Date::Parse::Modern;

# All the test times are assuming PST (-0800) so we force that TZ
$Date::Parse::Modern::LOCAL_TZ_OFFSET = "-28800";

# Known fixed bugs
is(strtotime('11/23/2025 08:00 PM')     , 1763956800, 'Github issue #2');
is(strtotime('May 15th, 10:15am 2025')  , 1747332900, 'Github issue #5');
is(strtotime('May 15, 10:15am 2025')    , 1747332900, 'Github issue #5');
is(strtotime('May 15th, 2025')          , 1747296000, 'Github issue #5');
is(strtotime('May 15, 2025')            , 1747296000, 'Github issue #5');

done_testing();
